import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { authenticator } from 'otplib';
import prisma from '../config/database.js';
import { generateTOTPQRCode } from '../middleware/totpMiddleware.js';

const JWT_SECRET = process.env.JWT_SECRET!;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET!;

export interface LoginResult {
  success: boolean;
  requires2FA?: boolean;
  userId?: string;
  accessToken?: string;
  refreshToken?: string;
  error?: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export const authService = {
  async validateCredentials(email: string, password: string): Promise<string | null> {
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) return null;

    const isValid = await bcrypt.compare(password, user.passwordHash);
    return isValid ? user.id : null;
  },

  async login(email: string, password: string): Promise<LoginResult> {
    try {
      const userId = await this.validateCredentials(email, password);
      if (!userId) {
        return { success: false, error: 'Invalid credentials' };
      }

      const user = await prisma.user.findUnique({ where: { id: userId } });

      if (user?.totpEnabled) {
        return { success: true, requires2FA: true, userId };
      }

      const tokens = this.generateTokens(userId, user?.role || 'USER');
      await this.saveRefreshToken(userId, tokens.refreshToken);

      return {
        success: true,
        userId,
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      };
    } catch (error) {
      console.error('Login error:', error);
      return { success: false, error: 'Login failed' };
    }
  },

  async verify2FA(userId: string, code: string): Promise<LoginResult> {
    try {
      const user = await prisma.user.findUnique({ where: { id: userId } });
      if (!user || !user.totpSecret) {
        return { success: false, error: '2FA not configured' };
      }

      const isValid = authenticator.verify({ token: code, secret: user.totpSecret });
      if (!isValid) {
        return { success: false, error: 'Invalid 2FA code' };
      }

      const tokens = this.generateTokens(userId, user.role);
      await this.saveRefreshToken(userId, tokens.refreshToken);

      return {
        success: true,
        userId,
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      };
    } catch (error) {
      console.error('2FA verification error:', error);
      return { success: false, error: '2FA verification failed' };
    }
  },

  async setup2FA(userId: string): Promise<{ secret: string; qrCode: string } | { error: string }> {
    try {
      const user = await prisma.user.findUnique({ where: { id: userId } });
      if (!user) {
        return { error: 'User not found' };
      }

      const secret = authenticator.generateSecret();
      const qrCode = await generateTOTPQRCode(user.email, secret);

      await prisma.user.update({
        where: { id: userId },
        data: { totpSecret: secret },
      });

      return { secret, qrCode };
    } catch (error) {
      console.error('2FA setup error:', error);
      return { error: 'Failed to setup 2FA' };
    }
  },

  async enable2FA(userId: string, code: string): Promise<{ success: boolean; error?: string }> {
    try {
      const user = await prisma.user.findUnique({ where: { id: userId } });
      if (!user || !user.totpSecret) {
        return { success: false, error: '2FA not setup' };
      }

      const isValid = authenticator.verify({ token: code, secret: user.totpSecret });
      if (!isValid) {
        return { success: false, error: 'Invalid verification code' };
      }

      await prisma.user.update({
        where: { id: userId },
        data: { totpEnabled: true },
      });

      return { success: true };
    } catch (error) {
      console.error('Enable 2FA error:', error);
      return { success: false, error: 'Failed to enable 2FA' };
    }
  },

  async refreshAccessToken(refreshToken: string): Promise<AuthTokens | { error: string }> {
    try {
      const decoded = jwt.verify(refreshToken, JWT_REFRESH_SECRET) as { userId: string };

      const user = await prisma.user.findUnique({ where: { id: decoded.userId } });
      if (!user || user.refreshToken !== refreshToken) {
        return { error: 'Invalid refresh token' };
      }

      const tokens = this.generateTokens(decoded.userId, user.role);
      await this.saveRefreshToken(decoded.userId, tokens.refreshToken);

      return tokens;
    } catch (error) {
      return { error: 'Invalid refresh token' };
    }
  },

  async logout(userId: string): Promise<void> {
    await prisma.user.update({
      where: { id: userId },
      data: { refreshToken: null },
    });
  },

  generateTokens(userId: string, role: string): AuthTokens {
    const accessToken = jwt.sign({ userId, role }, JWT_SECRET, { expiresIn: '15m' });
    const refreshToken = jwt.sign({ userId }, JWT_REFRESH_SECRET, { expiresIn: '7d' });
    return { accessToken, refreshToken };
  },

  async saveRefreshToken(userId: string, refreshToken: string): Promise<void> {
    await prisma.user.update({
      where: { id: userId },
      data: { refreshToken },
    });
  },

  async registerUser(
    email: string,
    password: string,
    name: string
  ): Promise<{ success: boolean; userId?: string; error?: string }> {
    try {
      const existing = await prisma.user.findUnique({ where: { email } });
      if (existing) {
        return { success: false, error: 'Email already registered' };
      }

      const passwordHash = await bcrypt.hash(password, 12);
      const user = await prisma.user.create({
        data: { email, passwordHash, name },
      });

      return { success: true, userId: user.id };
    } catch (error) {
      console.error('Registration error:', error);
      return { success: false, error: 'Registration failed' };
    }
  },
};
