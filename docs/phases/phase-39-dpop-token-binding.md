# Phase 39 — DPoP Token Binding

**Status:** DONE — see the roadmap entry for what was verified and what could not be run here

## Feature
Every authenticated request on REST, gRPC and WebSocket carries a **DPoP proof** (RFC 9449), so a stolen access or refresh token is useless without the device's private key.

## Why it exists
A bearer token works for whoever holds it: a leaked log line, a proxy cache or an XSS read is a full account takeover until expiry. Jira and ClickUp ship plain bearer tokens. Binding each session to a key that never leaves the device closes that hole for free, with no extra step for the user.

## How it works (plain words)
On first launch the app creates a keypair (ES256). The private key is **non-extractable**: WebCrypto on web, Keychain/Keystore (Secure Enclave or StrongBox where present) on native. Sign-in sends a proof signed with that key; the server stores the key's thumbprint (`jkt`) on the session, puts it in the access token (`cnf.jkt`) and returns `token_type: DPoP`. From then on every call sends two headers: `Authorization: DPoP <access token>` and `DPoP: <proof>`. A proof is a tiny JWT signed per request that says *which method, which URL, when, a unique id, and a hash of the access token*. The server checks the signature, that the key matches the session, that the proof is fresh and has never been seen, and that it was made for this exact call. Refresh is bound the same way: a refresh token only works with a proof from the same key, so stealing it alone achieves nothing. Replaying a captured request fails (`jti` seen), and a captured token used from another machine fails (wrong key).

## Scope
**In:** key generation and storage per platform, proof creation in the REST, gRPC and WebSocket clients, server verification for all three transports, `cnf.jkt` token binding, bound refresh tokens, replay cache, optional server nonce, `DPOP_MODE` policy (`off | optional | required`), CORS and Envoy header allowance, error shapes, a "key changed" signal for the session list.
**Out:** device naming and fingerprint labels (phase 40), mutual TLS, API-token (phase 32) binding — API tokens stay bearer by design, hardware attestation of the key.

## Data model
- `Session` gains `dpop_jkt` (base64url SHA-256 thumbprint of the public JWK), nullable only while `DPOP_MODE != required`.
- Replay cache (Redis/cache, no table): key `dpop:{jkt}:{jti}`, TTL = freshness window + skew.
- Server nonce state: current and previous nonce in cache, rotated every 5 minutes.

## API surface
- Request headers on **every** authenticated route: `Authorization: DPoP <access>` and `DPoP: <proof>`.
- Proof JWT: header `typ=dpop+jwt`, `alg=ES256`, `jwk` (public key); claims `jti`, `htm`, `htu`, `iat`, `ath` (SHA-256 of the access token, required on resource calls, absent on sign-in), `nonce` (when the server asked for one).
- **htu** is built from the configured public origin (`DJANGO_PUBLIC_ORIGIN`) plus the path, never from the incoming `Host`, so proxies and Envoy cannot cause mismatches. REST: `htm` = the HTTP method, `htu` = origin + path (no query). gRPC and gRPC-Web: `htm = POST`, `htu` = origin + `/<package.Service>/<Method>`, proof in metadata `dpop`.
- WebSocket: browsers cannot set headers on the handshake, so the proof travels in the first message `{"type":"authenticate","token":…,"dpop":…}` with `htm=GET`, `htu` = the socket URL. The connection is bound to that key; a token refresh sends a new `authenticate`. Never in the URL.
- Responses: `DPoP-Nonce` header when the server issues or rotates a nonce; `401` with `WWW-Authenticate: DPoP error="use_dpop_nonce"` makes the client retry once with the new nonce.
- Errors: REST `401` with `WWW-Authenticate: DPoP error="invalid_dpop_proof"` (or `invalid_token`) and the standard envelope; gRPC `UNAUTHENTICATED`; WebSocket error frame.
- Sign-in, signup and refresh accept a proof without `ath` and bind the session to its key. Existing `token/sessions` responses add `dpop_bound: bool`.
- **Routes that stay without a proof:** `health/live`, `health/ready`, public docs, inbound webhooks and public intake-form submissions (phase 33) — nothing authenticated to bind. If an access token is present on any route, its proof is required.

## Flutter UI
No new screens. Key creation is lazy and silent. A "This device's key changed, please sign in again" message appears when the server answers `invalid_token` because the key is gone (cleared storage, new browser profile). The Sessions screen shows a lock badge on bound sessions. Web stores the non-extractable `CryptoKey` in IndexedDB; native stores a keypair via the platform keystore, falling back to `flutter_secure_storage` where hardware keys are unavailable.

## Rules and edge cases
- Accepted algorithms: `ES256` only. Reject `none`, symmetric algorithms and `jwk` containing a private part.
- Freshness: `iat` within ±60 seconds of server time (config); `jti` must be unique per key inside that window, even across workers (shared cache).
- `ath` must equal SHA-256 of the exact access token presented.
- A token bound to key A used with a proof from key B is `invalid_token`, and counts as a failed login signal for rate limiting (phase 01 limits).
- In `required` mode a plain bearer token is rejected on every route, including the ones the starter exposes (`users/me`, gRPC `Me`, sessions). In `optional` mode (dev default until clients ship) a bearer token works but is logged once per session.
- Nonce is on by default in production, off in tests. A nonce is single-purpose for DPoP; it never replaces the replay cache.
- Clock skew on a phone is the usual failure: the 401 for a stale `iat` includes the server's `Date`, and the client adjusts its offset and retries once.
- The proof is never logged and never put in a URL or query string; log only `jkt` prefix and `jti`.
- Limits to document: DPoP stops token theft and replay, not malicious script running inside the signed-in page (it can still ask the browser to sign). It does not replace TLS.
- Existing sessions issued before the phase are bearer-only; they are revoked when `required` is switched on (documented in the release notes, one forced sign-in).

## Acceptance criteria
- [x] Sign-in on web, Android and desktop binds the session; the same access token sent without a proof is rejected in `required` mode on REST, gRPC and WebSocket — web: real browser against the production stack (key in IndexedDB, gRPC-Web through Caddy and Envoy, no proof refused); macOS and iOS: key persisted in the real Keychain (`integration_test/dpop_keystore_test.dart`); REST, gRPC and WebSocket rejection of a proof-less token is in `test_dpop_transports.py`. Android's Keystore was not run (no emulator here)
- [x] A proof replayed (same `jti`) is rejected, including against a second worker (`test_two_workers_sharing_the_cache_cannot_both_spend_one_proof`)
- [x] A proof with the wrong method, URL, `ath`, key, algorithm or stale `iat` is rejected, each with a distinct internal reason (`test_each_wrong_claim_is_refused`, `test_header_failures`)
- [x] A stolen refresh token without the key cannot refresh; with the key it rotates and the new token stays bound (`test_refresh_requires_the_bound_key`)
- [x] The server nonce challenge works end to end and the client retries once (`test_nonce_missing_and_stale_and_valid`; the nonce is exposed to the browser as `x-error-nonce-bin`)
- [x] CORS and Envoy pass the `DPoP` header and expose `DPoP-Nonce`; web works through gRPC-Web (the web app runs through gRPC-Web in `required` mode, which needs both)
- [x] Health, docs and inbound webhooks still work with no proof (`test_proof_free_routes_still_work`; `/api/health/ready` and `/api/version` answered through Caddy)

## Tests
Proof verification matrix (each claim and header field wrong in turn), replay cache, nonce rotation, token binding and bound refresh, interceptor and Ninja auth class parity (same proof table over REST and gRPC), WebSocket authenticate, clock-skew retry in the app, key loss path, Flutter proof builder against fixed test vectors from RFC 9449.

## Notes for implementation
- Verify with a maintained JOSE library (`joserfc` or `PyJWT` with `cryptography`) and, on Dart, `jose`/`pointycastle` or WebCrypto through `dart:js_interop`; do not hand-roll signature code.
- One shared verifier in `infrastructure/auth/core/dpop.py` used by the Ninja auth class, the gRPC interceptor and the socket, per the "one services layer, thin adapters" rule.
- The starter's `auth_*` apps own token issuing; add `cnf.jkt` through its token-claims hook rather than forking it.

## Depends on
Phase 01.

## Fault found by running it

`GRPC_FRAMEWORK["SERVER_INTERCEPTORS"]` named the method-path interceptor by dotted path, but django-socio-grpc 0.25 imports only some settings from strings, so grpc received a string and refused to start the server. It is now the instance, with a test that every configured interceptor is a `grpc.aio.ServerInterceptor`.
