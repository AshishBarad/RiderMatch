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
exports.cleanupOldDataScheduler = exports.completeRidesScheduler = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
/**
 * Scheduled function to auto-complete rides
 * Runs every hour to check for rides that have passed their end time
 */
exports.completeRidesScheduler = functions.pubsub
    .schedule('every 1 hours')
    .onRun(async (context) => {
    try {
        const now = admin.firestore.Timestamp.now();
        // Find rides that should be completed
        // Assuming rides have an estimated end time based on startDate + duration
        const ridesSnapshot = await db
            .collection('rides')
            .where('status', '==', 'UPCOMING')
            .where('startDate', '<', now)
            .limit(100)
            .get();
        if (ridesSnapshot.empty) {
            functions.logger.info('No rides to complete');
            return null;
        }
        const batch = db.batch();
        const rideIds = [];
        ridesSnapshot.docs.forEach((doc) => {
            const ride = doc.data();
            const rideStartTime = ride.startDate.toDate();
            const estimatedDuration = ride.distanceKm / 40; // Assume 40 km/h average
            const estimatedEndTime = new Date(rideStartTime.getTime() + estimatedDuration * 60 * 60 * 1000);
            // If estimated end time has passed, mark as completed
            if (estimatedEndTime < new Date()) {
                batch.update(doc.ref, {
                    status: 'COMPLETED',
                    completedAt: admin.firestore.FieldValue.serverTimestamp(),
                });
                rideIds.push(doc.id);
            }
        });
        await batch.commit();
        // Send notifications to all ride members
        const notificationPromises = rideIds.map(async (rideId) => {
            const membersSnapshot = await db
                .collection('ride_members')
                .doc(rideId)
                .collection('members')
                .where('status', '==', 'APPROVED')
                .get();
            const memberNotifications = membersSnapshot.docs.map((memberDoc) => {
                return sendNotificationToUser(memberDoc.id, {
                    title: 'Ride Completed!',
                    body: 'How was your ride? Share your experience!',
                    data: {
                        type: 'RIDE_COMPLETED',
                        rideId,
                    },
                });
            });
            return Promise.all(memberNotifications);
        });
        await Promise.all(notificationPromises);
        functions.logger.info(`Completed ${rideIds.length} rides`);
        return null;
    }
    catch (error) {
        functions.logger.error('Error in completeRidesScheduler:', error);
        throw error;
    }
});
/**
 * Scheduled function to clean up old data
 * Runs daily to archive old rides and clean up expired data
 */
exports.cleanupOldDataScheduler = functions.pubsub
    .schedule('every 24 hours')
    .onRun(async (context) => {
    try {
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        const cutoffTimestamp = admin.firestore.Timestamp.fromDate(thirtyDaysAgo);
        // Delete old rejected chat requests
        const oldRequestsSnapshot = await db
            .collection('chat_requests')
            .where('status', '==', 'REJECTED')
            .where('createdAt', '<', cutoffTimestamp)
            .limit(500)
            .get();
        const batch = db.batch();
        oldRequestsSnapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
        });
        await batch.commit();
        functions.logger.info(`Cleaned up ${oldRequestsSnapshot.size} old chat requests`);
        return null;
    }
    catch (error) {
        functions.logger.error('Error in cleanupOldDataScheduler:', error);
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
//# sourceMappingURL=scheduled.js.map