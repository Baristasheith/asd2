/// ⚠️ PLACEHOLDER — replace with your real Stripe PUBLISHABLE key
/// (starts with `pk_test_` or `pk_live_`) from
/// https://dashboard.stripe.com/apikeys
///
/// This is safe to ship inside the app — it's the SECRET key that must
/// never appear here (that one only lives in the Cloud Function; see
/// `functions/index.js`).
class StripeConfig {
  StripeConfig._();

  static const publishableKey = 'pk_test_REPLACE_ME';

  static bool get isConfigured => !publishableKey.contains('REPLACE_ME');
}
