# Firebase Project Setup Instructions

## Quick Setup Steps

Since automatic project creation requires additional permissions, please create the Firebase project manually:

### 1. Create Firebase Project (5 minutes)

1. **Go to Firebase Console**: https://console.firebase.google.com
2. **Click "Add project"**
3. **Enter project details:**
   - Project name: `RiderMatch Production`
   - Project ID: `ridermatch-prod` (or use auto-generated)
   - Enable Google Analytics: ✅ Yes (recommended)
4. **Click "Create project"**
5. **Wait for project creation** (~30 seconds)

### 2. Enable Required Services (10 minutes)

**Authentication:**
- Go to **Build** → **Authentication** → **Get started**
- Click **Sign-in method** tab
- Enable **Phone** authentication
- Enable **Google** authentication
- Click **Save**

**Firestore Database:**
- Go to **Build** → **Firestore Database** → **Create database**
- Select **Production mode**
- Choose location: **asia-south1** (Mumbai) or **us-central1** (Iowa)
- Click **Enable**

**Storage:**
- Go to **Build** → **Storage** → **Get started**
- Click **Next** (use default security rules for now)
- Choose same location as Firestore
- Click **Done**

**Cloud Functions (IMPORTANT):**
- Go to **Build** → **Functions** → **Get started**
- **Upgrade to Blaze Plan** (pay-as-you-go)
  - Click **Upgrade project**
  - Add billing account
  - Set budget alert: $50/month recommended

### 3. Get Your Project ID

- Go to **Project Settings** (gear icon)
- Copy the **Project ID** (e.g., `ridermatch-prod-a1b2c`)

### 4. Share Project ID

Once you have the Project ID, share it in the chat and I'll proceed with deployment!

---

**Why manual setup?**
The Firebase API requires additional permissions for programmatic project creation. Manual setup via console is the standard approach and takes just 10-15 minutes.
