# 🏋️ Gym App — API

**Stack:** Node.js · TypeScript · Express · Prisma 6 · PostgreSQL · Socket.io · Stripe · Cloudinary

---

## Quick Start (local, no Docker)

```bash
# 1. Create the Postgres database
createdb gymapp_db

# 2. Fill environment variables
cp .env.example .env

# 3. Generate Prisma client
npm run db:generate

# 4. Create database tables
npm run db:migrate

# 5. Seed super admin
npm run db:seed

# 6. Start dev server
npm run dev
```

`http://localhost:3000/api/v1`

---

## Architecture — Modular Monolith (Feature-based DDD)

```
src/
├── main.ts                      Entry point
├── routes.ts                    Central route registry
├── config/env.ts                Type-safe environment vars
├── infrastructure/
│   ├── database/prisma.ts       Prisma singleton client
│   ├── database/seed.ts         DB seeder
│   ├── logger/                  Winston
│   ├── storage/cloudinary.ts    Image/video uploads
│   ├── payment/stripe.ts        Stripe helpers
│   └── realtime/socket.ts       Socket.io event handlers
├── shared/
│   ├── errors/AppError.ts
│   ├── middleware/              errorHandler, rateLimiter, notFound
│   └── guards/auth.guard.ts     JWT authenticate + authorize
├── utils/apiResponse.ts
└── features/                   ← Business logic lives here
    ├── auth/                   register, login, refresh, logout
    ├── user/                   profile management
    ├── trainer/                trainer profile, clients, coaching
    ├── client/                 client profile
    ├── admin/                  platform management
    ├── workout/                workouts, assignments, sessions
    ├── exercise/               exercise library
    ├── nutrition/              meals, diet plans, food scan
    ├── biometrics/             weight, HR, BP, O2, stress, water, steps
    ├── run/                    GPS run sessions (real-time)
    ├── shop/                   products, cart, orders, Stripe checkout
    ├── chat/                   1-on-1 + group messaging
    └── notification/
```

Each feature:
```
<feature>/
  controller/   HTTP layer
  service/      Business logic
  repository/   Prisma queries only
  dto/          Zod validation schemas
  routes/       Express Router
```

---

## Roles

| Role | Can do |
|------|--------|
| `SUPER_ADMIN` | Manage everything |
| `TRAINER` | Create & assign workouts/diets, view client logs, chat |
| `CLIENT` | Log workouts/meals/biometrics, GPS run, shop, chat |
| `SELLER` | Manage own store, products, orders |

---

## Scripts

| Command | Action |
|---------|--------|
| `npm run dev` | Start with hot reload |
| `npm run build` | Compile TypeScript |
| `npm run db:generate` | Generate Prisma client |
| `npm run db:migrate` | Run migrations |
| `npm run db:seed` | Seed super admin |
| `npm run db:studio` | Open Prisma Studio |
| `npm test` | Run Jest |
