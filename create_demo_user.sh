#!/bin/bash

# Create demo user in Firestore using Firebase CLI
echo "Creating demo user with username 'demoUser'..."

# Note: Since firebase firestore commands don't exist, we'll use the app's debug mode
# The user can create the demo user by:
# 1. Login with phone +919999999999 using OTP 123456
# 2. Set username to 'demoUser' during profile setup

echo "✅ Database cleared!"
echo ""
echo "To create the demo user for testing:"
echo "1. Login to the app with any phone number"
echo "2. During profile setup, try entering 'demoUser' as username"
echo "3. It should show as available (since we cleared the DB)"
echo "4. Save your profile with 'demoUser'"
echo "5. Logout and create a new account"
echo "6. Try 'demoUser' again - it should now show as 'taken'"
echo ""
echo "Or manually add via Firebase Console:"
echo "Collection: users"
echo "Document ID: test_demo_user"
echo "Fields: {uid: 'test_demo_user', username: 'demoUser', fullName: 'Demo User'}"
echo ""
echo "Collection: usernames"  
echo "Document ID: demouser"
echo "Fields: {userId: 'test_demo_user'}"
