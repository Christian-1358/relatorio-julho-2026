/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#1E88E5',
        accent: '#00D9A5',
        background: '#0D1117',
        surface: '#161B22',
        surfaceLight: '#21262D',
        online: '#00D9A5',
        offline: '#8B949E',
        warning: '#FFB300',
        error: '#FF5252',
        locked: '#FF5252',
        unlocked: '#00E676',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
