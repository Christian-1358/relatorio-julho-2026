export interface User {
  id: string;
  email: string;
  name: string;
  role: 'USER' | 'ADMIN';
  totpEnabled: boolean;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface LoginResponse {
  requires2FA?: boolean;
  userId?: string;
  accessToken?: string;
  refreshToken?: string;
  error?: string;
}
