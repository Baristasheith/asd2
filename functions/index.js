/**
 * Ahmad Rest & Cafe — Cloud Functions
 *
 * Two pieces of server-side logic that must never live in the Flutter
 * app itself:
 *
 *   1. sendOrderStatusNotification — pushes a notification to the
 *      customer's phone the moment an order's `status` field changes
 *      (e.g. an admin/kitchen system marks it "onTheWay"). Requires a
 *      server because only trusted backend code should be allowed to
 *      send pushes to arbitrary users — the app's Firestore rules
 *      already forbid the client from doing this itself.
 *
 *   2. createPaymentIntent — creates a Stripe PaymentIntent using the
 *      SECRET key. The secret key must never ship inside the Flutter
 *      app (anyone could decompile it and charge cards on your
 *      account), so the app calls this callable function instead and
 *      only ever sees the publishable key + the client_secret this
 *      function returns.
 *
 * Deploy with:
 *   cd functions && npm install
 *   firebase deploy --only functions
 *
 * Configure the Stripe secret key (never commit it):
 *   firebase functions:secrets:set STRIPE_SECRET_KEY
 */

const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");

initializeApp();
const db = getFirestore();

const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY");

// ---------------------------------------------------------------------
// 1) Push notification when an order's status changes
// ---------------------------------------------------------------------
exports.sendOrderStatusNotification = onDocumentUpdated(
  "users/{userId}/orders/{orderId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.status === after.status) return; // no status change, nothing to send

    const userId = event.params.userId;
    const userDoc = await db.collection("users").doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken) return; // user never registered a device, or notifications denied

    const statusLabels = {
      preparing: "is being prepared",
      onTheWay: "is on the way",
      delivered: "has been delivered",
      cancelled: "was cancelled",
    };
    const label = statusLabels[after.status] || after.status;

    await getMessaging().send({
      token: fcmToken,
      notification: {
        title: "Ahmad Rest & Cafe",
        body: `Your order #${event.params.orderId.slice(-5)} ${label}.`,
      },
      data: {
        orderId: event.params.orderId,
        type: "order_status",
      },
    });
  }
);

// ---------------------------------------------------------------------
// 2) Stripe PaymentIntent creation (callable from the Flutter app)
// ---------------------------------------------------------------------
exports.createPaymentIntent = onCall(
  { secrets: [STRIPE_SECRET_KEY] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }

    const amount = request.data?.amount; // integer, smallest currency unit (e.g. cents)
    const currency = request.data?.currency || "usd";

    if (!Number.isInteger(amount) || amount <= 0) {
      throw new HttpsError("invalid-argument", "amount must be a positive integer (in cents).");
    }

    const stripe = require("stripe")(STRIPE_SECRET_KEY.value());

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      metadata: { uid: request.auth.uid },
      automatic_payment_methods: { enabled: true },
    });

    return { clientSecret: paymentIntent.client_secret };
  }
);
