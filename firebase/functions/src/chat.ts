import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Trigger when a new chat message is sent
 * Sends FCM notification to recipient
 */
export const onChatMessage = functions.firestore
    .document('chat_messages/{chatId}/messages/{messageId}')
    .onCreate(async (snapshot, context) => {
        const { chatId, messageId } = context.params;
        const message = snapshot.data();

        try {
            // Get chat document
            const chatDoc = await db.collection('direct_chats').doc(chatId).get();

            if (!chatDoc.exists) {
                functions.logger.error('Chat not found:', chatId);
                return;
            }

            const chat = chatDoc.data()!;

            // Get recipient UID (the other participant)
            const recipientUid = chat.participantIds.find(
                (id: string) => id !== message.senderId
            );

            if (!recipientUid) {
                functions.logger.error('Recipient not found in chat:', chatId);
                return;
            }

            // Update chat document with last message
            await db.collection('direct_chats').doc(chatId).update({
                lastMessage: message.content,
                lastMessageTime: message.createdAt,
                [`unreadCount.${recipientUid}`]: admin.firestore.FieldValue.increment(1),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            // Get sender's name
            const senderDoc = await db.collection('users').doc(message.senderId).get();
            const senderName = senderDoc.data()?.name || 'Someone';

            // Send FCM notification to recipient
            await sendNotificationToUser(recipientUid, {
                title: senderName,
                body: message.content,
                data: {
                    type: 'CHAT_MESSAGE',
                    chatId,
                    senderId: message.senderId,
                },
            });

            functions.logger.info('Chat message notification sent:', {
                chatId,
                messageId,
            });
        } catch (error) {
            functions.logger.error('Error processing chat message:', error);
            throw error;
        }
    });

/**
 * Trigger when a chat request is approved
 * Creates the chat room
 */
export const onChatRequestApproved = functions.firestore
    .document('chat_requests/{requestId}')
    .onUpdate(async (change, context) => {
        const { requestId } = context.params;
        const before = change.before.data();
        const after = change.after.data();

        // Only process if status changed to APPROVED
        if (before.status !== 'APPROVED' && after.status === 'APPROVED') {
            try {
                // Create chat document
                const chatRef = db.collection('direct_chats').doc();

                await chatRef.set({
                    chatId: chatRef.id,
                    participantIds: [after.fromUserId, after.toUserId],
                    lastMessage: after.message || null,
                    lastMessageTime: after.message
                        ? admin.firestore.FieldValue.serverTimestamp()
                        : null,
                    status: 'APPROVED',
                    requestedBy: after.fromUserId,
                    unreadCount: {
                        [after.fromUserId]: 0,
                        [after.toUserId]: 0,
                    },
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                });

                // If there was an intro message, add it to messages
                if (after.message) {
                    await db
                        .collection('chat_messages')
                        .doc(chatRef.id)
                        .collection('messages')
                        .add({
                            chatId: chatRef.id,
                            senderId: after.fromUserId,
                            content: after.message,
                            isRead: false,
                            createdAt: admin.firestore.FieldValue.serverTimestamp(),
                        });
                }

                // Send notification to requester
                await sendNotificationToUser(after.fromUserId, {
                    title: 'Chat Request Approved',
                    body: 'Your chat request was approved. Start messaging!',
                    data: {
                        type: 'CHAT_REQUEST_APPROVED',
                        chatId: chatRef.id,
                    },
                });

                functions.logger.info('Chat request approved, chat created:', {
                    requestId,
                    chatId: chatRef.id,
                });
            } catch (error) {
                functions.logger.error('Error processing chat request approval:', error);
                throw error;
            }
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
