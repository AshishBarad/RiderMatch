import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Trigger when a user follows another user
 * Updates follower/following counts
 */
export const onFollowUser = functions.firestore
    .document('follows/{uid}/following/{targetUid}')
    .onCreate(async (snapshot, context) => {
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
            const sourceName = sourceUserDoc.data()?.name || 'Someone';

            await sendNotificationToUser(targetUid, {
                title: 'New Follower',
                body: `${sourceName} started following you`,
                data: {
                    type: 'NEW_FOLLOWER',
                    followerUid: uid,
                },
            });

            functions.logger.info('Follow relationship created:', { uid, targetUid });
        } catch (error) {
            functions.logger.error('Error processing follow:', error);
            throw error;
        }
    });

/**
 * Trigger when a user unfollows another user
 * Updates follower/following counts
 */
export const onUnfollowUser = functions.firestore
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
        } catch (error) {
            functions.logger.error('Error processing unfollow:', error);
            throw error;
        }
    });

/**
 * Helper function to send FCM notification
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
