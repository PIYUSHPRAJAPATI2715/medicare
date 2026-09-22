/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#F0F7FF',
          100: '#E0F0FE',
          500: '#1D4ED8',
          600: '#1E40AF',
          700: '#1D4ED8',
        }
      }
    },
  },
  plugins: [],
}
