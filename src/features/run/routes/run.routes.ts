import { Router } from 'express';
import { authenticate } from '@shared/guards/auth.guard';

const router = Router();

// TODO: implement run routes
router.get('/', authenticate, (_req, res) => {
  res.json({ success: true, module: 'run', status: 'coming soon' });
});

export default router;
