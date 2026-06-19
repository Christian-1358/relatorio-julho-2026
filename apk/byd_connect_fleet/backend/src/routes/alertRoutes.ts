import { Router } from 'express';
import { alertController } from '../controllers/alertController.js';
import { authenticateToken } from '../middleware/authMiddleware.js';

const router = Router();

router.use(authenticateToken);

router.get('/', alertController.getAlerts);
router.get('/unread-count', alertController.getUnreadCount);
router.post('/', alertController.createAlert);
router.put('/:id/read', alertController.markAsRead);
router.put('/read-all', alertController.markAllAsRead);

export default router;
