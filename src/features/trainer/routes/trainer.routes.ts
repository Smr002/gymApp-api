import { Router } from 'express';
import { authenticate } from '@shared/guards/auth.guard';

const router = Router();

// TODO: implement trainer routes
router.get('/', authenticate, (_req, res) => {
  res.json({ success: true, module: 'trainer', status: 'coming soon' });
});

export default router;
