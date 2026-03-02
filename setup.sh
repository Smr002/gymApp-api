#!/bin/bash

# ============================================================
#  GYM APP — API Setup Script  (CORRECTED v2)
#  Stack: Node.js + TypeScript + Express + Prisma 6 + PostgreSQL
#  Architecture: Modular Monolith — Feature-based DDD +
#                Repository Pattern + Service Layer
#  Fixes applied:
#    [1] Prisma 6 — PrismaClient imported from generated output path
#        (schema has: output = "../src/generated/prisma")
#    [2] Zod v4 — error.issues  (NOT error.errors)
#    [3] Stripe — no manual apiVersion; SDK v12+ auto-uses its own
#    [4] tsconfig — ignoreDeprecations: "5.0" silences baseUrl warning
#    [5] No Docker — local dev only
# ============================================================

echo "🏋️  Creating Gym App API..."

mkdir -p gym-api && cd gym-api

# ─────────────────────────────────────────
# 1.  INIT
# ─────────────────────────────────────────
npm init -y

# ─────────────────────────────────────────
# 2.  RUNTIME DEPENDENCIES
# ─────────────────────────────────────────
npm install \
  express \
  cors \
  helmet \
  morgan \
  dotenv \
  bcryptjs \
  jsonwebtoken \
  passport \
  passport-jwt \
  passport-google-oauth20 \
  @prisma/client \
  cloudinary \
  multer \
  stripe \
  socket.io \
  zod \
  express-async-errors \
  http-status-codes \
  winston \
  express-rate-limit \
  cookie-parser \
  uuid \
  tsconfig-paths

# ─────────────────────────────────────────
# 3.  DEV DEPENDENCIES
# ─────────────────────────────────────────
npm install -D \
  typescript \
  ts-node \
  ts-node-dev \
  @types/express \
  @types/cors \
  @types/morgan \
  @types/bcryptjs \
  @types/jsonwebtoken \
  @types/passport \
  @types/passport-jwt \
  @types/passport-google-oauth20 \
  @types/multer \
  @types/cookie-parser \
  @types/uuid \
  @types/node \
  prisma \
  eslint \
  @typescript-eslint/parser \
  @typescript-eslint/eslint-plugin \
  prettier \
  eslint-config-prettier \
  eslint-plugin-prettier \
  jest \
  @types/jest \
  ts-jest \
  supertest \
  @types/supertest

# ─────────────────────────────────────────
# 4.  PRISMA INIT
# ─────────────────────────────────────────
npx prisma init

# ─────────────────────────────────────────
# 5.  FOLDER STRUCTURE
# ─────────────────────────────────────────
mkdir -p src/{config,shared,infrastructure,utils,types}
mkdir -p src/shared/{errors,middleware,guards,validators}
mkdir -p src/infrastructure/{database,storage,payment,realtime,logger}

# Feature modules — self-contained DDD domains
for module in auth user trainer client admin workout exercise nutrition biometrics chat run notification shop; do
  mkdir -p src/features/$module/{controller,service,repository,dto,routes}
done

mkdir -p tests/{unit,integration,e2e}
mkdir -p logs

# ─────────────────────────────────────────
# 6.  CONFIG FILES
# ─────────────────────────────────────────

# ── tsconfig.json ──
# FIX [4]: ignoreDeprecations silences "baseUrl is deprecated" in TS 5.x
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2021",
    "module": "commonjs",
    "lib": ["ES2021"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "sourceMap": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "ignoreDeprecations": "5.0",
    "baseUrl": ".",
    "paths": {
      "@features/*": ["src/features/*"],
      "@shared/*":   ["src/shared/*"],
      "@infra/*":    ["src/infrastructure/*"],
      "@config/*":   ["src/config/*"],
      "@utils/*":    ["src/utils/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
EOF

# ── .env ──
cat > .env << 'EOF'
# App
NODE_ENV=development
PORT=3000
API_PREFIX=/api/v1

# Database (local PostgreSQL — run: createdb gymapp_db)
DATABASE_URL="postgresql://postgres:password@localhost:5432/gymapp_db"

# JWT
JWT_SECRET=change_me_super_secret_jwt_key
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=change_me_refresh_secret
JWT_REFRESH_EXPIRES_IN=7d

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_CALLBACK_URL=http://localhost:3000/api/v1/auth/google/callback

# Cloudinary (free tier — cheapest + secure for media)
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Stripe
# FIX [3]: stripe-node v12+ does NOT need apiVersion in code.
# It auto-uses the version baked in at SDK release time.
STRIPE_SECRET_KEY=sk_test_your_stripe_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# CORS
CORS_ORIGIN=http://localhost:8081

# Food scanning
OPENFOODFACTS_BASE=https://world.openfoodfacts.org/api/v0
EOF

cp .env .env.example

# ── .gitignore ──
cat > .gitignore << 'EOF'
node_modules/
dist/
.env
*.log
logs/
coverage/
src/generated/
.DS_Store
EOF

# ── .prettierrc ──
cat > .prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "all",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2
}
EOF

# ── .eslintrc.json ──
cat > .eslintrc.json << 'EOF'
{
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint", "prettier"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier"
  ],
  "rules": {
    "prettier/prettier": "error",
    "@typescript-eslint/no-unused-vars": ["warn"],
    "@typescript-eslint/no-explicit-any": "warn"
  }
}
EOF

# ── jest.config.ts ──
cat > jest.config.ts << 'EOF'
import type { Config } from 'jest';
const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  moduleNameMapper: {
    '^@features/(.*)$': '<rootDir>/src/features/$1',
    '^@shared/(.*)$':   '<rootDir>/src/shared/$1',
    '^@infra/(.*)$':    '<rootDir>/src/infrastructure/$1',
    '^@config/(.*)$':   '<rootDir>/src/config/$1',
    '^@utils/(.*)$':    '<rootDir>/src/utils/$1',
  },
  collectCoverageFrom: ['src/**/*.ts'],
  coverageDirectory: 'coverage',
};
export default config;
EOF

# ── package.json scripts ──
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json'));
pkg.scripts = {
  'dev':           'ts-node-dev --respawn --transpile-only -r tsconfig-paths/register src/main.ts',
  'build':         'tsc -p tsconfig.json',
  'start':         'node -r tsconfig-paths/register dist/main.js',
  'lint':          'eslint src --ext .ts',
  'format':        'prettier --write \"src/**/*.ts\"',
  'test':          'jest',
  'test:watch':    'jest --watch',
  'test:coverage': 'jest --coverage',
  'db:migrate':    'npx prisma migrate dev',
  'db:generate':   'npx prisma generate',
  'db:seed':       'ts-node -r tsconfig-paths/register src/infrastructure/database/seed.ts',
  'db:studio':     'npx prisma studio',
  'db:reset':      'npx prisma migrate reset --force'
};
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
"

# ─────────────────────────────────────────
# 7.  PRISMA SCHEMA  (complete + corrected)
# FIX [1]: generator has output = "../src/generated/prisma"
#           so PrismaClient is imported from that path, not @prisma/client
# ─────────────────────────────────────────
cat > prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
  output   = "../src/generated/prisma"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ============================================================
// AUTH & USERS
// ============================================================

model User {
  id            String    @id @default(uuid())
  email         String    @unique
  password      String?
  googleId      String?   @unique
  role          Role      @default(CLIENT)
  isActive      Boolean   @default(true)
  isVerified    Boolean   @default(false)
  firstName     String
  lastName      String
  avatarUrl     String?
  gender        Gender?
  dateOfBirth   DateTime?
  height        Float?
  weight        Float?
  goal          Goal?
  activityLevel ActivityLevel?
  notificationsEnabled Boolean @default(true)

  refreshTokens      RefreshToken[]
  trainerProfile     TrainerProfile?
  clientProfile      ClientProfile?
  sellerProfile      SellerProfile?
  weightLogs         WeightLog[]
  heartRateLogs      HeartRateLog[]
  bloodPressureLogs  BloodPressureLog[]
  oxygenLogs         BloodOxygenLog[]
  stressLogs         StressLog[]
  waterLogs          WaterLog[]
  stepLogs           StepLog[]
  runSessions        RunSession[]
  workoutSessions    WorkoutSession[]
  workoutSchedules   ScheduledWorkout[]
  mealLogs           MealLog[]
  foodScanLogs       FoodScanLog[]
  sentMessages       Message[]      @relation("SentMessages")
  chatMemberships    ChatMember[]
  notifications      Notification[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model RefreshToken {
  id        String   @id @default(uuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  token     String   @unique
  expiresAt DateTime
  createdAt DateTime @default(now())
}

// ============================================================
// ROLE PROFILES
// ============================================================

model TrainerProfile {
  id          String   @id @default(uuid())
  userId      String   @unique
  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  bio         String?
  specialties String[]
  experience  Int?
  rating      Float    @default(0)
  isVerified  Boolean  @default(false)
  hourlyRate  Float?

  clients          ClientProfile[]     @relation("TrainerClients")
  coachingPlans    CoachingPlan[]
  createdWorkouts  Workout[]
  createdDietPlans DietPlan[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model ClientProfile {
  id           String          @id @default(uuid())
  userId       String          @unique
  user         User            @relation(fields: [userId], references: [id], onDelete: Cascade)
  trainerId    String?
  trainer      TrainerProfile? @relation("TrainerClients", fields: [trainerId], references: [id])
  fitnessLevel FitnessLevel    @default(BEGINNER)
  medicalNotes String?

  coachingSubscription CoachingSubscription?
  assignedWorkouts     WorkoutAssignment[]
  assignedDietPlans    DietPlanAssignment[]
  orders               Order[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model SellerProfile {
  id              String   @id @default(uuid())
  userId          String   @unique
  user            User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  storeName       String
  storeSlug       String   @unique
  description     String?
  logoUrl         String?
  bannerUrl       String?
  isVerified      Boolean  @default(false)
  rating          Float    @default(0)
  stripeAccountId String?

  products   Product[]
  orderItems OrderItem[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

// ============================================================
// COACHING
// ============================================================

model CoachingPlan {
  id            String         @id @default(uuid())
  trainerId     String
  trainer       TrainerProfile @relation(fields: [trainerId], references: [id], onDelete: Cascade)
  name          String
  description   String?
  price         Float
  durationWeeks Int
  features      String[]
  isActive      Boolean        @default(true)

  subscriptions CoachingSubscription[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model CoachingSubscription {
  id          String             @id @default(uuid())
  clientId    String             @unique
  client      ClientProfile      @relation(fields: [clientId], references: [id], onDelete: Cascade)
  planId      String
  plan        CoachingPlan       @relation(fields: [planId], references: [id])
  status      SubscriptionStatus @default(PENDING)
  startDate   DateTime?
  endDate     DateTime?
  stripeSubId String?
  paymentMode PaymentMode        @default(STRIPE)

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

// ============================================================
// BIOMETRICS
// ============================================================

model WeightLog {
  id     String   @id @default(uuid())
  userId String
  user   User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  value  Float
  date   DateTime @default(now())
}

model HeartRateLog {
  id     String   @id @default(uuid())
  userId String
  user   User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  bpm    Int
  date   DateTime @default(now())
}

model BloodPressureLog {
  id        String   @id @default(uuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  systolic  Int
  diastolic Int
  date      DateTime @default(now())
}

model BloodOxygenLog {
  id         String   @id @default(uuid())
  userId     String
  user       User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  percentage Int
  date       DateTime @default(now())
}

model StressLog {
  id     String   @id @default(uuid())
  userId String
  user   User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  level  Int
  status String?
  date   DateTime @default(now())
}

model WaterLog {
  id     String   @id @default(uuid())
  userId String
  user   User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  amount Int
  date   DateTime @default(now())
}

model StepLog {
  id     String   @id @default(uuid())
  userId String
  user   User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  count  Int
  date   DateTime @default(now())
}

// ============================================================
// RUN / GPS  (real-time, like Strava)
// ============================================================

model RunSession {
  id           String        @id @default(uuid())
  userId       String
  user         User          @relation(fields: [userId], references: [id], onDelete: Cascade)
  startTime    DateTime
  endTime      DateTime?
  distanceKm   Float?
  durationSecs Int?
  avgSpeedKmh  Float?
  calories     Int?
  status       SessionStatus @default(IN_PROGRESS)
  isPublic     Boolean       @default(false)

  routePoints RunRoutePoint[]

  createdAt DateTime @default(now())
}

model RunRoutePoint {
  id           String     @id @default(uuid())
  runSessionId String
  runSession   RunSession @relation(fields: [runSessionId], references: [id], onDelete: Cascade)
  latitude     Float
  longitude    Float
  altitude     Float?
  timestamp    DateTime
  order        Int
}

// ============================================================
// WORKOUTS
// ============================================================

model Workout {
  id           String          @id @default(uuid())
  title        String
  description  String?
  caloriesBurn Int?
  duration     Int?
  difficulty   Difficulty      @default(MEDIUM)
  imageUrl     String?
  isPublic     Boolean         @default(false)
  createdById  String?
  createdBy    TrainerProfile? @relation(fields: [createdById], references: [id])

  exercises   WorkoutExercise[]
  sessions    WorkoutSession[]
  schedules   ScheduledWorkout[]
  assignments WorkoutAssignment[]
  tags        WorkoutTag[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model WorkoutTag {
  id        String  @id @default(uuid())
  workoutId String
  workout   Workout @relation(fields: [workoutId], references: [id], onDelete: Cascade)
  tag       String
}

model Exercise {
  id                 String       @id @default(uuid())
  title              String
  description        String?
  imageUrl           String?
  videoUrl           String?
  caloriesBurnPerMin Float?
  muscleGroup        MuscleGroup?
  equipmentRequired  String[]

  instructions InstructionStep[]
  workouts     WorkoutExercise[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model WorkoutExercise {
  id         String   @id @default(uuid())
  workoutId  String
  workout    Workout  @relation(fields: [workoutId], references: [id], onDelete: Cascade)
  exerciseId String
  exercise   Exercise @relation(fields: [exerciseId], references: [id])
  order      Int
  sets       Int?
  reps       String?
  duration   Int?
  restTime   Int?
}

model InstructionStep {
  id         String   @id @default(uuid())
  exerciseId String
  exercise   Exercise @relation(fields: [exerciseId], references: [id], onDelete: Cascade)
  stepNumber Int
  title      String?
  content    String
  imageUrl   String?
}

model WorkoutAssignment {
  id         String        @id @default(uuid())
  clientId   String
  client     ClientProfile @relation(fields: [clientId], references: [id], onDelete: Cascade)
  workoutId  String
  workout    Workout       @relation(fields: [workoutId], references: [id])
  assignedAt DateTime      @default(now())
  note       String?
}

model WorkoutSession {
  id        String        @id @default(uuid())
  userId    String
  user      User          @relation(fields: [userId], references: [id], onDelete: Cascade)
  workoutId String
  workout   Workout       @relation(fields: [workoutId], references: [id])
  startTime DateTime
  endTime   DateTime?
  duration  Int?
  calories  Int?
  status    SessionStatus @default(IN_PROGRESS)

  exerciseLogs ExerciseLog[]

  createdAt DateTime @default(now())
}

model ExerciseLog {
  id               String         @id @default(uuid())
  workoutSessionId String
  workoutSession   WorkoutSession @relation(fields: [workoutSessionId], references: [id], onDelete: Cascade)
  exerciseId       String
  setNumber        Int
  repsCompleted    Int?
  weightKg         Float?
  durationSecs     Int?
  notes            String?
}

model ScheduledWorkout {
  id            String   @id @default(uuid())
  userId        String
  user          User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  workoutId     String
  workout       Workout  @relation(fields: [workoutId], references: [id])
  scheduledDate DateTime
  isCompleted   Boolean  @default(false)
  createdAt     DateTime @default(now())
}

// ============================================================
// NUTRITION
// ============================================================

model Meal {
  id          String       @id @default(uuid())
  name        String
  description String?
  category    MealCategory
  calories    Int
  fats        Float?
  proteins    Float?
  carbs       Float?
  fiber       Float?
  imageUrl    String?
  isPublic    Boolean      @default(true)

  ingredients   MealIngredient[]
  steps         RecipeStep[]
  logs          MealLog[]
  dietPlanMeals DietPlanMeal[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Ingredient {
  id       String  @id @default(uuid())
  name     String
  imageUrl String?
  calories Float?
  proteins Float?
  carbs    Float?
  fats     Float?
  per100g  Boolean @default(true)

  meals MealIngredient[]
}

model MealIngredient {
  id           String     @id @default(uuid())
  mealId       String
  meal         Meal       @relation(fields: [mealId], references: [id], onDelete: Cascade)
  ingredientId String
  ingredient   Ingredient @relation(fields: [ingredientId], references: [id])
  amount       String
}

model RecipeStep {
  id          String  @id @default(uuid())
  mealId      String
  meal        Meal    @relation(fields: [mealId], references: [id], onDelete: Cascade)
  stepNumber  Int
  instruction String
  imageUrl    String?
}

model MealLog {
  id                String       @id @default(uuid())
  userId            String
  user              User         @relation(fields: [userId], references: [id], onDelete: Cascade)
  mealId            String
  meal              Meal         @relation(fields: [mealId], references: [id])
  eatenAt           DateTime     @default(now())
  mealType          MealCategory
  portionMultiplier Float        @default(1)
}

model FoodScanLog {
  id          String     @id @default(uuid())
  userId      String
  user        User       @relation(fields: [userId], references: [id], onDelete: Cascade)
  barcode     String?
  imageUrl    String?
  productName String?
  calories    Float?
  proteins    Float?
  carbs       Float?
  fats        Float?
  rawData     Json?
  scanMethod  ScanMethod
  scannedAt   DateTime   @default(now())
}

// ============================================================
// DIET PLANS
// ============================================================

model DietPlan {
  id            String         @id @default(uuid())
  trainerId     String
  trainer       TrainerProfile @relation(fields: [trainerId], references: [id], onDelete: Cascade)
  title         String
  description   String?
  goal          Goal?
  durationWeeks Int?
  isPublic      Boolean        @default(false)

  meals       DietPlanMeal[]
  assignments DietPlanAssignment[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model DietPlanMeal {
  id         String       @id @default(uuid())
  dietPlanId String
  dietPlan   DietPlan     @relation(fields: [dietPlanId], references: [id], onDelete: Cascade)
  mealId     String
  meal       Meal         @relation(fields: [mealId], references: [id])
  dayNumber  Int
  mealType   MealCategory
  note       String?
}

model DietPlanAssignment {
  id         String        @id @default(uuid())
  clientId   String
  client     ClientProfile @relation(fields: [clientId], references: [id], onDelete: Cascade)
  dietPlanId String
  dietPlan   DietPlan      @relation(fields: [dietPlanId], references: [id])
  assignedAt DateTime      @default(now())
  note       String?
}

// ============================================================
// SHOP / E-COMMERCE
// ============================================================

model Product {
  id          String          @id @default(uuid())
  sellerId    String
  seller      SellerProfile   @relation(fields: [sellerId], references: [id], onDelete: Cascade)
  name        String
  description String?
  price       Float
  stock       Int             @default(0)
  category    ProductCategory
  imageUrls   String[]
  isActive    Boolean         @default(true)
  rating      Float           @default(0)

  orderItems OrderItem[]
  reviews    ProductReview[]
  cartItems  CartItem[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model ProductReview {
  id        String   @id @default(uuid())
  productId String
  product   Product  @relation(fields: [productId], references: [id], onDelete: Cascade)
  userId    String
  rating    Int
  comment   String?
  createdAt DateTime @default(now())
}

model Cart {
  id     String     @id @default(uuid())
  userId String     @unique
  items  CartItem[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model CartItem {
  id        String  @id @default(uuid())
  cartId    String
  cart      Cart    @relation(fields: [cartId], references: [id], onDelete: Cascade)
  productId String
  product   Product @relation(fields: [productId], references: [id])
  quantity  Int     @default(1)
}

model Order {
  id              String        @id @default(uuid())
  clientId        String
  client          ClientProfile @relation(fields: [clientId], references: [id])
  status          OrderStatus   @default(PENDING)
  totalAmount     Float
  stripePaymentId String?
  shippingAddress Json?

  items OrderItem[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model OrderItem {
  id        String        @id @default(uuid())
  orderId   String
  order     Order         @relation(fields: [orderId], references: [id], onDelete: Cascade)
  productId String
  product   Product       @relation(fields: [productId], references: [id])
  sellerId  String
  seller    SellerProfile @relation(fields: [sellerId], references: [id])
  quantity  Int
  unitPrice Float
}

// ============================================================
// CHAT / MESSAGING
// ============================================================

model Chat {
  id       String     @id @default(uuid())
  type     ChatType   @default(DIRECT)
  name     String?
  imageUrl String?

  members  ChatMember[]
  messages Message[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model ChatMember {
  id       String         @id @default(uuid())
  chatId   String
  chat     Chat           @relation(fields: [chatId], references: [id], onDelete: Cascade)
  userId   String
  user     User           @relation(fields: [userId], references: [id], onDelete: Cascade)
  role     ChatMemberRole @default(MEMBER)
  joinedAt DateTime       @default(now())

  @@unique([chatId, userId])
}

model Message {
  id        String     @id @default(uuid())
  chatId    String
  chat      Chat       @relation(fields: [chatId], references: [id], onDelete: Cascade)
  senderId  String
  sender    User       @relation("SentMessages", fields: [senderId], references: [id])
  content   String?
  mediaUrl  String?
  mediaType MediaType?
  isRead    Boolean    @default(false)

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

// ============================================================
// NOTIFICATIONS
// ============================================================

model Notification {
  id        String           @id @default(uuid())
  userId    String
  user      User             @relation(fields: [userId], references: [id], onDelete: Cascade)
  type      NotificationType
  title     String
  body      String
  data      Json?
  isRead    Boolean          @default(false)
  createdAt DateTime         @default(now())
}

// ============================================================
// ENUMS
// ============================================================

enum Role {
  SUPER_ADMIN
  TRAINER
  CLIENT
  SELLER
}

enum Gender {
  MALE
  FEMALE
  OTHER
}

enum Goal {
  LOSE_WEIGHT
  GAIN_MUSCLE
  KEEP_FIT
  IMPROVE_ENDURANCE
}

enum ActivityLevel {
  SEDENTARY
  LIGHTLY_ACTIVE
  MODERATELY_ACTIVE
  VERY_ACTIVE
}

enum FitnessLevel {
  BEGINNER
  INTERMEDIATE
  ADVANCED
}

enum Difficulty {
  EASY
  MEDIUM
  HARD
}

enum SessionStatus {
  IN_PROGRESS
  COMPLETED
  CANCELLED
}

enum MealCategory {
  BREAKFAST
  LUNCH
  SNACK
  DINNER
}

enum MuscleGroup {
  CHEST
  BACK
  SHOULDERS
  ARMS
  LEGS
  CORE
  FULL_BODY
  CARDIO
}

enum ProductCategory {
  PROTEIN
  CREATINE
  VITAMINS
  PRE_WORKOUT
  FAT_BURNER
  CLOTHING
  EQUIPMENT
  OTHER
}

enum OrderStatus {
  PENDING
  PAID
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
  REFUNDED
}

enum SubscriptionStatus {
  PENDING
  ACTIVE
  PAUSED
  CANCELLED
  EXPIRED
}

enum PaymentMode {
  STRIPE
  EXTERNAL
}

enum ChatType {
  DIRECT
  GROUP
}

enum ChatMemberRole {
  ADMIN
  MEMBER
}

enum MediaType {
  IMAGE
  VIDEO
  FILE
}

enum ScanMethod {
  BARCODE
  AI_IMAGE
}

enum NotificationType {
  WORKOUT_REMINDER
  MEAL_REMINDER
  MESSAGE
  COACHING_REQUEST
  COACHING_ACCEPTED
  ORDER_UPDATE
  SYSTEM
}
EOF

# ─────────────────────────────────────────
# 8.  SOURCE FILES
# ─────────────────────────────────────────

# ── config/env.ts ──
cat > src/config/env.ts << 'EOF'
import 'dotenv/config';

function required(key: string): string {
  const v = process.env[key];
  if (!v) throw new Error(`Missing required env var: ${key}`);
  return v;
}

export const env = {
  NODE_ENV:  process.env.NODE_ENV   || 'development',
  PORT:      parseInt(process.env.PORT || '3000'),
  API_PREFIX: process.env.API_PREFIX || '/api/v1',

  DATABASE_URL: required('DATABASE_URL'),

  JWT_SECRET:             required('JWT_SECRET'),
  JWT_EXPIRES_IN:         process.env.JWT_EXPIRES_IN         || '15m',
  JWT_REFRESH_SECRET:     required('JWT_REFRESH_SECRET'),
  JWT_REFRESH_EXPIRES_IN: process.env.JWT_REFRESH_EXPIRES_IN || '7d',

  GOOGLE_CLIENT_ID:     process.env.GOOGLE_CLIENT_ID     || '',
  GOOGLE_CLIENT_SECRET: process.env.GOOGLE_CLIENT_SECRET || '',
  GOOGLE_CALLBACK_URL:  process.env.GOOGLE_CALLBACK_URL  || '',

  CLOUDINARY_CLOUD_NAME: process.env.CLOUDINARY_CLOUD_NAME || '',
  CLOUDINARY_API_KEY:    process.env.CLOUDINARY_API_KEY    || '',
  CLOUDINARY_API_SECRET: process.env.CLOUDINARY_API_SECRET || '',

  STRIPE_SECRET_KEY:     process.env.STRIPE_SECRET_KEY    || '',
  STRIPE_WEBHOOK_SECRET: process.env.STRIPE_WEBHOOK_SECRET || '',

  CORS_ORIGIN:         process.env.CORS_ORIGIN         || 'http://localhost:8081',
  OPENFOODFACTS_BASE:  process.env.OPENFOODFACTS_BASE   || 'https://world.openfoodfacts.org/api/v0',
} as const;
EOF

# ── infrastructure/logger/index.ts ──
cat > src/infrastructure/logger/index.ts << 'EOF'
import winston from 'winston';
import { env } from '@config/env';

export const logger = winston.createLogger({
  level: env.NODE_ENV === 'production' ? 'warn' : 'debug',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.colorize(),
    winston.format.printf(({ timestamp, level, message, ...meta }) => {
      const extra = Object.keys(meta).length ? JSON.stringify(meta) : '';
      return `${timestamp} [${level}]: ${message} ${extra}`;
    }),
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
  ],
});
EOF

# ── infrastructure/database/prisma.ts ──
# FIX [1]: Import from generated output path, NOT from '@prisma/client'
cat > src/infrastructure/database/prisma.ts << 'EOF'
// FIX: Prisma 6 with custom output — import from generated path
// Defined in schema.prisma: generator client { output = "../src/generated/prisma" }
import { PrismaClient } from '../../generated/prisma';
import { logger } from '../logger';

declare global {
  // eslint-disable-next-line no-var
  var __prisma: PrismaClient | undefined;
}

export const prisma: PrismaClient =
  global.__prisma ??
  new PrismaClient({
    log: [
      { emit: 'event', level: 'error' },
      { emit: 'stdout', level: 'warn' },
    ],
  });

// Suppress "any" warnings — Prisma's event type is complex
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(prisma as any).$on('error', (e: unknown) => logger.error('Prisma:', e));

if (process.env.NODE_ENV !== 'production') {
  global.__prisma = prisma;
}

export default prisma;
EOF

# ── infrastructure/database/seed.ts ──
cat > src/infrastructure/database/seed.ts << 'EOF'
import { prisma } from './prisma';
import bcrypt from 'bcryptjs';
import { logger } from '../logger';

async function main() {
  logger.info('🌱 Seeding...');

  await prisma.user.upsert({
    where: { email: 'admin@gymapp.com' },
    update: {},
    create: {
      email:      'admin@gymapp.com',
      password:   await bcrypt.hash('Admin@1234', 12),
      firstName:  'Super',
      lastName:   'Admin',
      role:       'SUPER_ADMIN',
      isVerified: true,
    },
  });

  logger.info('✅ Seed done!');
}

main()
  .catch((e) => { logger.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
EOF

# ── infrastructure/storage/cloudinary.ts ──
cat > src/infrastructure/storage/cloudinary.ts << 'EOF'
import { v2 as cloudinary } from 'cloudinary';
import { env } from '@config/env';

cloudinary.config({
  cloud_name: env.CLOUDINARY_CLOUD_NAME,
  api_key:    env.CLOUDINARY_API_KEY,
  api_secret: env.CLOUDINARY_API_SECRET,
});

export { cloudinary };

export const uploadFile = async (
  filePath: string,
  folder: string,
  opts: object = {},
): Promise<{ url: string; publicId: string }> => {
  const r = await cloudinary.uploader.upload(filePath, {
    folder: `gymapp/${folder}`,
    ...opts,
  });
  return { url: r.secure_url, publicId: r.public_id };
};

export const deleteFile = async (publicId: string) =>
  cloudinary.uploader.destroy(publicId);
EOF

# ── infrastructure/payment/stripe.ts ──
# FIX [3]: stripe-node v12+ auto-uses its own built-in API version.
# Do NOT pass apiVersion manually — causes type error with old date strings.
cat > src/infrastructure/payment/stripe.ts << 'EOF'
import Stripe from 'stripe';
import { env } from '@config/env';

// stripe-node v12+: SDK picks its own API version automatically.
// Passing apiVersion: '2024-04-10' causes a TS type error — removed.
export const stripe = new Stripe(env.STRIPE_SECRET_KEY);

export const createPaymentIntent = (
  amount: number,
  currency = 'usd',
  metadata: Stripe.MetadataParam = {},
) =>
  stripe.paymentIntents.create({
    amount: Math.round(amount * 100),
    currency,
    metadata,
  });
EOF

# ── infrastructure/realtime/socket.ts ──
cat > src/infrastructure/realtime/socket.ts << 'EOF'
import { Server } from 'socket.io';
import { logger } from '../logger';

export const initSocket = (io: Server): void => {
  io.on('connection', (socket) => {
    logger.info(`Socket connected: ${socket.id}`);

    socket.on('chat:join',  (chatId: string) => socket.join(`chat:${chatId}`));
    socket.on('chat:leave', (chatId: string) => socket.leave(`chat:${chatId}`));
    socket.on('chat:message', (data) => io.to(`chat:${data.chatId}`).emit('chat:message:new', data));

    // Real-time GPS run (broadcast to all)
    socket.on('run:location', (data) => socket.broadcast.emit('run:location:update', data));

    socket.on('disconnect', () => logger.info(`Socket disconnected: ${socket.id}`));
  });
};
EOF

# ── shared/errors/AppError.ts ──
cat > src/shared/errors/AppError.ts << 'EOF'
export class AppError extends Error {
  public readonly statusCode: number;
  public readonly isOperational: boolean;

  constructor(message: string, statusCode = 500, isOperational = true) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    Error.captureStackTrace(this, this.constructor);
  }
}
EOF

# ── shared/middleware/errorHandler.ts ──
# FIX [2]: Zod v4 uses error.issues, NOT error.errors
cat > src/shared/middleware/errorHandler.ts << 'EOF'
import { Request, Response, NextFunction } from 'express';
import { StatusCodes } from 'http-status-codes';
import { ZodError } from 'zod';
import { AppError } from '@shared/errors/AppError';
import { logger } from '@infra/logger';

export const errorHandler = (
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void => {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({ success: false, message: err.message });
    return;
  }

  // FIX [2]: Zod v4 — use .issues (not .errors)
  if (err instanceof ZodError) {
    res.status(StatusCodes.UNPROCESSABLE_ENTITY).json({
      success: false,
      message: 'Validation error',
      errors: err.issues.map((i) => ({ field: i.path.join('.'), message: i.message })),
    });
    return;
  }

  logger.error('Unhandled error', { message: err.message, stack: err.stack });
  res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({
    success: false,
    message: 'Internal server error',
  });
};
EOF

# ── shared/middleware/notFoundHandler.ts ──
cat > src/shared/middleware/notFoundHandler.ts << 'EOF'
import { Request, Response } from 'express';
import { StatusCodes } from 'http-status-codes';

export const notFoundHandler = (req: Request, res: Response): void => {
  res.status(StatusCodes.NOT_FOUND).json({
    success: false,
    message: `Route not found: ${req.method} ${req.path}`,
  });
};
EOF

# ── shared/middleware/rateLimiter.ts ──
cat > src/shared/middleware/rateLimiter.ts << 'EOF'
import rateLimit from 'express-rate-limit';

export const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests. Try again later.' },
});
EOF

# ── shared/guards/auth.guard.ts ──
cat > src/shared/guards/auth.guard.ts << 'EOF'
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '@config/env';
import { AppError } from '@shared/errors/AppError';
import { StatusCodes } from 'http-status-codes';

export type UserRole = 'SUPER_ADMIN' | 'TRAINER' | 'CLIENT' | 'SELLER';

export interface JwtPayload {
  userId: string;
  role:   UserRole;
  email:  string;
}

declare global {
  namespace Express {
    interface Request { user?: JwtPayload; }
  }
}

export const authenticate = (req: Request, _res: Response, next: NextFunction): void => {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer '))
    throw new AppError('Authorization header missing', StatusCodes.UNAUTHORIZED);

  try {
    req.user = jwt.verify(header.split(' ')[1], env.JWT_SECRET) as JwtPayload;
    next();
  } catch {
    throw new AppError('Invalid or expired token', StatusCodes.UNAUTHORIZED);
  }
};

export const authorize = (...roles: UserRole[]) =>
  (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user || !roles.includes(req.user.role))
      throw new AppError('Forbidden — insufficient permissions', StatusCodes.FORBIDDEN);
    next();
  };
EOF

# ── utils/apiResponse.ts ──
cat > src/utils/apiResponse.ts << 'EOF'
import { Response } from 'express';

export const sendSuccess = <T>(
  res: Response,
  data: T,
  message = 'Success',
  statusCode = 200,
): Response => res.status(statusCode).json({ success: true, message, data });

export const sendPaginated = <T>(
  res: Response,
  data: T[],
  total: number,
  page: number,
  limit: number,
): Response =>
  res.status(200).json({
    success: true,
    data,
    pagination: { total, page, limit, totalPages: Math.ceil(total / limit) },
  });
EOF

# ── src/main.ts ──
cat > src/main.ts << 'EOF'
import 'express-async-errors';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import cookieParser from 'cookie-parser';
import { createServer } from 'http';
import { Server as SocketServer } from 'socket.io';

import { env } from '@config/env';
import { errorHandler } from '@shared/middleware/errorHandler';
import { notFoundHandler } from '@shared/middleware/notFoundHandler';
import { rateLimiter } from '@shared/middleware/rateLimiter';
import { logger } from '@infra/logger';
import { initSocket } from '@infra/realtime/socket';
import { registerRoutes } from './routes';

const app = express();
const httpServer = createServer(app);

export const io = new SocketServer(httpServer, {
  cors: { origin: env.CORS_ORIGIN, credentials: true },
});

app.use(helmet());
app.use(cors({ origin: env.CORS_ORIGIN, credentials: true }));
app.use(morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(rateLimiter);

registerRoutes(app);
initSocket(io);

app.use(notFoundHandler);
app.use(errorHandler);

httpServer.listen(env.PORT, () => {
  logger.info(`🚀 Server → http://localhost:${env.PORT}${env.API_PREFIX}  [${env.NODE_ENV}]`);
});

export default app;
EOF

# ── src/routes.ts ──
cat > src/routes.ts << 'EOF'
import { Express } from 'express';
import { env } from '@config/env';

import authRoutes         from '@features/auth/routes/auth.routes';
import userRoutes         from '@features/user/routes/user.routes';
import trainerRoutes      from '@features/trainer/routes/trainer.routes';
import clientRoutes       from '@features/client/routes/client.routes';
import workoutRoutes      from '@features/workout/routes/workout.routes';
import exerciseRoutes     from '@features/exercise/routes/exercise.routes';
import nutritionRoutes    from '@features/nutrition/routes/nutrition.routes';
import biometricsRoutes   from '@features/biometrics/routes/biometrics.routes';
import runRoutes          from '@features/run/routes/run.routes';
import shopRoutes         from '@features/shop/routes/shop.routes';
import chatRoutes         from '@features/chat/routes/chat.routes';
import notificationRoutes from '@features/notification/routes/notification.routes';
import adminRoutes        from '@features/admin/routes/admin.routes';

export const registerRoutes = (app: Express): void => {
  const p = env.API_PREFIX;

  app.get(`${p}/health`, (_req, res) =>
    res.json({ status: 'ok', ts: new Date().toISOString() }),
  );

  app.use(`${p}/auth`,          authRoutes);
  app.use(`${p}/users`,         userRoutes);
  app.use(`${p}/trainers`,      trainerRoutes);
  app.use(`${p}/clients`,       clientRoutes);
  app.use(`${p}/workouts`,      workoutRoutes);
  app.use(`${p}/exercises`,     exerciseRoutes);
  app.use(`${p}/nutrition`,     nutritionRoutes);
  app.use(`${p}/biometrics`,    biometricsRoutes);
  app.use(`${p}/runs`,          runRoutes);
  app.use(`${p}/shop`,          shopRoutes);
  app.use(`${p}/chats`,         chatRoutes);
  app.use(`${p}/notifications`, notificationRoutes);
  app.use(`${p}/admin`,         adminRoutes);
};
EOF

# ─────────────────────────────────────────
# 9.  AUTH MODULE  (fully implemented)
# ─────────────────────────────────────────

cat > src/features/auth/dto/auth.dto.ts << 'EOF'
import { z } from 'zod';

export const registerSchema = z.object({
  email:     z.string().email(),
  password:  z.string().min(8, 'Password must be at least 8 characters'),
  firstName: z.string().min(1),
  lastName:  z.string().min(1),
  role:      z.enum(['CLIENT', 'TRAINER', 'SELLER']).optional().default('CLIENT'),
});

export const loginSchema = z.object({
  email:    z.string().email(),
  password: z.string().min(1),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

export type RegisterDto = z.infer<typeof registerSchema>;
export type LoginDto    = z.infer<typeof loginSchema>;
EOF

cat > src/features/auth/repository/auth.repository.ts << 'EOF'
import { prisma } from '@infra/database/prisma';

export class AuthRepository {
  findByEmail(email: string)     { return prisma.user.findUnique({ where: { email } }); }
  findById(id: string)           { return prisma.user.findUnique({ where: { id } }); }
  findByGoogleId(googleId: string) { return prisma.user.findUnique({ where: { googleId } }); }

  createUser(data: {
    email: string; password?: string; googleId?: string;
    firstName: string; lastName: string;
    role?: 'CLIENT' | 'TRAINER' | 'SELLER';
  }) {
    return prisma.user.create({ data });
  }

  saveRefreshToken(userId: string, token: string, expiresAt: Date) {
    return prisma.refreshToken.create({ data: { userId, token, expiresAt } });
  }

  findRefreshToken(token: string) {
    return prisma.refreshToken.findUnique({ where: { token } });
  }

  deleteRefreshToken(token: string) {
    return prisma.refreshToken.delete({ where: { token } });
  }
}
EOF

cat > src/features/auth/service/auth.service.ts << 'EOF'
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { AuthRepository } from '../repository/auth.repository';
import { AppError } from '@shared/errors/AppError';
import { StatusCodes } from 'http-status-codes';
import { env } from '@config/env';
import { prisma } from '@infra/database/prisma';
import type { RegisterDto } from '../dto/auth.dto';

const repo = new AuthRepository();

export class AuthService {
  async register(data: RegisterDto) {
    if (await repo.findByEmail(data.email))
      throw new AppError('Email already registered', StatusCodes.CONFLICT);

    const user = await repo.createUser({
      ...data,
      password: await bcrypt.hash(data.password, 12),
    });

    if (user.role === 'CLIENT')
      await prisma.clientProfile.create({ data: { userId: user.id } });
    else if (user.role === 'TRAINER')
      await prisma.trainerProfile.create({ data: { userId: user.id } });
    else if (user.role === 'SELLER')
      await prisma.sellerProfile.create({
        data: { userId: user.id, storeName: `${user.firstName}'s Store`, storeSlug: uuidv4().slice(0,8) },
      });

    return this.tokens(user);
  }

  async login(email: string, password: string) {
    const user = await repo.findByEmail(email);
    if (!user?.password) throw new AppError('Invalid credentials', StatusCodes.UNAUTHORIZED);
    if (!(await bcrypt.compare(password, user.password)))
      throw new AppError('Invalid credentials', StatusCodes.UNAUTHORIZED);
    if (!user.isActive) throw new AppError('Account deactivated', StatusCodes.FORBIDDEN);
    return this.tokens(user);
  }

  async refresh(token: string) {
    const stored = await repo.findRefreshToken(token);
    if (!stored || stored.expiresAt < new Date())
      throw new AppError('Invalid or expired refresh token', StatusCodes.UNAUTHORIZED);
    const user = await repo.findById(stored.userId);
    if (!user) throw new AppError('User not found', StatusCodes.NOT_FOUND);
    await repo.deleteRefreshToken(token);
    return this.tokens(user);
  }

  async logout(token: string) {
    await repo.deleteRefreshToken(token).catch(() => null);
  }

  private async tokens(user: { id: string; email: string; role: string }) {
    const payload = { userId: user.id, email: user.email, role: user.role };
    const accessToken  = jwt.sign(payload, env.JWT_SECRET, { expiresIn: env.JWT_EXPIRES_IN as string });
    const refreshToken = uuidv4();
    await repo.saveRefreshToken(user.id, refreshToken, new Date(Date.now() + 7 * 86400_000));
    return { accessToken, refreshToken, user: payload };
  }
}
EOF

cat > src/features/auth/controller/auth.controller.ts << 'EOF'
import { Request, Response } from 'express';
import { AuthService } from '../service/auth.service';
import { sendSuccess } from '@utils/apiResponse';
import { registerSchema, loginSchema, refreshSchema } from '../dto/auth.dto';

const svc = new AuthService();

export const register = async (req: Request, res: Response) => {
  sendSuccess(res, await svc.register(registerSchema.parse(req.body)), 'Registered', 201);
};

export const login = async (req: Request, res: Response) => {
  const { email, password } = loginSchema.parse(req.body);
  sendSuccess(res, await svc.login(email, password), 'Login successful');
};

export const refresh = async (req: Request, res: Response) => {
  sendSuccess(res, await svc.refresh(refreshSchema.parse(req.body).refreshToken), 'Token refreshed');
};

export const logout = async (req: Request, res: Response) => {
  await svc.logout(req.body.refreshToken);
  sendSuccess(res, null, 'Logged out');
};
EOF

cat > src/features/auth/routes/auth.routes.ts << 'EOF'
import { Router } from 'express';
import * as ctrl from '../controller/auth.controller';

const router = Router();

router.post('/register', ctrl.register);
router.post('/login',    ctrl.login);
router.post('/refresh',  ctrl.refresh);
router.post('/logout',   ctrl.logout);

export default router;
EOF

# ─────────────────────────────────────────
# 10. PLACEHOLDER ROUTES (all other modules)
# ─────────────────────────────────────────

for module in user trainer client workout exercise nutrition biometrics run shop chat notification admin; do
cat > src/features/$module/routes/${module}.routes.ts << ROUTEOF
import { Router } from 'express';
import { authenticate } from '@shared/guards/auth.guard';

const router = Router();

// TODO: implement $module routes
router.get('/', authenticate, (_req, res) => {
  res.json({ success: true, module: '$module', status: 'coming soon' });
});

export default router;
ROUTEOF
done

# ─────────────────────────────────────────
# 11. README
# ─────────────────────────────────────────
cat > README.md << 'EOF'
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
EOF

echo ""
echo "✅ ══════════════════════════════════════════"
echo "   GYM APP API — DONE!"
echo "══════════════════════════════════════════"
echo ""
echo "📁  gym-api/"
echo ""
echo "▶️  Run:"
echo "   cd gym-api"
echo "   createdb gymapp_db"
echo "   cp .env.example .env    ← fill in secrets"
echo "   npm run db:generate"
echo "   npm run db:migrate"
echo "   npm run db:seed"
echo "   npm run dev"
echo ""
echo "🌐  http://localhost:3000/api/v1"
echo ""
echo "🐛  Fixes vs v1:"
echo "   ✓  Prisma 6: PrismaClient from generated path"
echo "   ✓  Zod v4: error.issues (not error.errors)"
echo "   ✓  Stripe: no manual apiVersion"
echo "   ✓  tsconfig: ignoreDeprecations added"
echo "   ✓  No Docker"
echo ""