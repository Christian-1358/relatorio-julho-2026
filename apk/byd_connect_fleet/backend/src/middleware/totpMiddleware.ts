import { Request, Response, NextFunction } from 'express';
import { authenticator } from 'otplib';
import prisma from '../config/database.js';

export const verifyTOTP = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  const { userId, code } = req.body;

  if (!userId || !code) {
    res.status(400).json({ error: 'userId and code are required' });
    return;
  }

  try {
    const user = await prisma.user.findUnique({ where: { id: userId } });

    if (!user || !user.totpSecret || !user.totpEnabled) {
      res.status(400).json({ error: '2FA not configured for this user' });
      return;
    }

    const isValid = authenticator.verify({ token: code, secret: user.totpSecret });

    if (!isValid) {
      res.status(401).json({ error: 'Invalid 2FA code' });
      return;
    }

    next();
  } catch (error) {
    next(error);
  }
};

export const generateTOTPSecret = (email: string): string => {
  return authenticator.generateSecret();
};

export const generateTOTPQRCode = async (email: string, secret: string): Promise<string> => {
  const QRCode = await import('qrcode');
  const otpauth = authenticator.keyuri(email, 'BYD Connect Fleet', secret);
  return QRCode.default.toDataURL(otpauth);
};
