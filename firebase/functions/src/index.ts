import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Export all function modules
export * from './rides';
export * from './social';
export * from './chat';
export * from './notifications';
export * from './scheduled';
export * from './api';
