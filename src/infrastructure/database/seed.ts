import { prisma } from './prisma';
import bcrypt from 'bcryptjs';
import { logger } from '../logger';

async function main() {
  logger.info('🌱 Starting comprehensive database seeding...');

  // ============================================================
  // USERS
  // ============================================================
  logger.info('Creating users...');

  const adminUser = await prisma.user.upsert({
    where: { email: 'admin@gymapp.com' },
    update: {},
    create: {
      email: 'admin@gymapp.com',
      password: await bcrypt.hash('Admin@1234', 12),
      firstName: 'Super',
      lastName: 'Admin',
      role: 'SUPER_ADMIN',
      isVerified: true,
      gender: 'MALE',
      dateOfBirth: new Date('1985-01-15'),
      height: 180,
      weight: 80,
      goal: 'KEEP_FIT',
      activityLevel: 'MODERATELY_ACTIVE',
    },
  });

  const trainer1 = await prisma.user.upsert({
    where: { email: 'john.trainer@gymapp.com' },
    update: {},
    create: {
      email: 'john.trainer@gymapp.com',
      password: await bcrypt.hash('Trainer@1234', 12),
      firstName: 'John',
      lastName: 'Trainer',
      role: 'TRAINER',
      isVerified: true,
      gender: 'MALE',
      dateOfBirth: new Date('1988-05-20'),
      height: 185,
      weight: 85,
      goal: 'GAIN_MUSCLE',
      activityLevel: 'VERY_ACTIVE',
    },
  });

  const trainer2 = await prisma.user.upsert({
    where: { email: 'sarah.coach@gymapp.com' },
    update: {},
    create: {
      email: 'sarah.coach@gymapp.com',
      password: await bcrypt.hash('Trainer@1234', 12),
      firstName: 'Sarah',
      lastName: 'Coach',
      role: 'TRAINER',
      isVerified: true,
      gender: 'FEMALE',
      dateOfBirth: new Date('1990-08-12'),
      height: 168,
      weight: 60,
      goal: 'KEEP_FIT',
      activityLevel: 'VERY_ACTIVE',
    },
  });

  const client1 = await prisma.user.upsert({
    where: { email: 'mike.client@gymapp.com' },
    update: {},
    create: {
      email: 'mike.client@gymapp.com',
      password: await bcrypt.hash('Client@1234', 12),
      firstName: 'Mike',
      lastName: 'Johnson',
      role: 'CLIENT',
      isVerified: true,
      gender: 'MALE',
      dateOfBirth: new Date('1995-03-10'),
      height: 175,
      weight: 90,
      goal: 'LOSE_WEIGHT',
      activityLevel: 'LIGHTLY_ACTIVE',
    },
  });

  const client2 = await prisma.user.upsert({
    where: { email: 'emma.fit@gymapp.com' },
    update: {},
    create: {
      email: 'emma.fit@gymapp.com',
      password: await bcrypt.hash('Client@1234', 12),
      firstName: 'Emma',
      lastName: 'Williams',
      role: 'CLIENT',
      isVerified: true,
      gender: 'FEMALE',
      dateOfBirth: new Date('1992-11-25'),
      height: 165,
      weight: 58,
      goal: 'GAIN_MUSCLE',
      activityLevel: 'MODERATELY_ACTIVE',
    },
  });

  const client3 = await prisma.user.upsert({
    where: { email: 'alex.runner@gymapp.com' },
    update: {},
    create: {
      email: 'alex.runner@gymapp.com',
      password: await bcrypt.hash('Client@1234', 12),
      firstName: 'Alex',
      lastName: 'Martinez',
      role: 'CLIENT',
      isVerified: true,
      gender: 'MALE',
      dateOfBirth: new Date('1998-07-08'),
      height: 170,
      weight: 65,
      goal: 'IMPROVE_ENDURANCE',
      activityLevel: 'VERY_ACTIVE',
    },
  });

  const seller1 = await prisma.user.upsert({
    where: { email: 'nutrition.seller@gymapp.com' },
    update: {},
    create: {
      email: 'nutrition.seller@gymapp.com',
      password: await bcrypt.hash('Seller@1234', 12),
      firstName: 'Nutrition',
      lastName: 'Plus',
      role: 'SELLER',
      isVerified: true,
      gender: 'MALE',
      dateOfBirth: new Date('1987-02-14'),
    },
  });

  const seller2 = await prisma.user.upsert({
    where: { email: 'fitgear.store@gymapp.com' },
    update: {},
    create: {
      email: 'fitgear.store@gymapp.com',
      password: await bcrypt.hash('Seller@1234', 12),
      firstName: 'FitGear',
      lastName: 'Store',
      role: 'SELLER',
      isVerified: true,
      gender: 'FEMALE',
      dateOfBirth: new Date('1985-09-30'),
    },
  });

  // ============================================================
  // TRAINER PROFILES
  // ============================================================
  logger.info('Creating trainer profiles...');

  const trainerProfile1 = await prisma.trainerProfile.upsert({
    where: { userId: trainer1.id },
    update: {},
    create: {
      userId: trainer1.id,
      bio: 'Certified personal trainer with 10+ years of experience. Specializing in strength training and body transformation.',
      specialties: 'Strength Training,Body Building,Weight Loss',
      experience: 10,
      rating: 4.8,
      isVerified: true,
      hourlyRate: 75.0,
    },
  });

  const trainerProfile2 = await prisma.trainerProfile.upsert({
    where: { userId: trainer2.id },
    update: {},
    create: {
      userId: trainer2.id,
      bio: 'Yoga and Pilates instructor passionate about holistic wellness and functional fitness.',
      specialties: 'Yoga,Pilates,Flexibility,Functional Training',
      experience: 7,
      rating: 4.9,
      isVerified: true,
      hourlyRate: 60.0,
    },
  });

  // ============================================================
  // CLIENT PROFILES
  // ============================================================
  logger.info('Creating client profiles...');

  const clientProfile1 = await prisma.clientProfile.upsert({
    where: { userId: client1.id },
    update: {},
    create: {
      userId: client1.id,
      trainerId: trainerProfile1.id,
      fitnessLevel: 'BEGINNER',
      medicalNotes: 'Mild knee pain, avoid high-impact exercises',
    },
  });

  const clientProfile2 = await prisma.clientProfile.upsert({
    where: { userId: client2.id },
    update: {},
    create: {
      userId: client2.id,
      trainerId: trainerProfile1.id,
      fitnessLevel: 'INTERMEDIATE',
    },
  });

  const clientProfile3 = await prisma.clientProfile.upsert({
    where: { userId: client3.id },
    update: {},
    create: {
      userId: client3.id,
      trainerId: trainerProfile2.id,
      fitnessLevel: 'ADVANCED',
    },
  });

  // ============================================================
  // SELLER PROFILES
  // ============================================================
  logger.info('Creating seller profiles...');

  const sellerProfile1 = await prisma.sellerProfile.upsert({
    where: { userId: seller1.id },
    update: {},
    create: {
      userId: seller1.id,
      storeName: 'Nutrition Plus',
      storeSlug: 'nutrition-plus',
      description: 'Premium supplements and nutrition products for serious athletes',
      logoUrl: 'https://example.com/logos/nutrition-plus.png',
      isVerified: true,
      rating: 4.7,
    },
  });

  const sellerProfile2 = await prisma.sellerProfile.upsert({
    where: { userId: seller2.id },
    update: {},
    create: {
      userId: seller2.id,
      storeName: 'FitGear Pro',
      storeSlug: 'fitgear-pro',
      description: 'Quality fitness equipment and apparel',
      logoUrl: 'https://example.com/logos/fitgear.png',
      isVerified: true,
      rating: 4.5,
    },
  });

  // ============================================================
  // COACHING PLANS
  // ============================================================
  logger.info('Creating coaching plans...');

  const coachingPlan1 = await prisma.coachingPlan.create({
    data: {
      trainerId: trainerProfile1.id,
      name: 'Body Transformation Plan',
      description:
        'Complete 12-week transformation program with personalized workouts and nutrition',
      price: 299.99,
      durationWeeks: 12,
      features: 'Custom workout plans,Weekly check-ins,Nutrition guidance,24/7 chat support',
      isActive: true,
    },
  });

  const coachingPlan2 = await prisma.coachingPlan.create({
    data: {
      trainerId: trainerProfile2.id,
      name: 'Wellness & Flexibility',
      description: '8-week program focused on flexibility, mobility, and mindfulness',
      price: 199.99,
      durationWeeks: 8,
      features: 'Yoga sessions,Stretching routines,Meditation guides,Progress tracking',
      isActive: true,
    },
  });

  // ============================================================
  // COACHING SUBSCRIPTIONS
  // ============================================================
  logger.info('Creating coaching subscriptions...');

  await prisma.coachingSubscription.create({
    data: {
      clientId: clientProfile1.id,
      planId: coachingPlan1.id,
      status: 'ACTIVE',
      startDate: new Date('2026-01-01'),
      endDate: new Date('2026-03-24'),
      paymentMode: 'STRIPE',
    },
  });

  await prisma.coachingSubscription.create({
    data: {
      clientId: clientProfile3.id,
      planId: coachingPlan2.id,
      status: 'ACTIVE',
      startDate: new Date('2026-02-01'),
      endDate: new Date('2026-03-29'),
      paymentMode: 'STRIPE',
    },
  });

  // ============================================================
  // EXERCISES
  // ============================================================
  logger.info('Creating exercises...');

  const pushUp = await prisma.exercise.create({
    data: {
      title: 'Push-ups',
      description: 'Classic bodyweight exercise for chest, shoulders, and triceps',
      muscleGroup: 'CHEST',
      caloriesBurnPerMin: 7.0,
      imageUrl: 'https://example.com/exercises/pushup.jpg',
      instructions: {
        create: [
          { stepNumber: 1, content: 'Start in a plank position with hands shoulder-width apart' },
          { stepNumber: 2, content: 'Lower your body until chest nearly touches the floor' },
          { stepNumber: 3, content: 'Push back up to starting position' },
          { stepNumber: 4, content: 'Keep core engaged throughout the movement' },
        ],
      },
    },
  });

  const squat = await prisma.exercise.create({
    data: {
      title: 'Squats',
      description: 'Fundamental lower body exercise',
      muscleGroup: 'LEGS',
      caloriesBurnPerMin: 8.0,
      imageUrl: 'https://example.com/exercises/squat.jpg',
      instructions: {
        create: [
          { stepNumber: 1, content: 'Stand with feet shoulder-width apart' },
          { stepNumber: 2, content: 'Lower your body as if sitting back into a chair' },
          { stepNumber: 3, content: 'Keep chest up and knees tracking over toes' },
          { stepNumber: 4, content: 'Push through heels to return to standing' },
        ],
      },
    },
  });

  const plank = await prisma.exercise.create({
    data: {
      title: 'Plank Hold',
      description: 'Core strengthening exercise',
      muscleGroup: 'CORE',
      caloriesBurnPerMin: 5.0,
      imageUrl: 'https://example.com/exercises/plank.jpg',
      instructions: {
        create: [
          { stepNumber: 1, content: 'Start in forearm plank position' },
          { stepNumber: 2, content: 'Keep body in straight line from head to heels' },
          { stepNumber: 3, content: 'Engage core and hold position' },
          { stepNumber: 4, content: 'Breathe steadily throughout' },
        ],
      },
    },
  });

  const burpee = await prisma.exercise.create({
    data: {
      title: 'Burpees',
      description: 'Full body cardio exercise',
      muscleGroup: 'FULL_BODY',
      caloriesBurnPerMin: 10.0,
      imageUrl: 'https://example.com/exercises/burpee.jpg',
      instructions: {
        create: [
          { stepNumber: 1, content: 'Start standing, then drop into a squat' },
          { stepNumber: 2, content: 'Kick feet back into plank position' },
          { stepNumber: 3, content: 'Do a push-up, then jump feet back to squat' },
          { stepNumber: 4, content: 'Explode up with a jump' },
        ],
      },
    },
  });

  const pullUp = await prisma.exercise.create({
    data: {
      title: 'Pull-ups',
      description: 'Upper body pulling exercise',
      muscleGroup: 'BACK',
      caloriesBurnPerMin: 9.0,
      imageUrl: 'https://example.com/exercises/pullup.jpg',
      instructions: {
        create: [
          { stepNumber: 1, content: 'Hang from bar with overhand grip' },
          { stepNumber: 2, content: 'Pull yourself up until chin clears bar' },
          { stepNumber: 3, content: 'Lower back down with control' },
        ],
      },
    },
  });

  // ============================================================
  // WORKOUTS
  // ============================================================
  logger.info('Creating workouts...');

  const workout1 = await prisma.workout.create({
    data: {
      title: 'Beginner Full Body',
      description: 'Perfect starter workout for beginners',
      caloriesBurn: 250,
      duration: 30,
      difficulty: 'EASY',
      isPublic: true,
      createdById: trainerProfile1.id,
      imageUrl: 'https://example.com/workouts/beginner-full.jpg',
      exercises: {
        create: [
          { exerciseId: pushUp.id, order: 1, sets: 3, reps: '10', restTime: 60 },
          { exerciseId: squat.id, order: 2, sets: 3, reps: '15', restTime: 60 },
          { exerciseId: plank.id, order: 3, sets: 3, duration: 30, restTime: 45 },
        ],
      },
      tags: {
        create: [{ tag: 'beginner' }, { tag: 'full-body' }, { tag: 'home-workout' }],
      },
    },
  });

  const workout2 = await prisma.workout.create({
    data: {
      title: 'HIIT Cardio Blast',
      description: 'High intensity interval training for fat loss',
      caloriesBurn: 400,
      duration: 25,
      difficulty: 'HARD',
      isPublic: true,
      createdById: trainerProfile1.id,
      imageUrl: 'https://example.com/workouts/hiit.jpg',
      exercises: {
        create: [
          { exerciseId: burpee.id, order: 1, sets: 4, reps: '15', restTime: 30 },
          { exerciseId: squat.id, order: 2, sets: 4, reps: '20', restTime: 30 },
          { exerciseId: pushUp.id, order: 3, sets: 4, reps: '15', restTime: 30 },
        ],
      },
      tags: {
        create: [{ tag: 'hiit' }, { tag: 'cardio' }, { tag: 'fat-loss' }],
      },
    },
  });

  const workout3 = await prisma.workout.create({
    data: {
      title: 'Upper Body Strength',
      description: 'Build upper body muscle and strength',
      caloriesBurn: 300,
      duration: 45,
      difficulty: 'MEDIUM',
      isPublic: true,
      createdById: trainerProfile2.id,
      imageUrl: 'https://example.com/workouts/upper.jpg',
      exercises: {
        create: [
          { exerciseId: pullUp.id, order: 1, sets: 4, reps: '8', restTime: 90 },
          { exerciseId: pushUp.id, order: 2, sets: 4, reps: '12', restTime: 60 },
          { exerciseId: plank.id, order: 3, sets: 3, duration: 45, restTime: 60 },
        ],
      },
      tags: {
        create: [{ tag: 'strength' }, { tag: 'upper-body' }],
      },
    },
  });

  // ============================================================
  // WORKOUT ASSIGNMENTS
  // ============================================================
  logger.info('Creating workout assignments...');

  await prisma.workoutAssignment.create({
    data: {
      clientId: clientProfile1.id,
      workoutId: workout1.id,
      note: 'Start with this 3x per week. Focus on form!',
    },
  });

  await prisma.workoutAssignment.create({
    data: {
      clientId: clientProfile2.id,
      workoutId: workout2.id,
      note: 'Great for your fat loss goals. Push yourself!',
    },
  });

  // ============================================================
  // SCHEDULED WORKOUTS
  // ============================================================
  logger.info('Creating scheduled workouts...');

  const today = new Date();
  await prisma.scheduledWorkout.createMany({
    data: [
      {
        userId: client1.id,
        workoutId: workout1.id,
        scheduledDate: new Date(today.getTime() + 1 * 24 * 60 * 60 * 1000),
      },
      {
        userId: client1.id,
        workoutId: workout1.id,
        scheduledDate: new Date(today.getTime() + 3 * 24 * 60 * 60 * 1000),
      },
      {
        userId: client2.id,
        workoutId: workout2.id,
        scheduledDate: new Date(today.getTime() + 2 * 24 * 60 * 60 * 1000),
      },
    ],
  });

  // ============================================================
  // INGREDIENTS
  // ============================================================
  logger.info('Creating ingredients...');

  const chicken = await prisma.ingredient.create({
    data: {
      name: 'Chicken Breast',
      calories: 165,
      proteins: 31,
      carbs: 0,
      fats: 3.6,
      per100g: true,
    },
  });

  const rice = await prisma.ingredient.create({
    data: {
      name: 'Brown Rice',
      calories: 112,
      proteins: 2.6,
      carbs: 24,
      fats: 0.9,
      per100g: true,
    },
  });

  const broccoli = await prisma.ingredient.create({
    data: {
      name: 'Broccoli',
      calories: 34,
      proteins: 2.8,
      carbs: 7,
      fats: 0.4,
      per100g: true,
    },
  });

  const egg = await prisma.ingredient.create({
    data: {
      name: 'Eggs',
      calories: 155,
      proteins: 13,
      carbs: 1.1,
      fats: 11,
      per100g: true,
    },
  });

  const oats = await prisma.ingredient.create({
    data: {
      name: 'Oats',
      calories: 389,
      proteins: 16.9,
      carbs: 66,
      fats: 6.9,
      per100g: true,
    },
  });

  const banana = await prisma.ingredient.create({
    data: {
      name: 'Banana',
      calories: 89,
      proteins: 1.1,
      carbs: 23,
      fats: 0.3,
      per100g: true,
    },
  });

  // ============================================================
  // MEALS
  // ============================================================
  logger.info('Creating meals...');

  const meal1 = await prisma.meal.create({
    data: {
      name: 'Protein Oatmeal Bowl',
      description: 'Hearty breakfast with oats, banana, and protein',
      category: 'BREAKFAST',
      calories: 450,
      proteins: 20,
      carbs: 65,
      fats: 12,
      fiber: 8,
      isPublic: true,
      imageUrl: 'https://example.com/meals/oatmeal.jpg',
      ingredients: {
        create: [
          { ingredientId: oats.id, amount: '80g' },
          { ingredientId: banana.id, amount: '1 medium' },
        ],
      },
      steps: {
        create: [
          { stepNumber: 1, instruction: 'Cook oats according to package instructions' },
          { stepNumber: 2, instruction: 'Slice banana and add on top' },
          { stepNumber: 3, instruction: 'Add protein powder if desired' },
        ],
      },
    },
  });

  const meal2 = await prisma.meal.create({
    data: {
      name: 'Grilled Chicken & Rice',
      description: 'Classic bodybuilding meal',
      category: 'LUNCH',
      calories: 520,
      proteins: 45,
      carbs: 55,
      fats: 8,
      fiber: 4,
      isPublic: true,
      imageUrl: 'https://example.com/meals/chicken-rice.jpg',
      ingredients: {
        create: [
          { ingredientId: chicken.id, amount: '200g' },
          { ingredientId: rice.id, amount: '150g' },
          { ingredientId: broccoli.id, amount: '100g' },
        ],
      },
      steps: {
        create: [
          { stepNumber: 1, instruction: 'Season and grill chicken breast' },
          { stepNumber: 2, instruction: 'Cook brown rice' },
          { stepNumber: 3, instruction: 'Steam broccoli' },
          { stepNumber: 4, instruction: 'Plate and serve' },
        ],
      },
    },
  });

  const meal3 = await prisma.meal.create({
    data: {
      name: 'Scrambled Eggs & Toast',
      description: 'Quick protein-rich breakfast',
      category: 'BREAKFAST',
      calories: 320,
      proteins: 22,
      carbs: 28,
      fats: 14,
      fiber: 3,
      isPublic: true,
      imageUrl: 'https://example.com/meals/eggs.jpg',
      ingredients: {
        create: [{ ingredientId: egg.id, amount: '3 large' }],
      },
      steps: {
        create: [
          { stepNumber: 1, instruction: 'Whisk eggs in a bowl' },
          { stepNumber: 2, instruction: 'Cook in non-stick pan on medium heat' },
          { stepNumber: 3, instruction: 'Serve with whole grain toast' },
        ],
      },
    },
  });

  // ============================================================
  // DIET PLANS
  // ============================================================
  logger.info('Creating diet plans...');

  const dietPlan1 = await prisma.dietPlan.create({
    data: {
      trainerId: trainerProfile1.id,
      title: 'Muscle Gain Plan',
      description: '7-day high protein meal plan for muscle building',
      goal: 'GAIN_MUSCLE',
      durationWeeks: 4,
      isPublic: true,
      meals: {
        create: [
          { mealId: meal1.id, dayNumber: 1, mealType: 'BREAKFAST' },
          { mealId: meal2.id, dayNumber: 1, mealType: 'LUNCH' },
          { mealId: meal3.id, dayNumber: 2, mealType: 'BREAKFAST' },
        ],
      },
    },
  });

  const dietPlan2 = await prisma.dietPlan.create({
    data: {
      trainerId: trainerProfile2.id,
      title: 'Weight Loss Plan',
      description: 'Calorie-controlled plan for fat loss',
      goal: 'LOSE_WEIGHT',
      durationWeeks: 8,
      isPublic: true,
      meals: {
        create: [
          { mealId: meal1.id, dayNumber: 1, mealType: 'BREAKFAST' },
          {
            mealId: meal2.id,
            dayNumber: 1,
            mealType: 'LUNCH',
            note: 'Reduce rice portion to 100g',
          },
        ],
      },
    },
  });

  // ============================================================
  // DIET PLAN ASSIGNMENTS
  // ============================================================
  logger.info('Creating diet plan assignments...');

  await prisma.dietPlanAssignment.create({
    data: {
      clientId: clientProfile2.id,
      dietPlanId: dietPlan1.id,
      note: 'Follow strictly for best results',
    },
  });

  // ============================================================
  // PRODUCTS
  // ============================================================
  logger.info('Creating products...');

  const product1 = await prisma.product.create({
    data: {
      sellerId: sellerProfile1.id,
      name: 'Whey Protein Isolate',
      description: 'Premium whey protein isolate, 25g protein per serving',
      price: 49.99,
      stock: 100,
      category: 'PROTEIN',
      imageUrls: JSON.parse(
        '["https://example.com/products/whey1.jpg","https://example.com/products/whey2.jpg"]',
      ),
      rating: 4.6,
      isActive: true,
    },
  });

  const product2 = await prisma.product.create({
    data: {
      sellerId: sellerProfile1.id,
      name: 'Creatine Monohydrate',
      description: 'Pure micronized creatine monohydrate, 5g per serving',
      price: 24.99,
      stock: 150,
      category: 'CREATINE',
      imageUrls: JSON.parse('["https://example.com/products/creatine.jpg"]'),
      rating: 4.8,
      isActive: true,
    },
  });

  const product3 = await prisma.product.create({
    data: {
      sellerId: sellerProfile2.id,
      name: 'Resistance Bands Set',
      description: 'Set of 5 resistance bands with different strengths',
      price: 29.99,
      stock: 75,
      category: 'EQUIPMENT',
      imageUrls: JSON.parse('["https://example.com/products/bands.jpg"]'),
      rating: 4.5,
      isActive: true,
    },
  });

  const product4 = await prisma.product.create({
    data: {
      sellerId: sellerProfile2.id,
      name: 'Gym T-Shirt',
      description: 'Breathable performance t-shirt',
      price: 19.99,
      stock: 200,
      category: 'CLOTHING',
      imageUrls: JSON.parse('["https://example.com/products/tshirt.jpg"]'),
      rating: 4.3,
      isActive: true,
    },
  });

  // ============================================================
  // PRODUCT REVIEWS
  // ============================================================
  logger.info('Creating product reviews...');

  await prisma.productReview.createMany({
    data: [
      {
        productId: product1.id,
        userId: client1.id,
        rating: 5,
        comment: 'Great protein! Mixes well and tastes good.',
      },
      {
        productId: product1.id,
        userId: client2.id,
        rating: 4,
        comment: 'Good quality, slightly expensive',
      },
      {
        productId: product2.id,
        userId: client3.id,
        rating: 5,
        comment: 'Best creatine on the market',
      },
    ],
  });

  // ============================================================
  // CART & CART ITEMS
  // ============================================================
  logger.info('Creating carts...');

  const cart1 = await prisma.cart.create({
    data: {
      userId: client1.id,
      items: {
        create: [
          { productId: product1.id, quantity: 2 },
          { productId: product3.id, quantity: 1 },
        ],
      },
    },
  });

  // ============================================================
  // ORDERS
  // ============================================================
  logger.info('Creating orders...');

  const order1 = await prisma.order.create({
    data: {
      clientId: clientProfile2.id,
      status: 'DELIVERED',
      totalAmount: 74.98,
      shippingAddress: JSON.parse(
        '{"street":"123 Main St","city":"New York","zip":"10001","country":"USA"}',
      ),
      items: {
        create: [
          {
            productId: product1.id,
            sellerId: sellerProfile1.id,
            quantity: 1,
            unitPrice: 49.99,
          },
          {
            productId: product2.id,
            sellerId: sellerProfile1.id,
            quantity: 1,
            unitPrice: 24.99,
          },
        ],
      },
    },
  });

  const order2 = await prisma.order.create({
    data: {
      clientId: clientProfile3.id,
      status: 'SHIPPED',
      totalAmount: 29.99,
      shippingAddress: JSON.parse(
        '{"street":"456 Oak Ave","city":"Los Angeles","zip":"90001","country":"USA"}',
      ),
      items: {
        create: [
          {
            productId: product3.id,
            sellerId: sellerProfile2.id,
            quantity: 1,
            unitPrice: 29.99,
          },
        ],
      },
    },
  });

  // ============================================================
  // BIOMETRIC LOGS
  // ============================================================
  logger.info('Creating biometric logs...');

  // Weight logs
  const thirtyDaysAgo = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000);
  await prisma.weightLog.createMany({
    data: [
      {
        userId: client1.id,
        value: 92,
        date: new Date(thirtyDaysAgo.getTime() + 0 * 24 * 60 * 60 * 1000),
      },
      {
        userId: client1.id,
        value: 91.5,
        date: new Date(thirtyDaysAgo.getTime() + 7 * 24 * 60 * 60 * 1000),
      },
      {
        userId: client1.id,
        value: 90.8,
        date: new Date(thirtyDaysAgo.getTime() + 14 * 24 * 60 * 60 * 1000),
      },
      {
        userId: client1.id,
        value: 90,
        date: new Date(thirtyDaysAgo.getTime() + 21 * 24 * 60 * 60 * 1000),
      },
      {
        userId: client1.id,
        value: 89.5,
        date: new Date(thirtyDaysAgo.getTime() + 28 * 24 * 60 * 60 * 1000),
      },
    ],
  });

  // Heart rate logs
  await prisma.heartRateLog.createMany({
    data: [
      { userId: client1.id, bpm: 72 },
      { userId: client2.id, bpm: 68 },
      { userId: client3.id, bpm: 65 },
    ],
  });

  // Blood pressure logs
  await prisma.bloodPressureLog.createMany({
    data: [
      { userId: client1.id, systolic: 120, diastolic: 80 },
      { userId: client2.id, systolic: 118, diastolic: 78 },
    ],
  });

  // Water logs
  await prisma.waterLog.createMany({
    data: [
      { userId: client1.id, amount: 2000, date: today },
      { userId: client2.id, amount: 2500, date: today },
      { userId: client3.id, amount: 3000, date: today },
    ],
  });

  // Step logs
  await prisma.stepLog.createMany({
    data: [
      { userId: client1.id, count: 8500, date: today },
      { userId: client2.id, count: 10200, date: today },
      { userId: client3.id, count: 12500, date: today },
    ],
  });

  // Stress logs
  await prisma.stressLog.createMany({
    data: [
      { userId: client1.id, level: 3, status: 'Moderate' },
      { userId: client2.id, level: 2, status: 'Low' },
    ],
  });

  // Blood oxygen logs
  await prisma.bloodOxygenLog.createMany({
    data: [
      { userId: client1.id, percentage: 98 },
      { userId: client2.id, percentage: 99 },
    ],
  });

  // ============================================================
  // RUN SESSIONS
  // ============================================================
  logger.info('Creating run sessions...');

  const runSession1 = await prisma.runSession.create({
    data: {
      userId: client3.id,
      startTime: new Date(today.getTime() - 2 * 60 * 60 * 1000),
      endTime: new Date(today.getTime() - 1.5 * 60 * 60 * 1000),
      distanceKm: 5.2,
      durationSecs: 1800,
      avgSpeedKmh: 10.4,
      calories: 420,
      status: 'COMPLETED',
      isPublic: true,
      routePoints: {
        create: [
          {
            latitude: 40.7128,
            longitude: -74.006,
            altitude: 10,
            timestamp: new Date(today.getTime() - 2 * 60 * 60 * 1000),
            order: 1,
          },
          {
            latitude: 40.7138,
            longitude: -74.007,
            altitude: 12,
            timestamp: new Date(today.getTime() - 1.9 * 60 * 60 * 1000),
            order: 2,
          },
          {
            latitude: 40.7148,
            longitude: -74.008,
            altitude: 15,
            timestamp: new Date(today.getTime() - 1.8 * 60 * 60 * 1000),
            order: 3,
          },
        ],
      },
    },
  });

  // ============================================================
  // WORKOUT SESSIONS
  // ============================================================
  logger.info('Creating workout sessions...');

  const workoutSession1 = await prisma.workoutSession.create({
    data: {
      userId: client1.id,
      workoutId: workout1.id,
      startTime: new Date(today.getTime() - 24 * 60 * 60 * 1000),
      endTime: new Date(today.getTime() - 23.5 * 60 * 60 * 1000),
      duration: 30,
      calories: 250,
      status: 'COMPLETED',
      exerciseLogs: {
        create: [
          { exerciseId: pushUp.id, setNumber: 1, repsCompleted: 10 },
          { exerciseId: pushUp.id, setNumber: 2, repsCompleted: 10 },
          { exerciseId: pushUp.id, setNumber: 3, repsCompleted: 8 },
          { exerciseId: squat.id, setNumber: 1, repsCompleted: 15 },
          { exerciseId: squat.id, setNumber: 2, repsCompleted: 15 },
        ],
      },
    },
  });

  // ============================================================
  // MEAL LOGS
  // ============================================================
  logger.info('Creating meal logs...');

  await prisma.mealLog.createMany({
    data: [
      {
        userId: client1.id,
        mealId: meal1.id,
        mealType: 'BREAKFAST',
        eatenAt: new Date(today.getTime() - 5 * 60 * 60 * 1000),
        portionMultiplier: 1,
      },
      {
        userId: client1.id,
        mealId: meal2.id,
        mealType: 'LUNCH',
        eatenAt: new Date(today.getTime() - 1 * 60 * 60 * 1000),
        portionMultiplier: 1,
      },
      {
        userId: client2.id,
        mealId: meal3.id,
        mealType: 'BREAKFAST',
        eatenAt: new Date(today.getTime() - 4 * 60 * 60 * 1000),
        portionMultiplier: 1,
      },
    ],
  });

  // ============================================================
  // FOOD SCAN LOGS
  // ============================================================
  logger.info('Creating food scan logs...');

  await prisma.foodScanLog.createMany({
    data: [
      {
        userId: client1.id,
        barcode: '123456789',
        productName: 'Protein Bar',
        calories: 200,
        proteins: 20,
        carbs: 25,
        fats: 8,
        scanMethod: 'BARCODE',
        rawData: JSON.parse('{"brand":"FitBar","serving":"60g"}'),
      },
      {
        userId: client2.id,
        imageUrl: 'https://example.com/scans/apple.jpg',
        productName: 'Apple',
        calories: 95,
        proteins: 0.5,
        carbs: 25,
        fats: 0.3,
        scanMethod: 'AI_IMAGE',
      },
    ],
  });

  // ============================================================
  // CHATS & MESSAGES
  // ============================================================
  logger.info('Creating chats and messages...');

  const chat1 = await prisma.chat.create({
    data: {
      type: 'DIRECT',
      members: {
        create: [
          { userId: client1.id, role: 'MEMBER' },
          { userId: trainer1.id, role: 'MEMBER' },
        ],
      },
      messages: {
        create: [
          {
            senderId: client1.id,
            content: 'Hi John, I have a question about my workout plan',
            isRead: true,
          },
          {
            senderId: trainer1.id,
            content: 'Of course! What would you like to know?',
            isRead: true,
          },
          {
            senderId: client1.id,
            content: 'Should I increase the weights this week?',
            isRead: false,
          },
        ],
      },
    },
  });

  const chat2 = await prisma.chat.create({
    data: {
      type: 'GROUP',
      name: 'Muscle Builders Group',
      members: {
        create: [
          { userId: trainer1.id, role: 'ADMIN' },
          { userId: client1.id, role: 'MEMBER' },
          { userId: client2.id, role: 'MEMBER' },
        ],
      },
      messages: {
        create: [
          {
            senderId: trainer1.id,
            content: "Welcome to the group! Let's crush our goals together!",
            isRead: true,
          },
        ],
      },
    },
  });

  // ============================================================
  // NOTIFICATIONS
  // ============================================================
  logger.info('Creating notifications...');

  await prisma.notification.createMany({
    data: [
      {
        userId: client1.id,
        type: 'WORKOUT_REMINDER',
        title: 'Workout Reminder',
        body: 'You have a workout scheduled for today!',
        isRead: false,
      },
      {
        userId: client1.id,
        type: 'MESSAGE',
        title: 'New Message',
        body: 'John Trainer sent you a message',
        isRead: false,
      },
      {
        userId: client2.id,
        type: 'COACHING_ACCEPTED',
        title: 'Coaching Request Accepted',
        body: 'Your coaching request has been accepted!',
        isRead: true,
      },
      {
        userId: client3.id,
        type: 'ORDER_UPDATE',
        title: 'Order Shipped',
        body: 'Your order has been shipped!',
        data: JSON.parse('{"orderId":"' + order2.id + '"}'),
        isRead: false,
      },
    ],
  });

  logger.info('✅ Comprehensive seed completed successfully!');
  logger.info('');
  logger.info('📊 Summary:');
  logger.info('  - Users: 8 (1 admin, 2 trainers, 3 clients, 2 sellers)');
  logger.info('  - Exercises: 5');
  logger.info('  - Workouts: 3');
  logger.info('  - Meals: 3');
  logger.info('  - Products: 4');
  logger.info('  - Orders: 2');
  logger.info('  - Chats: 2');
  logger.info('  - And much more...');
  logger.info('');
  logger.info('🔑 Login credentials:');
  logger.info('  Admin: admin@gymapp.com / Admin@1234');
  logger.info('  Trainer 1: john.trainer@gymapp.com / Trainer@1234');
  logger.info('  Trainer 2: sarah.coach@gymapp.com / Trainer@1234');
  logger.info('  Client 1: mike.client@gymapp.com / Client@1234');
  logger.info('  Client 2: emma.fit@gymapp.com / Client@1234');
  logger.info('  Client 3: alex.runner@gymapp.com / Client@1234');
  logger.info('  Seller 1: nutrition.seller@gymapp.com / Seller@1234');
  logger.info('  Seller 2: fitgear.store@gymapp.com / Seller@1234');
}

main()
  .catch((e) => {
    logger.error('❌ Seeding failed:');
    logger.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
