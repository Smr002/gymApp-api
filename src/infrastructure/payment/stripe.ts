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
