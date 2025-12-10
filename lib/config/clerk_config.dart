// Clerk configuration for auth integration.
class ClerkConfig {
  static const publishableKey = 'pk_test_c3VtbWFyeS1lZnQtMTkuY2xlcmsuYWNjb3VudHMuZGV2JA';
  static const frontendApiUrl = 'https://summary-eft-19.accounts.dev';
  // Do NOT put secret keys in the client; keep CLERK_SECRET_KEY on the server.

  // Force Google as the sign-in strategy for the hosted page.
  static String get defaultSignInUrl => '$frontendApiUrl/sign-in?strategy=oauth_google';
}
