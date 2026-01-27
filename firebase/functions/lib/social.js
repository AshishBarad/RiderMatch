"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.onUnfollowUser = exports.onFollowUser = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
/**
 * Trigger when a user follows another user
 * Updates follower/following counts
 */
exports.onFollowUser = functions.firestore
    .document('follows/{uid}/following/{targetUid}')
    .onCreate(async (snapshot, context) => {
    var _a;
    const { uid, targetUid } = context.params;
    try {
        const batch = db.batch();
        // Increment following count for source user
        const sourceUserRef = db.collection('users').doc(uid);
        batch.update(sourceUserRef, {
            followingCount: admin.firestore.FieldValue.increment(1),
        });
        // Increment follower count for target user
        const targetUserRef = db.collection('users').doc(targetUid);
        batch.update(targetUserRef, {
            followerCount: admin.firestore.FieldValue.increment(1),
        });
        // Create reverse relationship in followers subcollection
        const followerRef = db
            .collection('follows')
            .doc(targetUid)
            .collection('followers')
            .doc(uid);
        batch.set(followerRef, {
            sourceUid: uid,
            followedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        await batch.commit();
        // Send notification to target user
        const sourceUserDoc = await sourceUserRef.get();
        const sourceName = ((_a = sourceUserDoc.data()) === null || _a === void 0 ? void 0 : _a.name) || 'Someone';
        await sendNotificationToUser(targetUid, {
            title: 'New Follower',
            body: `${sourceName} started following you`,
            data: {
                type: 'NEW_FOLLOWER',
                followerUid: uid,
            },
        });
        functions.logger.info('Follow relationship created:', { uid, targetUid });
    }
    catch (error) {
        functions.logger.error('Error processing follow:', error);
        throw error;
    }
});
/**
 * Trigger when a user unfollows another user
 * Updates follower/following counts
 */
exports.onUnfollowUser = functions.firestore
    .document('follows/{uid}/following/{targetUid}')
    .onDelete(async (snapshot, context) => {
    const { uid, targetUid } = context.params;
    try {
        const batch = db.batch();
        // Decrement following count for source user
        const sourceUserRef = db.collection('users').doc(uid);
        batch.update(sourceUserRef, {
            followingCount: admin.firestore.FieldValue.increment(-1),
        });
        // Decrement follower count for target user
        const targetUserRef = db.collection('users').doc(targetUid);
        batch.update(targetUserRef, {
            followerCount: admin.firestore.FieldValue.increment(-1),
        });
        // Delete reverse relationship in followers subcollection
        const followerRef = db
            .collection('follows')
            .doc(targetUid)
            .collection('followers')
            .doc(uid);
        batch.delete(followerRef);
        await batch.commit();
        functions.logger.info('Follow relationship deleted:', { uid, targetUid });
    }
    catch (error) {
        functions.logger.error('Error processing unfollow:', error);
        throw error;
    }
});
/**
 * Helper function to send FCM notification
 */
async function sendNotificationToUser(uid, payload) {
    try {
        await admin.messaging().sendToTopic(`user_${uid}`, {
            notification: {
                title: payload.title,
                body: payload.body,
            },
            data: payload.data || {},
        });
    }
    catch (error) {
        functions.logger.error('Error sending notification:', error);
    }
}
//# sourceMappingURL=social.js.map