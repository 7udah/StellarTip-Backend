#!/bin/bash
# Create all 20 StellarTip backend GitHub issues
set -e

echo "Creating Issue 1/20: Stellar Wallet Signature Verification..."
gh issue create \
  --title "Implement Stellar Wallet Signature Verification" \
  --label "auth,blockchain,stellar,P0" \
  --body '> **Area:** Authentication
> **Priority:** P0 — Critical

## Description
The `StellarStrategy` (`src/auth/strategies/stellar.strategy.ts`) currently has a TODO placeholder for signature verification. The `verifyStellarSignature` method always returns `true`. Replace with proper cryptographic verification using `@stellar/stellar-sdk`.

## Acceptance Criteria
- [ ] Install `@stellar/stellar-sdk` and add to `package.json`
- [ ] Replace the TODO in `verifyStellarSignature` with proper `Keypair.fromPublicKey(address).verify()` logic
- [ ] The signed message from Freighter wallet is verified against the Stellar public key
- [ ] Invalid signatures return `false` and trigger `UnauthorizedException`
- [ ] Add unit tests for `verifyStellarSignature` with valid and invalid signatures
- [ ] All existing auth tests continue to pass'

echo "Creating Issue 2/20: Rate Limiting Middleware..."
gh issue create \
  --title "Add Rate Limiting Middleware to API Endpoints" \
  --label "auth,security,infrastructure,P0" \
  --body '> **Area:** API Security
> **Priority:** P0 — Critical

## Description
The API currently has no rate limiting, making it vulnerable to brute-force attacks on auth endpoints and DoS on tip creation endpoints. Implement global and per-endpoint rate limiting.

## Acceptance Criteria
- [ ] Install and configure `@nestjs/throttler` package
- [ ] Apply global rate limit: 100 requests per minute per IP
- [ ] Apply stricter limits on auth endpoints: 10 req/min per IP for `POST /auth/login` and `POST /auth/stellar/login`
- [ ] Moderate limits on tip creation: 30 req/min per IP for `POST /tips`
- [ ] Rate limit headers (`X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`) returned in responses
- [ ] Exceeded limits return `429 Too Many Requests`
- [ ] Rate limiting is configurable via environment variables
- [ ] Add unit tests for throttler configuration'

echo "Creating Issue 3/20: JWT Refresh Token..."
gh issue create \
  --title "Implement JWT Refresh Token Mechanism" \
  --label "auth,security,P1" \
  --body '> **Area:** Authentication
> **Priority:** P1 — High

## Description
JWT tokens currently expire after 7 days with no refresh mechanism. Users must re-authenticate when tokens expire. Implement a refresh token flow.

## Acceptance Criteria
- [ ] Add a `refresh_tokens` table/entity to store refresh tokens linked to users
- [ ] Add `POST /auth/refresh` endpoint that accepts a refresh token and returns a new access token + refresh token
- [ ] Access tokens expire in 15 minutes; refresh tokens expire in 30 days
- [ ] Refresh tokens are single-use (rotated on each refresh)
- [ ] Old refresh tokens are invalidated on password change
- [ ] Add unit tests for refresh token creation, rotation, and expiry
- [ ] Update API documentation in README'

echo "Creating Issue 4/20: Stellar Horizon SDK Integration..."
gh issue create \
  --title "Implement Stellar Horizon SDK Integration in StellarService" \
  --label "blockchain,stellar,P0" \
  --body '> **Area:** Stellar Module
> **Priority:** P0 — Critical

## Description
The `StellarService` (`src/stellar/stellar.service.ts`) is entirely stubbed with TODO placeholders. Integrate with the Stellar Horizon API using `@stellar/stellar-sdk`.

## Acceptance Criteria
- [ ] Install `@stellar/stellar-sdk` and add to `package.json`
- [ ] Initialize `Server` instance connected to the configured Horizon URL
- [ ] `getAccountBalance()` returns real XLM and USDC balances from the Stellar network
- [ ] `verifyPayment()` checks the transaction on Horizon, returns `from`, `to`, `amount`, `asset`
- [ ] `getAccountInfo()` returns account existence, sequence number, subentry count
- [ ] Network selection (TESTNET vs PUBLIC) driven by `STELLAR_NETWORK` env var
- [ ] Errors from Horizon are gracefully handled and logged
- [ ] Add unit tests with mocked Horizon responses'

echo "Creating Issue 5/20: USDC Tip Asset Support..."
gh issue create \
  --title "Add Support for USDC Tip Asset Alongside XLM" \
  --label "tips,blockchain,stellar,P1" \
  --body '> **Area:** Tips
> **Priority:** P1 — High

## Description
The TipAsset enum supports both XLM and USDC, but the service and validation do not properly differentiate between them. USDC tipping requires proper Stellar asset notation.

## Acceptance Criteria
- [ ] Validate USDC asset includes the issuer account address from config
- [ ] POST /tips rejects unsupported asset types with a clear error
- [ ] Add assetIssuer column to Tip entity (nullable for native XLM)
- [ ] Tip stats correctly groups by both asset type and issuer
- [ ] Update CreateTipDto with optional assetIssuer field
- [ ] Write a TypeORM migration for the new column
- [ ] Write unit tests for USDC tip creation flow'

echo "Creating Issue 6/20: Creator Tip Link Endpoint..."
gh issue create \
  --title "Implement Creator Tip Link / Public Profile Endpoint" \
  --label "profiles,tips,P1" \
  --body '> **Area:** Creator Experience
> **Priority:** P1 — High

## Description
The README mentions "tip links per creator (stellartip.com/{username})", but there\'s no dedicated endpoint that returns a creator\'s public tipping page data.

## Acceptance Criteria
- [ ] Add `GET /profiles/:username/tipping-info` endpoint
- [ ] Response includes: creator display name, bio, avatar, wallet address, total tips received, recent tip messages (last 5)
- [ ] Public endpoint — no auth required
- [ ] If creator has no wallet linked, return guidance instead of wallet address
- [ ] Cache response for 60 seconds
- [ ] Add unit tests for the new endpoint
- [ ] Update README with new endpoint documentation'

echo "Creating Issue 7/20: Tip Pagination, Filtering, Sorting..."
gh issue create \
  --title "Improve Tip Pagination, Filtering, and Sorting" \
  --label "tips,enhancement,P2" \
  --body '> **Area:** Tips
> **Priority:** P2 — Medium

## Description
Tip history endpoints support basic pagination but lack filtering by date range, asset type, amount range, and sorting.

## Acceptance Criteria
- [ ] Add query parameters: `startDate`, `endDate`, `asset`, `minAmount`, `maxAmount`, `sortBy`, `sortOrder`
- [ ] `sortBy` supports: `createdAt` (default), `amount`
- [ ] `sortOrder` supports: `ASC`, `DESC` (default)
- [ ] Date filters use ISO 8601 format; amount filters validated (> 0)
- [ ] Invalid filters return `400 Bad Request`
- [ ] Pagination metadata includes `hasNextPage` and `hasPreviousPage`
- [ ] Add unit tests for filtered queries
- [ ] Update README with new query parameters'

echo "Creating Issue 8/20: Tip Receipt / Notification System..."
gh issue create \
  --title "Implement Tip Receipt / Notification System" \
  --label "tips,notifications,P2" \
  --body '> **Area:** Notifications
> **Priority:** P2 — Medium

## Description
Creators have no way to know they received a tip unless they manually check the dashboard. Implement in-app + email notifications.

## Acceptance Criteria
- [ ] Create a `notifications` module with a `Notification` entity
- [ ] On tip completion, create an in-app notification for the creator
- [ ] Add `GET /notifications` (paginated, unread first)
- [ ] Add `PATCH /notifications/:id/read` to mark as read
- [ ] Add `GET /notifications/unread-count` for badge display
- [ ] If creator has email + opted in, send email notification with tip details
- [ ] Email sending uses mock transport in development
- [ ] Add unit tests for notification creation and read status
- [ ] Update README with new endpoints'

echo "Creating Issue 9/20: Avatar Upload Endpoint..."
gh issue create \
  --title "Add Avatar Upload Endpoint with Image Processing" \
  --label "profiles,media,P1" \
  --body '> **Area:** Profiles
> **Priority:** P1 — High

## Description
Creators can set an `avatarUrl` but there\'s no upload mechanism. Implement a file upload endpoint with validation and processing.

## Acceptance Criteria
- [ ] Add `POST /profiles/me/avatar` endpoint accepting multipart/form-data
- [ ] Supported formats: JPEG, PNG, WEBP; max 5MB
- [ ] Validate file is an image via magic bytes check
- [ ] Store files in `uploads/avatars/` with UUID filenames
- [ ] Resize images to max 400x400px, preserve aspect ratio
- [ ] Return the URL to the uploaded avatar
- [ ] Serve static files via `ServeStaticModule`
- [ ] Old avatar is deleted when a new one is uploaded
- [ ] Add unit tests for file validation and upload logic
- [ ] Update README with new endpoint'

echo "Creating Issue 10/20: Social Links on Profiles..."
gh issue create \
  --title "Add Social Links to Creator Profiles" \
  --label "profiles,enhancement,P3" \
  --body '> **Area:** Profiles
> **Priority:** P3 — Low

## Description
Creators should be able to link social media accounts (Twitter/X, GitHub, YouTube, Website) to their profile.

## Acceptance Criteria
- [ ] Add a `socialLinks` JSON column to the `User` entity
- [ ] Schema: `{ twitter?: string, github?: string, youtube?: string, website?: string }`
- [ ] Add `PATCH /profiles/me/social-links` endpoint
- [ ] Validate URLs are properly formatted (must start with https://)
- [ ] Social links returned in public profile responses
- [ ] Max 4 social links (one per platform)
- [ ] Write a TypeORM migration for the new column
- [ ] Add unit tests for social link update and validation'

echo "Creating Issue 11/20: Creator Analytics Dashboard..."
gh issue create \
  --title "Implement Creator Analytics Dashboard Endpoint" \
  --label "analytics,dashboard,P1" \
  --body '> **Area:** Analytics
> **Priority:** P1 — High

## Description
The current `GET /tips/my/stats` is minimal. Creators need rich analytics with time series data, top supporters, and trends.

## Acceptance Criteria
- [ ] Create `GET /profiles/me/analytics` endpoint
- [ ] Response includes: total tips, total XLM/USDC received, daily breakdown (last 30 days), top 5 supporters, average tip amount, largest single tip
- [ ] Time series data: `[{ date, count, totalAmount, asset }]`
- [ ] Supporters data: `[{ walletAddress, totalAmount, tipCount, lastTipAt }]`
- [ ] Data cached for 5 minutes
- [ ] Add unit tests for analytics computation
- [ ] Update README with new endpoint'

echo "Creating Issue 12/20: Health Check Endpoints..."
gh issue create \
  --title "Add Health Check and Readiness Endpoints" \
  --label "infrastructure,observability,P1" \
  --body '> **Area:** DevOps
> **Priority:** P1 — High

## Description
The API lacks health check endpoints needed for container orchestration and monitoring.

## Acceptance Criteria
- [ ] Add `GET /health` returning `{ status, timestamp, uptime, version }`
- [ ] Add `GET /health/ready` checking database connectivity (SELECT 1) and Stellar Horizon connectivity
- [ ] Unhealthy database returns `503 Service Unavailable`
- [ ] Create a `HealthModule`
- [ ] Health endpoints are NOT rate-limited
- [ ] Add unit tests for health check logic'

echo "Creating Issue 13/20: Docker and Docker Compose..."
gh issue create \
  --title "Set Up Docker and Docker Compose for Local Development" \
  --label "infrastructure,devops,docker,P0" \
  --body '> **Area:** DevOps
> **Priority:** P0 — Critical

## Description
No Docker setup exists. Developers must install PostgreSQL manually. Create Docker Compose configuration.

## Acceptance Criteria
- [ ] Create `Dockerfile` (multi-stage build) for the NestJS backend
- [ ] Create `docker-compose.yml` with `api` and `db` (PostgreSQL 16) services
- [ ] Add `.dockerignore` excluding `node_modules`, `dist`, `.env`
- [ ] Docker Compose uses `.env` file for configuration
- [ ] App hot-reloads in dev mode via volume mounts
- [ ] Document `docker compose up` in README
- [ ] `npm install` runs inside container on first build'

echo "Creating Issue 14/20: GitHub Actions CI/CD..."
gh issue create \
  --title "Configure GitHub Actions CI/CD Pipeline" \
  --label "infrastructure,devops,ci-cd,P1" \
  --body '> **Area:** DevOps
> **Priority:** P1 — High

## Description
No CI/CD pipeline exists. Every push should trigger linting, type checking, and unit tests.

## Acceptance Criteria
- [ ] Create `.github/workflows/ci.yml`
- [ ] Trigger on push to `main` and all PRs
- [ ] Jobs: Lint (`npm run lint`), TypeScript check (`npx tsc --noEmit`), Unit tests (`npm test`), Build (`npm run build`)
- [ ] Jobs run in parallel where possible
- [ ] Use Node.js 20 with PostgreSQL service container for e2e tests
- [ ] Add CI status badge to README
- [ ] Pipeline completes in under 5 minutes'

echo "Creating Issue 15/20: Structured Logging..."
gh issue create \
  --title "Set Up Structured JSON Logging" \
  --label "infrastructure,observability,P2" \
  --body '> **Area:** Logging
> **Priority:** P2 — Medium

## Description
App uses NestJS built-in Logger (plain text). For production debugging, structured JSON logging is essential.

## Acceptance Criteria
- [ ] Install and configure Winston or Pino as the logging provider
- [ ] Configure NestJS to use custom logger globally
- [ ] JSON log format: `{ timestamp, level, context, message, requestId, duration }`
- [ ] HTTP request logging middleware logs method, URL, status, response time
- [ ] Dev mode uses human-readable colorized output
- [ ] Production uses JSON format
- [ ] Sensitive data (passwords, tokens) are redacted from logs
- [ ] Add `requestId` to every log line via middleware'
echo "Creating Issue 16/20: AuthService Unit Tests..."
gh issue create \
  --title "Add Comprehensive Unit Tests for AuthService" \
  --label "testing,auth,P0" \
  --body '> **Area:** Quality
> **Priority:** P0 — Critical

## Description
The auth module has no dedicated unit tests for `AuthService`. Critical security logic must be tested.

## Acceptance Criteria
- [ ] Create `src/auth/auth.service.spec.ts`
- [ ] Test `validateStellarUser()`: new wallet creates user, existing returns user, invalid address throws
- [ ] Test `login()`: returns valid JWT with correct payload
- [ ] Test `signup()`: creates user, rejects duplicate email, rejects duplicate username
- [ ] Test `loginWithEmail()`: valid creds return token, invalid password throws, deactivated user throws
- [ ] Test `getNonce()`: returns nonce and message with correct wallet address
- [ ] Use `@nestjs/testing` with mocked `Repository` and `JwtService`
- [ ] Coverage target: >90% for AuthService'

echo "Creating Issue 17/20: TipsService Unit Tests..."
gh issue create \
  --title "Add Comprehensive Unit Tests for TipsService" \
  --label "testing,tips,P0" \
  --body '> **Area:** Quality
> **Priority:** P0 — Critical

## Description
The `TipsService` has no unit tests. Tip creation involves multiple entities and business rules.

## Acceptance Criteria
- [ ] Create `src/tips/tips.service.spec.ts`
- [ ] Test `createTip()`: creates with valid data, throws on unknown wallet, throws on zero amount
- [ ] Test `getTipById()`: returns tip, throws on missing
- [ ] Test `getTipsByCreator()`: paginates, returns in descending order
- [ ] Test `getTipsBySupporter()`: returns only from that supporter
- [ ] Test `getTipsByWallet()`: matches both sender and receiver wallets
- [ ] Test `confirmTip()`: updates status and tx hash
- [ ] Test `getTipStats()`: returns correct aggregation by asset
- [ ] Coverage target: >85% for TipsService'

echo "Creating Issue 18/20: ProfilesService Unit Tests..."
gh issue create \
  --title "Add Comprehensive Unit Tests for ProfilesService" \
  --label "testing,profiles,P1" \
  --body '> **Area:** Quality
> **Priority:** P1 — High

## Description
The `ProfilesService` has no unit tests.

## Acceptance Criteria
- [ ] Create `src/profiles/profiles.service.spec.ts`
- [ ] Test `getProfile()`: returns by username, throws on inactive/missing
- [ ] Test `getProfileById()`: returns by ID, throws on missing
- [ ] Test `updateProfile()`: updates allowed fields only
- [ ] Test `updateWalletAddress()`: links wallet, rejects duplicate on different user
- [ ] Test `searchProfiles()`: matches by username/displayName, limited to 20
- [ ] Verify sensitive fields (password, email) are not returned
- [ ] Coverage target: >85% for ProfilesService'

echo "Creating Issue 19/20: End-to-End Tests..."
gh issue create \
  --title "Add End-to-End Tests for All API Endpoints" \
  --label "testing,e2e,P1" \
  --body '> **Area:** Quality
> **Priority:** P1 — High

## Description
Only a basic smoke test exists. Add comprehensive E2E tests for all modules.

## Acceptance Criteria
- [ ] Create test files: `test/auth.e2e-spec.ts`, `test/profiles.e2e-spec.ts`, `test/tips.e2e-spec.ts`, `test/stellar.e2e-spec.ts`
- [ ] Use a test database (separate from development)
- [ ] Clean up test data after each test (rollback or truncation)
- [ ] Test auth: unauthenticated requests return 401 on protected routes
- [ ] Test validation: invalid bodies return 400
- [ ] Run with `npm run test:e2e`
- [ ] Update `test/jest-e2e.json` if needed'

echo "Creating Issue 20/20: ESLint Strict Rules..."
gh issue create \
  --title "Set Up ESLint Strict Rules and Fix Violations" \
  --label "quality,tooling,P3" \
  --body '> **Area:** Code Quality
> **Priority:** P3 — Low

## Description
ESLint config disables `no-explicit-any` and `no-unsafe-argument`. Enable stricter TypeScript rules.

## Acceptance Criteria
- [ ] Update `eslint.config.mjs`:
  - `@typescript-eslint/no-explicit-any`: error
  - `@typescript-eslint/no-unsafe-argument`: error
  - `@typescript-eslint/no-unused-vars`: error
  - `@typescript-eslint/explicit-function-return-type`: warn
  - `prettier/prettier`: error
- [ ] Run `npm run lint` and fix all errors
- [ ] Add `lint-staged` to run ESLint on staged files
- [ ] Document setup in CONTRIBUTING.md
- [ ] Verify `npm run lint` exits with code 0'

echo ""
echo "✅ All 20 issues created successfully!"
