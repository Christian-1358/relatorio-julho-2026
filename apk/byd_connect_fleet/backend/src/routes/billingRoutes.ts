import { Router } from 'express';
import { billingController } from '../controllers/billingController.js';
import { authenticateToken } from '../middleware/authMiddleware.js';

const router = Router();

router.get('/plans', billingController.getPlans);
router.get('/subscription', authenticateToken, billingController.getSubscription);
router.post('/subscription', authenticateToken, billingController.createSubscription);
router.put('/subscription/:subscriptionId/cancel', authenticateToken, billingController.cancelSubscription);

export default router;
