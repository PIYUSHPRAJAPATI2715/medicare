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
          50: '#ebf5ff',
          100: '#dbeafe',
          500: '#1a56db',
          600: '#1e429f',
          700: '#1e3a8a',
        },
      },
    },
  },
  plugins: [],
}
