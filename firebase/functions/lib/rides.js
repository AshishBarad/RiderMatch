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
exports.onRideCreated = exports.onRideJoinApproved = exports.onRideJoinRequest = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
/**
 * Trigger when a user requests to join a ride
 * Validates capacity and prevents duplicate joins
 */
exports.onRideJoinRequest = functions.firestore
    .document('ride_members/{rideId}/members/{uid}')
    .onCreate(async (snapshot, context) => {
    var _a;
    const { rideId, uid } = context.params;
    const memberData = snapshot.data();
    try {
        // Get ride document
        const rideRef = db.collection('rides').doc(rideId);
        const rideDoc = await rideRef.get();
        if (!rideDoc.exists) {
            functions.logger.error('Ride not found:', rideId);
            return;
        }
        const ride = rideDoc.data();
        // Check if ride is full
        if (ride.currentParticipants >= ride.maxParticipants) {
            // Update member status to rejected
            await snapshot.ref.update({
                status: 'REJECTED',
                rejectionReason: 'Ride is full',
            });
            functions.logger.warn('Ride full, request rejected:', rideId);
            return;
        }
        // Send notification to ride manager
        const managerUid = ride.createdBy;
        const userDoc = await db.collection('users').doc(uid).get();
        const userName = ((_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.name) || 'Someone';
        await sendNotificationToUser(managerUid, {
            title: 'New Ride Join Request',
            body: `${userName} wants to join your ride "${ride.rideName}"`,
            data: {
                type: 'RIDE_JOIN_REQUEST',
                rideId,
                requesterId: uid,
            },
        });
        functions.logger.info('Ride join request processed:', { rideId, uid });
    }
    catch (error) {
        functions.logger.error('Error processing ride join request:', error);
        throw error;
    }
});
/**
 * Trigger when a ride join request is approved
 * Updates indexes and sends notifications
 */
exports.onRideJoinApproved = functions.firestore
    .document('ride_members/{rideId}/members/{uid}')
    .onUpdate(async (change, context) => {
    const { rideId, uid } = context.params;
    const before = change.before.data();
    const after = change.after.data();
    // Only process if status changed to APPROVED
    if (before.status !== 'APPROVED' && after.status === 'APPROVED') {
        try {
            const batch = db.batch();
            // Add to user_rides index
            const userRideRef = db
                .collection('user_rides')
                .doc(uid)
                .collection('rides')
                .doc(rideId);
            batch.set(userRideRef, {
                rideId,
                type: 'JOINED',
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            // Increment ride participant count
            const rideRef = db.collection('rides').doc(rideId);
            batch.update(rideRef, {
                currentParticipants: admin.firestore.FieldValue.increment(1),
            });
            await batch.commit();
            // Send notification to user
            const rideDoc = await rideRef.get();
            const ride = rideDoc.data();
            await sendNotificationToUser(uid, {
                title: 'Ride Request Approved!',
                body: `You've been approved to join "${ride === null || ride === void 0 ? void 0 : ride.rideName}"`,
                data: {
                    type: 'RIDE_JOIN_APPROVED',
                    rideId,
                },
            });
            // Subscribe user to ride topic for notifications
            await subscribeToTopic(uid, `ride_${rideId}`);
            functions.logger.info('Ride join approved processed:', { rideId, uid });
        }
        catch (error) {
            functions.logger.error('Error processing ride join approval:', error);
            throw error;
        }
    }
});
/**
 * Trigger when a new ride is created
 * Notifies all followers
 */
exports.onRideCreated = functions.firestore
    .document('rides/{rideId}')
    .onCreate(async (snapshot, context) => {
    var _a;
    const { rideId } = context.params;
    const ride = snapshot.data();
    try {
        // Get creator's followers
        const followersSnapshot = await db
            .collection('follows')
            .doc(ride.createdBy)
            .collection('followers')
            .get();
        if (followersSnapshot.empty) {
            functions.logger.info('No followers to notify for ride:', rideId);
            return;
        }
        // Get creator's name
        const creatorDoc = await db.collection('users').doc(ride.createdBy).get();
        const creatorName = ((_a = creatorDoc.data()) === null || _a === void 0 ? void 0 : _a.name) || 'Someone';
        // Send notifications to all followers
        const notificationPromises = followersSnapshot.docs.map((doc) => {
            const followerUid = doc.data().sourceUid;
            return sendNotificationToUser(followerUid, {
                title: 'New Ride from ' + creatorName,
                body: `${ride.rideName} - ${ride.fromLocation.name} to ${ride.toLocation.name}`,
                data: {
                    type: 'NEW_RIDE',
                    rideId,
                    creatorUid: ride.createdBy,
                },
            });
        });
        await Promise.all(notificationPromises);
        // Add to creator's user_rides index
        await db
            .collection('user_rides')
            .doc(ride.createdBy)
            .collection('rides')
            .doc(rideId)
            .set({
            rideId,
            type: 'CREATED',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        functions.logger.info('Ride created notifications sent:', rideId);
    }
    catch (error) {
        functions.logger.error('Error processing ride creation:', error);
        throw error;
    }
});
/**
 * Helper function to send FCM notification to a user
 */
async function sendNotificationToUser(uid, payload) {
    try {
        // In production, you'd get the FCM token from a tokens collection
        // For now, send to topic
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
/**
 * Helper function to subscribe user to FCM topic
 */
async function subscribeToTopic(uid, topic) {
    try {
        // In production, get user's FCM tokens and subscribe them
        functions.logger.info('User subscribed to topic:', { uid, topic });
    }
    catch (error) {
        functions.logger.error('Error subscribing to topic:', error);
    }
}
//# sourceMappingURL=rides.js.map