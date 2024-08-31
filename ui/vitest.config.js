import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.js'],
    mockReset: true,
    include: ['**/__tests__/*.test.{js,jsx}'],
    exclude: [
      'tests/**', // Exclude Playwright tests
      '*.config.js',
      '*.setup.js',
    ],
    coverage: {
      provider: 'istanbul',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'dist/',
        'tests/**', // Exclude Playwright tests
        '*.setup.js',
        './*.config.js',
        'src/**/*.test.{js,jsx}',
      ],
    },
  },
});
