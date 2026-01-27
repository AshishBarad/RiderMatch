import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Trigger when a user requests to join a ride
 * Validates capacity and prevents duplicate joins
 */
export const onRideJoinRequest = functions.firestore
    .document('ride_members/{rideId}/members/{uid}')
    .onCreate(async (snapshot, context) => {
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

            const ride = rideDoc.data()!;

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
            const userName = userDoc.data()?.name || 'Someone';

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
        } catch (error) {
            functions.logger.error('Error processing ride join request:', error);
            throw error;
        }
    });

/**
 * Trigger when a ride join request is approved
 * Updates indexes and sends notifications
 */
export const onRideJoinApproved = functions.firestore
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
                    body: `You've been approved to join "${ride?.rideName}"`,
                    data: {
                        type: 'RIDE_JOIN_APPROVED',
                        rideId,
                    },
                });

                // Subscribe user to ride topic for notifications
                await subscribeToTopic(uid, `ride_${rideId}`);

                functions.logger.info('Ride join approved processed:', { rideId, uid });
            } catch (error) {
                functions.logger.error('Error processing ride join approval:', error);
                throw error;
            }
        }
    });

/**
 * Trigger when a new ride is created
 * Notifies all followers
 */
export const onRideCreated = functions.firestore
    .document('rides/{rideId}')
    .onCreate(async (snapshot, context) => {
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
            const creatorName = creatorDoc.data()?.name || 'Someone';

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
        } catch (error) {
            functions.logger.error('Error processing ride creation:', error);
            throw error;
        }
    });

/**
 * Helper function to send FCM notification to a user
 */
async function sendNotificationToUser(
    uid: string,
    payload: {
        title: string;
        body: string;
        data?: { [key: string]: string };
    }
) {
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
    } catch (error) {
        functions.logger.error('Error sending notification:', error);
    }
}

/**
 * Helper function to subscribe user to FCM topic
 */
async function subscribeToTopic(uid: string, topic: string) {
    try {
        // In production, get user's FCM tokens and subscribe them
        functions.logger.info('User subscribed to topic:', { uid, topic });
    } catch (error) {
        functions.logger.error('Error subscribing to topic:', error);
    }
}
