import { Router } from 'express';
import { authController } from '../controllers/authController.js';
import { authenticateToken } from '../middleware/authMiddleware.js';

const router = Router();

router.post('/login', authController.login);
router.post('/verify-2fa', authController.verify2FA);
router.post('/refresh', authController.refresh);
router.post('/register', authController.register);
router.post('/logout', authenticateToken, authController.logout);
router.post('/setup-2fa', authenticateToken, authController.setup2FA);
router.post('/enable-2fa', authenticateToken, authController.enable2FA);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);

export default router;
