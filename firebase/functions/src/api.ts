import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import express, { Request, Response } from 'express';
import cors from 'cors';

const db = admin.firestore();
const app = express();

// Enable CORS
app.use(cors({ origin: true }));
app.use(express.json());

/**
 * GET /api/rides/nearby
 * Get nearby rides based on user location
 */
app.get('/rides/nearby', async (req, res) => {
    try {
        const { lat, lng, limit = 20 } = req.query;

        if (!lat || !lng) {
            return res.status(400).json({ error: 'lat and lng are required' });
        }

        // Simple proximity query (in production, use GeoFirestore)
        const ridesSnapshot = await db
            .collection('rides')
            .where('status', '==', 'UPCOMING')
            .where('isPublic', '==', true)
            .orderBy('startDate', 'asc')
            .limit(Number(limit))
            .get();

        const rides = ridesSnapshot.docs.map((doc) => ({
            id: doc.id,
            ...doc.data(),
        }));

        res.json({ rides });
    } catch (error) {
        functions.logger.error('Error getting nearby rides:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * GET /api/rides/user/:uid
 * Get rides for a specific user
 */
app.get('/rides/user/:uid', async (req: Request, res: Response) => {
    try {
        const { uid } = req.params;
        const { type } = req.query; // 'CREATED' | 'JOINED' | 'COMPLETED'

        let query = db
            .collection('user_rides')
            .doc(uid)
            .collection('rides')
            .orderBy('createdAt', 'desc');

        if (type) {
            query = query.where('type', '==', type);
        }

        const userRidesSnapshot = await query.get();
        const rideIds = userRidesSnapshot.docs.map((doc) => doc.data().rideId);

        if (rideIds.length === 0) {
            return res.json({ rides: [] });
        }

        // Fetch full ride details
        const ridePromises = rideIds.map((rideId) =>
            db.collection('rides').doc(rideId).get()
        );
        const rideDocs = await Promise.all(ridePromises);

        const rides = rideDocs
            .filter((doc) => doc.exists)
            .map((doc) => ({
                id: doc.id,
                ...doc.data(),
            }));

        res.json({ rides });
    } catch (error) {
        functions.logger.error('Error getting user rides:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * POST /api/rides/create
 * Create a new ride
 */
app.post('/rides/create', async (req: Request, res: Response) => {
    try {
        const rideData = req.body;

        // Validate required fields
        if (
            !rideData.createdBy ||
            !rideData.rideName ||
            !rideData.fromLocation ||
            !rideData.toLocation
        ) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        // Create ride document
        const rideRef = db.collection('rides').doc();

        await rideRef.set({
            rideId: rideRef.id,
            ...rideData,
            currentParticipants: 1, // Creator is first participant
            status: 'UPCOMING',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Add creator as manager in ride_members
        await db
            .collection('ride_members')
            .doc(rideRef.id)
            .collection('members')
            .doc(rideData.createdBy)
            .set({
                uid: rideData.createdBy,
                joinedAt: admin.firestore.FieldValue.serverTimestamp(),
                status: 'APPROVED',
                role: 'MANAGER',
            });

        res.json({ rideId: rideRef.id, message: 'Ride created successfully' });
    } catch (error) {
        functions.logger.error('Error creating ride:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * POST /api/rides/join
 * Request to join a ride
 */
app.post('/rides/join', async (req: Request, res: Response) => {
    try {
        const { rideId, uid } = req.body;

        if (!rideId || !uid) {
            return res.status(400).json({ error: 'rideId and uid are required' });
        }

        // Check if already a member
        const existingMember = await db
            .collection('ride_members')
            .doc(rideId)
            .collection('members')
            .doc(uid)
            .get();

        if (existingMember.exists) {
            return res.status(400).json({ error: 'Already requested or joined' });
        }

        // Add join request
        await db
            .collection('ride_members')
            .doc(rideId)
            .collection('members')
            .doc(uid)
            .set({
                uid,
                joinedAt: admin.firestore.FieldValue.serverTimestamp(),
                status: 'PENDING',
                role: 'MEMBER',
            });

        res.json({ message: 'Join request sent successfully' });
    } catch (error) {
        functions.logger.error('Error joining ride:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * POST /api/rides/approve
 * Approve a ride join request
 */
app.post('/rides/approve', async (req: Request, res: Response) => {
    try {
        const { rideId, uid, approverId } = req.body;

        if (!rideId || !uid || !approverId) {
            return res
                .status(400)
                .json({ error: 'rideId, uid, and approverId are required' });
        }

        // Verify approver is the ride manager
        const rideDoc = await db.collection('rides').doc(rideId).get();
        if (!rideDoc.exists) {
            return res.status(404).json({ error: 'Ride not found' });
        }

        const ride = rideDoc.data()!;
        if (ride.createdBy !== approverId) {
            return res.status(403).json({ error: 'Only ride creator can approve' });
        }

        // Update member status
        await db
            .collection('ride_members')
            .doc(rideId)
            .collection('members')
            .doc(uid)
            .update({
                status: 'APPROVED',
            });

        res.json({ message: 'Member approved successfully' });
    } catch (error) {
        functions.logger.error('Error approving member:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Export the Express app as a Cloud Function
export const api = functions.https.onRequest(app);
