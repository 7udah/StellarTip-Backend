# StellarTip Backend API

The NestJS backend for [StellarTip](https://stellartip.com) — a decentralized micro-tipping platform for creators on the Stellar ecosystem.

## Overview

This API powers creator profiles, tip transactions, and Stellar blockchain interactions.

## Tech Stack

- **Runtime**: Node.js 18+
- **Framework**: NestJS (TypeScript)
- **Database**: PostgreSQL (via Neon)
- **ORM**: TypeORM
- **Auth**: JWT + Stellar wallet (Freighter)
- **Blockchain**: Stellar (via Horizon)

## Features

### Auth
- Stellar wallet (Freighter) authentication
- Email/password authentication with JWT
- Wallet nonce signing verification

### Profiles
- Creator profiles with username, display name, bio, and avatar
- Tip links per creator (stellartip.com/username)
- Profile search
- Wallet address linking

### Tips
- Instant tip recording (XLM/USDC)
- Tip history for creators and supporters
- Transaction verification
- Tip statistics and analytics

### Stellar
- Balance checking
- Transaction verification
- Account info lookup

## Project Structure

```
src/
├── auth/           # Authentication (JWT, Stellar wallet, guards)
├── config/         # Database and app configuration
├── entities/       # TypeORM entities (User, Tip)
├── profiles/       # Creator profile management
├── stellar/        # Stellar blockchain interaction
├── tips/           # Tip transactions and history
├── app.module.ts   # Root application module
└── main.ts         # Application entrypoint
```

## Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn
- PostgreSQL (local or Neon)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/stellartip-backend.git
cd stellartip-backend

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Start development server
npm run start:dev
```

### Scripts

| Command            | Description                        |
|--------------------|------------------------------------|
| `npm run dev`      | Start development server (watch)   |
| `npm run build`    | Build for production               |
| `npm run start`    | Start production server            |
| `npm run test`     | Run unit tests                     |
| `npm run test:e2e` | Run end-to-end tests               |
| `npm run lint`     | Lint and fix code                  |

## API Endpoints

### Auth
| Method | Path               | Description                  |
|--------|--------------------|------------------------------|
| POST   | `/auth/signup`     | Register with email/password |
| POST   | `/auth/login`      | Login with email/password    |
| POST   | `/auth/stellar/login` | Login with Stellar wallet  |
| GET    | `/auth/nonce`      | Get signing nonce for wallet |
| GET    | `/auth/profile`    | Get current user profile     |

### Profiles
| Method | Path                 | Description                |
|--------|----------------------|----------------------------|
| GET    | `/profiles/:username` | Get creator profile        |
| GET    | `/profiles?q=query`   | Search creators            |
| PUT    | `/profiles/me`        | Update own profile         |

### Tips
| Method | Path                      | Description              |
|--------|---------------------------|--------------------------|
| POST   | `/tips`                   | Create a new tip         |
| GET    | `/tips/:id`               | Get tip details          |
| GET    | `/tips/my/received`       | My received tips         |
| GET    | `/tips/my/sent`           | My sent tips             |
| GET    | `/tips/my/stats`          | My tip statistics        |
| GET    | `/tips/wallet/:address`   | Tips by wallet address   |
| POST   | `/tips/:id/confirm`       | Confirm a tip with tx    |

### Stellar
| Method | Path                        | Description                 |
|--------|-----------------------------|-----------------------------|
| GET    | `/stellar/balance`          | Get wallet balance          |
| GET    | `/stellar/account`          | Get account info            |
| POST   | `/stellar/verify-payment`   | Verify a transaction        |

## Environment Variables

| Variable             | Description                  | Default                        |
|----------------------|------------------------------|--------------------------------|
| `PORT`               | Server port                  | `3000`                         |
| `NODE_ENV`           | Environment                  | `development`                  |
| `DB_HOST`            | Database host                | `localhost`                    |
| `DB_PORT`            | Database port                | `5432`                         |
| `DB_USERNAME`        | Database username            | `postgres`                     |
| `DB_PASSWORD`        | Database password            | `postgres`                     |
| `DB_NAME`            | Database name                | `stellartip`                   |
| `JWT_SECRET`         | JWT signing secret           | —                              |
| `STELLAR_NODE_URL`   | Stellar Horizon URL          | `https://horizon-testnet.stellar.org` |
| `STELLAR_NETWORK`    | Stellar network              | `TESTNET`                      |

## License

MIT
