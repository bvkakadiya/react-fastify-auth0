#!/bin/bash

# Create Vite project in a temporary folder
npm create vite@latest tempUI -- --template react
cd tempUI

# Install TailwindCSS
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# Configure TailwindCSS
echo "export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {},
  },
  plugins: [],
}" > tailwind.config.js

# Add Tailwind directives to CSS
mkdir -p src
echo "@tailwind base;
@tailwind components;
@tailwind utilities;" > src/index.css

# Unit test setup with Vitest
npm install -D vitest @testing-library/react @vitest/ui c8 jsdom @testing-library/dom @testing-library/jest-dom

# Configure Vitest
echo "import { defineConfig } from 'vite';
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
      provider: 'c8',
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
});" > vitest.config.js

# Create setup file for test
echo "import '@testing-library/jest-dom/vitest'
import { cleanup } from '@testing-library/react'
import { afterEach } from 'vitest'

afterEach(() => {
  cleanup()
})
" > vitest.setup.js
# sed -i "/globals: globals.browser,/c\ \ \ \ globals: { ...globals.browser, 'vitest/globals': true }," eslint.config.js

# Create sample test file
mkdir -p src/__tests__
echo "import { render, screen } from '@testing-library/react';
import App from '../App';

test('renders learn react link', () => {
  render(<App />);
  const linkElement = screen.getByText(/Click on the Vite and React logos to learn more/i);
  expect(linkElement).toBeInTheDocument();
});" > src/__tests__/App.test.jsx

# Update script file with test command
sed -i '/"scripts": {/a \ \ \ \ "test": "vitest",' package.json
sed -i '/"scripts": {/a \ \ \ \ "test:ui": "vitest --ui",' package.json
sed -i '/"scripts": {/a \ \ \ \ "test:coverage": "vitest run --coverage",' package.json
sed -i "/settings: {/a \ \ \ \ env: { 'vitest/globals': true }," eslint.config.js

# Install Playwright & Initialize Playwright
npm install -D playwright @playwright/test
npx playwright install

# Troubleshooting: Missing Dependencies for Browsers
sudo npx playwright install-deps
sudo apt-get install libevent-2.1-7 libgstreamer-plugins-bad1.0-0 libflite1 gstreamer1.0-libav

# Setup Playwright config
echo "// playwright.config.js
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests', // Directory where your tests are located
  timeout: 30000, // Timeout for each test in milliseconds
  retries: 2, // Number of retries for failed tests
  use: {
    headless: true, // Run tests in headless mode
    viewport: { width: 1280, height: 720 }, // Default viewport size
    ignoreHTTPSErrors: true, // Ignore HTTPS errors
    video: 'retain-on-failure', // Record video only on test failure
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    // {
    //   name: 'firefox',
    //   use: { ...devices['Desktop Firefox'] },
    // },
    // {
    //   name: 'webkit',
    //   use: { ...devices['Desktop Safari'] },
    // },
  ],
});" > playwright.config.js

# Create a Sample E2E Test
mkdir -p tests
echo "import { test, expect } from '@playwright/test';

test('basic test', async ({ page }) => {
  await page.goto('http://localhost:5173/');
  const title = await page.title();
  expect(title).toBe('React App');
});" > tests/example.spec.js
sed -i '/"scripts": {/a \ \ \ \ "test:e2e": "playwright test",' package.json
sed -i '/"scripts": {/a \ \ \ \ "test:e2e:headed": "playwright test --headed",' package.json
sed -i '/"scripts": {/a \ \ \ \ "test:e2e:debug": "playwright test --debug",' package.json

# Setup Auth0 in project
# Step 1: Install Auth0 React SDK
npm install @auth0/auth0-react react-router-dom

# Step 2: Create .env file for Vite project
echo "VITE_AUTH0_DOMAIN='dev-bk.auth0.com'
VITE_AUTH0_CLIENT_ID=YOUR_AUTH0_CLIENT_ID" > .env

# Step 3: Update index.js to include Auth0Provider
echo "import {StrictMode } from 'react';
import {createRoot} from 'react-dom/client';
import { Auth0Provider } from '@auth0/auth0-react';
import App from './App.jsx';
import './index.css'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <Auth0Provider
      domain={import.meta.env.VITE_AUTH0_DOMAIN}
      clientId={import.meta.env.VITE_AUTH0_CLIENT_ID}
      authorizationParams={{
        redirect_uri: window.location.origin
      }}
    >
      <App />
    </Auth0Provider>
  </StrictMode>);
" > src/main.jsx

# Step 4: Create custom hook for Auth0
mkdir -p src/hooks
echo "import { useAuth0 } from '@auth0/auth0-react';

const useAuth = () => {
  const { loginWithRedirect, logout, user, isAuthenticated, isLoading } = useAuth0();

  return {
    loginWithRedirect,
    logout,
    user,
    isAuthenticated,
    isLoading,
  };
};

export default useAuth;" > src/hooks/useAuth.js

# Step 5: Create ProtectedRoute component
mkdir -p src/components
echo "import React from 'react'
import { Navigate } from 'react-router-dom'
import { useAuth0 } from '@auth0/auth0-react'

const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, isLoading } = useAuth0()

  if (isLoading) {
    return <div>Loading...</div>
  }

  if (!isAuthenticated) {
    return <Navigate to='/login' />
  }
  return <>{children}</>
}

export default ProtectedRoute
" > src/components/ProtectedRoute.jsx

# Step 6: Create LoginButton component
echo "import React from 'react';
import useAuth from '../hooks/useAuth';

const LoginButton = () => {
  const { loginWithRedirect } = useAuth();

  return <button onClick={() => loginWithRedirect()}>Log In</button>;
};

export default LoginButton;" > src/components/LoginButton.jsx

# Step 7: Create LogoutButton component
echo "import React from 'react';
import useAuth from '../hooks/useAuth';

const LogoutButton = () => {
  const { logout } = useAuth();

  return <button onClick={() => logout({ returnTo: window.location.origin })}>Log Out</button>;
};

export default LogoutButton;" > src/components/LogoutButton.jsx

# Move tempUI to UI, replacing existing files
cd ..
rm -rf ui
mv tempUI ui


# Update package.json name property
sed -i 's/"name": "tempui"/"name": "ui"/' ui/package.json