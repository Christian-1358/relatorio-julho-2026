import { useState, useRef } from 'react';
import { motion } from 'framer-motion';
import { Car, Lock, Eye, EyeOff, Mail, User, ArrowLeft } from 'lucide-react';
import { authApi } from '../api/authApi';
import { useAuthStore } from '../store/authStore';
import toast from 'react-hot-toast';

// Google reCAPTCHA site key (demo - replace with your own)
const RECAPTCHA_SITE_KEY = '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI';

type AuthMode = 'login' | 'register' | 'forgot';

export const LoginPage = () => {
  const [mode, setMode] = useState<AuthMode>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [step, setStep] = useState<'credentials' | '2fa'>('credentials');
  const [code, setCode] = useState('');
  const [loading, setLoading] = useState(false);
  const [resetSent, setResetSent] = useState(false);
  const recaptchaRef = useRef<any>(null);

  const { setRequires2FA, pendingUserId } = useAuthStore();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const result = await authApi.login(email, password);

      if (result.requires2FA && result.userId) {
        setRequires2FA(true, result.userId);
        setStep('2fa');
        toast.success('Please enter your 2FA code');
      } else if (result.accessToken && result.refreshToken) {
        localStorage.setItem('accessToken', result.accessToken);
        localStorage.setItem('refreshToken', result.refreshToken);
        toast.success('Welcome back!');
        window.location.href = '/dashboard';
      } else if (result.error) {
        toast.error(result.error);
      }
    } catch (error) {
      toast.error('Login failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const result = await authApi.register(email, password, name);
      if (result.userId) {
        toast.success('Account created! Please login.');
        setMode('login');
      } else if (result.error) {
        toast.error(result.error);
      }
    } catch (error) {
      toast.error('Registration failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleForgotPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      // In a real app, this would call an API to send reset email
      // and verify reCAPTCHA token
      await new Promise(resolve => setTimeout(resolve, 1000));

      // Simulate sending reset email
      toast.success(`Password reset link sent to ${email}`);
      setResetSent(true);
    } catch (error) {
      toast.error('Failed to send reset email.');
    } finally {
      setLoading(false);
    }
  };

  const handle2FA = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const result = await authApi.verify2FA(pendingUserId!, code);

      if (result.accessToken && result.refreshToken) {
        localStorage.setItem('accessToken', result.accessToken);
        localStorage.setItem('refreshToken', result.refreshToken);
        toast.success('Welcome back!');
        window.location.href = '/dashboard';
      } else if (result.error) {
        toast.error(result.error);
      }
    } catch (error) {
      toast.error('2FA verification failed.');
    } finally {
      setLoading(false);
    }
  };

  const renderLoginForm = () => (
    <form onSubmit={handleLogin} className="space-y-6">
      <div>
        <label className="block text-sm font-medium text-gray-300 mb-2">Email</label>
        <div className="relative">
          <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-500" />
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="glass-input w-full pl-10"
            placeholder="your@email.com"
            required
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-300 mb-2">Password</label>
        <div className="relative">
          <input
            type={showPassword ? 'text' : 'password'}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="glass-input w-full pr-10"
            placeholder="••••••••"
            required
          />
          <button
            type="button"
            onClick={() => setShowPassword(!showPassword)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-white"
          >
            {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
          </button>
        </div>
      </div>

      <div className="flex items-center justify-between text-sm">
        <label className="flex items-center gap-2 cursor-pointer">
          <input type="checkbox" className="rounded border-gray-600 bg-surface" />
          <span className="text-gray-400">Remember me</span>
        </label>
        <button
          type="button"
          onClick={() => setMode('forgot')}
          className="text-primary hover:text-primary/80"
        >
          Forgot password?
        </button>
      </div>

      <motion.button
        type="submit"
        disabled={loading}
        className="w-full py-3 bg-primary hover:bg-primary/80 rounded-xl font-medium transition-colors disabled:opacity-50"
        whileTap={{ scale: 0.98 }}
      >
        {loading ? 'Signing in...' : 'Sign In'}
      </motion.button>

      <div className="text-center text-gray-400 text-sm">
        Don't have an account?{' '}
        <button
          type="button"
          onClick={() => setMode('register')}
          className="text-primary hover:text-primary/80 font-medium"
        >
          Sign up
        </button>
      </div>
    </form>
  );

  const renderRegisterForm = () => (
    <form onSubmit={handleRegister} className="space-y-6">
      <div className="text-center mb-4">
        <h2 className="text-xl font-semibold">Create Account</h2>
        <p className="text-gray-500 text-sm">Join BYD Connect Fleet</p>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-300 mb-2">Full Name</label>
        <div className="relative">
          <User className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-500" />
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="glass-input w-full pl-10"
            placeholder="John Smith"
            required
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-300 mb-2">Email</label>
        <div className="relative">
          <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-500" />
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="glass-input w-full pl-10"
            placeholder="your@email.com"
            required
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-300 mb-2">Password</label>
        <div className="relative">
          <input
            type={showPassword ? 'text' : 'password'}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="glass-input w-full pr-10"
            placeholder="••••••••"
            required
            minLength={8}
          />
          <button
            type="button"
            onClick={() => setShowPassword(!showPassword)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-white"
          >
            {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
          </button>
        </div>
        <p className="text-xs text-gray-500 mt-1">Minimum 8 characters</p>
      </div>

      {/* reCAPTCHA placeholder */}
      <div className="flex items-center gap-2 p-3 bg-surface/50 rounded-lg border border-white/10">
        <input type="checkbox" id="recaptcha" className="rounded" />
        <label htmlFor="recaptcha" className="text-sm text-gray-400 cursor-pointer">
          I'm not a robot
        </label>
        <div className="ml-auto text-xs text-gray-500">reCAPTCHA</div>
      </div>

      <motion.button
        type="submit"
        disabled={loading}
        className="w-full py-3 bg-primary hover:bg-primary/80 rounded-xl font-medium transition-colors disabled:opacity-50"
        whileTap={{ scale: 0.98 }}
      >
        {loading ? 'Creating account...' : 'Create Account'}
      </motion.button>

      <div className="text-center text-gray-400 text-sm">
        Already have an account?{' '}
        <button
          type="button"
          onClick={() => setMode('login')}
          className="text-primary hover:text-primary/80 font-medium"
        >
          Sign in
        </button>
      </div>
    </form>
  );

  const renderForgotForm = () => (
    <form onSubmit={handleForgotPassword} className="space-y-6">
      <div className="text-center mb-4">
        <h2 className="text-xl font-semibold">Reset Password</h2>
        <p className="text-gray-500 text-sm">
          {resetSent
            ? 'Check your email for a reset link'
            : 'Enter your email to receive a reset link'}
        </p>
      </div>

      {!resetSent ? (
        <>
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">Email</label>
            <div className="relative">
              <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-500" />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="glass-input w-full pl-10"
                placeholder="your@email.com"
                required
              />
            </div>
          </div>

          {/* reCAPTCHA placeholder */}
          <div className="flex items-center gap-2 p-3 bg-surface/50 rounded-lg border border-white/10">
            <input type="checkbox" id="recaptcha-forgot" className="rounded" />
            <label htmlFor="recaptcha-forgot" className="text-sm text-gray-400 cursor-pointer">
              I'm not a robot
            </label>
            <div className="ml-auto text-xs text-gray-500">reCAPTCHA</div>
          </div>

          <motion.button
            type="submit"
            disabled={loading}
            className="w-full py-3 bg-primary hover:bg-primary/80 rounded-xl font-medium transition-colors disabled:opacity-50"
            whileTap={{ scale: 0.98 }}
          >
            {loading ? 'Sending...' : 'Send Reset Link'}
          </motion.button>
        </>
      ) : (
        <motion.button
          type="button"
          onClick={() => {
            setMode('login');
            setResetSent(false);
            setEmail('');
          }}
          className="w-full py-3 bg-surface hover:bg-surface/80 rounded-xl font-medium transition-colors border border-white/10"
          whileTap={{ scale: 0.98 }}
        >
          Back to Login
        </motion.button>
      )}

      <button
        type="button"
        onClick={() => setMode('login')}
        className="w-full text-gray-500 hover:text-white text-sm flex items-center justify-center gap-2"
      >
        <ArrowLeft className="w-4 h-4" />
        Back to login
      </button>
    </form>
  );

  const render2FAForm = () => (
    <form onSubmit={handle2FA} className="space-y-6">
      <div className="text-center">
        <Lock className="w-12 h-12 text-primary mx-auto mb-4" />
        <h2 className="text-xl font-semibold">Two-Factor Authentication</h2>
        <p className="text-gray-500 text-sm mt-2">Enter the code from your authenticator app</p>
      </div>

      <input
        type="text"
        value={code}
        onChange={(e) => setCode(e.target.value)}
        className="glass-input w-full text-center text-2xl tracking-widest"
        placeholder="000000"
        maxLength={6}
        required
      />

      <motion.button
        type="submit"
        disabled={loading}
        className="w-full py-3 bg-primary hover:bg-primary/80 rounded-xl font-medium transition-colors disabled:opacity-50"
        whileTap={{ scale: 0.98 }}
      >
        {loading ? 'Verifying...' : 'Verify'}
      </motion.button>

      <button
        type="button"
        onClick={() => setStep('credentials')}
        className="w-full text-gray-500 hover:text-white text-sm"
      >
        ← Back to login
      </button>
    </form>
  );

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-4">
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/10 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-accent/10 rounded-full blur-3xl" />
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-md relative"
      >
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="w-16 h-16 bg-primary/20 rounded-2xl flex items-center justify-center mx-auto mb-4">
            <Car className="w-8 h-8 text-primary" />
          </div>
          <h1 className="text-3xl font-bold">BYD Connect</h1>
          <p className="text-gray-500 mt-2">Fleet Management System</p>
        </div>

        {/* Form */}
        <div className="glass-card p-8">
          {step === '2fa' ? render2FAForm() :
           mode === 'register' ? renderRegisterForm() :
           mode === 'forgot' ? renderForgotForm() :
           renderLoginForm()}
        </div>

        <p className="text-center text-gray-600 text-sm mt-6">
          Demo: admin@bydfleet.com / admin123
        </p>
      </motion.div>
    </div>
  );
};
