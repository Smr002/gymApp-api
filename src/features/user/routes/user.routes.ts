import { Router } from 'express';
import { authenticate } from '@shared/guards/auth.guard';

const router = Router();

// TODO: implement user routes
router.get('/', authenticate, (_req, res) => {
  res.json({ success: true, module: 'user', status: 'coming soon' });
});

export default router;
