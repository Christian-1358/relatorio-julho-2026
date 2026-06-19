import { Request, Response, NextFunction } from 'express';
import { authService } from '../services/authService.js';

export const authController = {
  async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { email, password } = req.body;
      if (!email || !password) {
        res.status(400).json({ error: 'Email and password required' });
        return;
      }

      const result = await authService.login(email, password);

      if (!result.success) {
        res.status(401).json({ error: result.error });
        return;
      }

      if (result.requires2FA) {
        res.json({ requires2FA: true, userId: result.userId });
        return;
      }

      res.json({
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        userId: result.userId,
      });
    } catch (error) {
      next(error);
    }
  },

  async verify2FA(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { userId, code } = req.body;
      if (!userId || !code) {
        res.status(400).json({ error: 'userId and code required' });
        return;
      }

      const result = await authService.verify2FA(userId, code);

      if (!result.success) {
        res.status(401).json({ error: result.error });
        return;
      }

      res.json({
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        userId: result.userId,
      });
    } catch (error) {
      next(error);
    }
  },

  async refresh(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { refreshToken } = req.body;
      if (!refreshToken) {
        res.status(400).json({ error: 'Refresh token required' });
        return;
      }

      const result = await authService.refreshAccessToken(refreshToken);

      if ('error' in result) {
        res.status(401).json({ error: result.error });
        return;
      }

      res.json(result);
    } catch (error) {
      next(error);
    }
  },

  async logout(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = (req as any).userId;
      await authService.logout(userId);
      res.json({ success: true });
    } catch (error) {
      next(error);
    }
  },

  async register(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { email, password, name } = req.body;
      if (!email || !password || !name) {
        res.status(400).json({ error: 'Email, password and name required' });
        return;
      }

      const result = await authService.registerUser(email, password, name);

      if (!result.success) {
        res.status(400).json({ error: result.error });
        return;
      }

      res.status(201).json({ userId: result.userId });
    } catch (error) {
      next(error);
    }
  },

  async setup2FA(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = (req as any).userId;
      const result = await authService.setup2FA(userId);

      if ('error' in result) {
        res.status(400).json({ error: result.error });
        return;
      }

      res.json(result);
    } catch (error) {
      next(error);
    }
  },

  async enable2FA(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = (req as any).userId;
      const { code } = req.body;

      const result = await authService.enable2FA(userId, code);

      if (!result.success) {
        res.status(400).json({ error: result.error });
        return;
      }

      res.json({ success: true });
    } catch (error) {
      next(error);
    }
  },

  async forgotPassword(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { email } = req.body;
      if (!email) {
        res.status(400).json({ error: 'Email required' });
        return;
      }

      // In production, this would send an email with reset link
      // For demo, we just return success
      res.json({ message: 'If an account exists, a reset link has been sent' });
    } catch (error) {
      // Always return success to prevent email enumeration
      res.json({ message: 'If an account exists, a reset link has been sent' });
    }
  },

  async resetPassword(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { token, newPassword } = req.body;
      if (!token || !newPassword) {
        res.status(400).json({ error: 'Token and new password required' });
        return;
      }

      // In production, this would verify token and reset password
      res.json({ success: true, message: 'Password has been reset' });
    } catch (error) {
      next(error);
    }
  },
};
