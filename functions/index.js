const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
const crypto = require('crypto');

admin.initializeApp();

function hashPin(pin) {
    return crypto.createHash('sha256').update(String(pin)).digest('hex');
}

exports.loginWithPin = functions.https.onCall(async (data, context) => {
    const phone = data.phone;
    const pin = data.pin;

    if (!phone || !pin) {
        throw new functions.https.HttpsError('invalid-argument', 'Phone and PIN are required.');
    }

    const pinHash = hashPin(pin);

    try {
        const usersSnapshot = await admin.firestore().collection('users')
            .where('phone', '==', phone)
            .where('isActive', '==', true)
            .get();

        if (usersSnapshot.empty) {
            throw new functions.https.HttpsError('not-found', 'User not found or inactive.');
        }

        let matchedUser = null;
        let matchedUserId = null;

        for (const doc of usersSnapshot.docs) {
            const userData = doc.data();
            if (userData.pinHash === pinHash) {
                // Check if station is suspended
                if (userData.tenantId && userData.tenantId !== 'admin_station') {
                    const stationDoc = await admin.firestore().collection('stations').doc(userData.tenantId).get();
                    if (stationDoc.exists && stationDoc.data().licence === 'suspended') {
                        throw new functions.https.HttpsError('permission-denied', 'station_suspended');
                    }
                }
                matchedUser = userData;
                matchedUserId = doc.id;
                break;
            }
        }

        if (!matchedUser) {
            throw new functions.https.HttpsError('unauthenticated', 'Invalid PIN.');
        }

        // Create Custom Token
        const customClaims = {
            tenantId: matchedUser.tenantId || '',
            roles: matchedUser.roles || ['ouvrier']
        };

        const customToken = await admin.auth().createCustomToken(matchedUserId, customClaims);

        return { token: customToken };

    } catch (error) {
        console.error('Login error:', error);
        if (error instanceof functions.https.HttpsError) {
            throw error;
        }
        throw new functions.https.HttpsError('internal', 'An error occurred during login.');
    }
});
