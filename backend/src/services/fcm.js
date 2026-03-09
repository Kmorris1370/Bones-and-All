const admin = require('firebase-admin');
const serviceAccount = require('../../serviceAccountKey.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

/**
 * Send a push notification to a single device
 * @param {string} fcmToken - Device token stored in users table
 * @param {string} title
 * @param {string} body
 */
async function sendNotification(fcmToken, title, body) {
  const message = {
    notification: { title, body },
    token: fcmToken
  };
  try {
    const response = await admin.messaging().send(message);
    console.log('Notification sent:', response);
    return { success: true, response };
  } catch (err) {
    console.error('FCM error:', err);
    return { success: false, error: err };
  }
}

module.exports = { sendNotification };