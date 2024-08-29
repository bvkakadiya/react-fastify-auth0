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
# Step 8: Create Profile component
echo "import { useAuth0 } from '@auth0/auth0-react';

const Profile = () => {
  const { user, isAuthenticated } = useAuth0();

  if (!isAuthenticated) {
    return null;
  }

  return (
    <div>
      <img src={user.picture} alt={user.name} />
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  );
};

export default Profile;" > src/components/Profile.jsx

# Step 9: Create Header component
echo "import { useAuth0 } from '@auth0/auth0-react';
import LoginButton from './LoginButton';
import LogoutButton from './LogoutButton';
import Profile from './Profile';

const Header = () => {
  const { isAuthenticated } = useAuth0();

  return (
    <header className='bg-gray-800 text-white p-4 flex justify-between items-center'>
      <div className='text-xl font-bold'>App Name</div>
      <div className='flex items-center space-x-4'>
        {isAuthenticated ? (
          <>
            <Profile />
            <LogoutButton />
          </>
        ) : (
          <LoginButton />
        )}
      </div>
    </header>
  );
};

export default Header;" > src/components/Header.jsx

# Step 9: Update App component to include Auth0 components
mkdir -p src/components
echo "import React from 'react';

const Home = () => {
  return (
    <div>
      <h1>Home</h1>
      <p>Welcome to the Home page!</p>
    </div>
  );
};

export default Home;
" > src/components/Home.jsx

echo "import React from 'react';
import { render, screen } from '@testing-library/react';
import Home from '../Home';

describe('Home', () => {
  it('renders the Home component', () => {
    render(<Home />);
    expect(screen.getByText('Home')).toBeInTheDocument();
    expect(screen.getByText('Welcome to the Home page!')).toBeInTheDocument();
  });
});
" > src/components/__tests__/Home.test.jsx

echo "import { Route, Routes } from 'react-router-dom'
import Header from './components/Header'
import LoginButton from './components/LoginButton'
import LogoutButton from './components/LogoutButton'
import Profile from './components/Profile'
import ProtectedRoute from './components/ProtectedRoute'
import Home from './components/Home'
import Dashboard from './components/Dashboard'

const App = () => {
  return (
      <div className='flex flex-col min-h-screen'>
        <Header />
        <main className='flex-grow'>
          <Routes>
            <Route path='/' element={<Home />} />
            <Route path='/login' element={<LoginButton />} />
            <Route
              path='/dashboard'
              element={
                <ProtectedRoute>
                  <Dashboard />
                </ProtectedRoute>
              }
            />
          </Routes>
        </main>
      </div>
  )
}

export default App
" > src/App.jsx

# Step 10: Create test for LoginButton component
mkdir -p src/components/__tests__
echo "import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import LoginButton from '../LoginButton';
import { useAuth0 } from '@auth0/auth0-react';

vi.mock('@auth0/auth0-react');

describe('LoginButton', () => {
  it('renders login button', () => {
    const loginWithRedirect = vi.fn();

    useAuth0.mockReturnValue({
      loginWithRedirect,
    });

    render(<LoginButton />);
    const buttonElement = screen.getByText(/Log In/i);
    expect(buttonElement).toBeInTheDocument();
    buttonElement.click();
    expect(loginWithRedirect).toHaveBeenCalled();
  });
});" > src/components/__tests__/LoginButton.test.jsx

# Step 11: Create test for LogoutButton component
echo "import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import LogoutButton from '../LogoutButton';
import { useAuth0 } from '@auth0/auth0-react';

vi.mock('@auth0/auth0-react');

describe('LogoutButton', () => {
  it('renders logout button', () => {
    const logout = vi.fn();

    useAuth0.mockReturnValue({
      logout,
    });

    render(<LogoutButton />);
    const buttonElement = screen.getByText(/Log Out/i);
    expect(buttonElement).toBeInTheDocument();
    buttonElement.click();
    expect(logout).toHaveBeenCalledWith({ returnTo: window.location.origin });
  });
});" > src/components/__tests__/LogoutButton.test.jsx

# Step 12: Create test for Profile component
echo "import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import Profile from '../Profile';
import { useAuth0 } from '@auth0/auth0-react';

vi.mock('@auth0/auth0-react');

describe('Profile', () => {
  it('renders profile component', () => {
    const user = {
      name: 'John Doe',
      email: 'john.doe@example.com',
      picture: 'https://via.placeholder.com/150',
    };

    useAuth0.mockReturnValue({
      isAuthenticated: true,
      user,
    });

    render(<Profile />);
    const nameElement = screen.getByText(/John Doe/i);
    const emailElement = screen.getByText(/john.doe@example.com/i);
    expect(nameElement).toBeInTheDocument();
    expect(emailElement).toBeInTheDocument();
  });
});" > src/components/__tests__/Profile.test.jsx

# Step 13: Create test for ProtectedRoute component
echo "import React from 'react';
import { render, screen } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { useAuth0 } from '@auth0/auth0-react';
import ProtectedRoute from '../ProtectedRoute';
import { vi } from 'vitest';

vi.mock('@auth0/auth0-react');

describe('ProtectedRoute', () => {
  it('renders loading state when isLoading is true', () => {
    useAuth0.mockReturnValue({
      isLoading: true,
      isAuthenticated: false,
    });

    render(
      <BrowserRouter>
        <ProtectedRoute />
      </BrowserRouter>
    );

    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('redirects to login when not authenticated', () => {
    useAuth0.mockReturnValue({
      isLoading: false,
      isAuthenticated: false,
    });

    render(
      <BrowserRouter>
        <ProtectedRoute />
      </BrowserRouter>
    );

    expect(screen.queryByText('Loading...')).not.toBeInTheDocument();
    expect(screen.queryByText('Mock Component')).not.toBeInTheDocument();
  });

  it('renders nothing when authenticated', () => {
    useAuth0.mockReturnValue({
      isLoading: false,
      isAuthenticated: true,
    });

    const { container } = render(
      <BrowserRouter>
        <ProtectedRoute />
      </BrowserRouter>
    );

    expect(container).toBeEmptyDOMElement();
  });
});" > src/components/__tests__/ProtectedRoute.test.jsx

# Step 14: Create test for Header component
echo "import { render, screen } from '@testing-library/react';
import { useAuth0 } from '@auth0/auth0-react';
import Header from '../Header';
import { vi } from 'vitest';

vi.mock('@auth0/auth0-react');
vi.mock('../LoginButton', () => ({
  __esModule: true,
  default: () => <div>Login Button</div>,
}));
vi.mock('../LogoutButton', () => ({
  __esModule: true,
  default: () => <div>Logout Button</div>,
}));
vi.mock('../Profile', () => ({
  __esModule: true,
  default: () => <div>Profile</div>,
}));

describe('Header', () => {
  it('renders the App name', () => {
    useAuth0.mockReturnValue({
      isAuthenticated: false,
    });

    render(<Header />);

    expect(screen.getByText('App Name')).toBeInTheDocument();
  });

  it('shows the LoginButton when not authenticated', () => {
    useAuth0.mockReturnValue({
      isAuthenticated: false,
    });

    render(<Header />);

    expect(screen.getByText('Login Button')).toBeInTheDocument();
    expect(screen.queryByText('Profile')).not.toBeInTheDocument();
    expect(screen.queryByText('Logout Button')).not.toBeInTheDocument();
  });

  it('shows the Profile and LogoutButton when authenticated', () => {
    useAuth0.mockReturnValue({
      isAuthenticated: true,
    });

    render(<Header />);

    expect(screen.getByText('Profile')).toBeInTheDocument();
    expect(screen.getByText('Logout Button')).toBeInTheDocument();
    expect(screen.queryByText('Login Button')).not.toBeInTheDocument();
  });
});
" > src/components/__tests__/Header.test.jsx

# Adding redux store

# Install Redux and React-Redux
npm install --save @reduxjs/toolkit react-redux

# Create Redux Store
mkdir -p src/store/features/counter
echo "import { createSlice } from '@reduxjs/toolkit';

const counterSlice = createSlice({
  name: 'counter',
  initialState: {
    value: 0,
  },
  reducers: {
    increment: (state) => {
      state.value += 1;
    },
    decrement: (state) => {
      state.value -= 1;
    },
  },
});

export const { increment, decrement } = counterSlice.actions;

export default counterSlice.reducer;
" > src/store/features/counter/counterSlice.js

echo "import { combineReducers } from '@reduxjs/toolkit';
import counterReducer from './features/counter/counterSlice';

const rootReducer = combineReducers({
  counter: counterReducer,
});

export default rootReducer;
" > src/store/rootReducer.js

echo "import { configureStore } from '@reduxjs/toolkit';
import rootReducer from './rootReducer';

const store = configureStore({
  reducer: rootReducer,
});

export default store;
" > src/store/store.js

# Update main.jsx
echo "import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { Provider } from 'react-redux'
import { Auth0Provider } from '@auth0/auth0-react'
import App from './App.jsx'
import store from './store/store'
import './index.css'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <BrowserRouter>
      <Provider store={store}>
        <Auth0Provider
          domain={import.meta.env.VITE_AUTH0_DOMAIN}
          clientId={import.meta.env.VITE_AUTH0_CLIENT_ID}
          authorizationParams={{
            redirect_uri: window.location.origin,
          }}
        >
          <App />
        </Auth0Provider>
      </Provider>
    </BrowserRouter>
  </StrictMode>
)
" > src/main.jsx

# Create the Dashboard component
mkdir -p src/components
echo "import React from 'react';
import Counter from './Counter';

const Dashboard = () => {
  return (
    <div>
      <h1>Dashboard</h1>
      <Counter />
    </div>
  );
};

export default Dashboard;
" > src/components/Dashboard.jsx

# Create the Counter component
echo "import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { increment, decrement } from '../store/features/counter/counterSlice';

const Counter = () => {
  const count = useSelector((state) => state.counter.value);
  const dispatch = useDispatch();

  return (
    <div>
      <h2>Counter</h2>
      <p>{count}</p>
      <button onClick={() => dispatch(increment())}>Increment</button>
      <button onClick={() => dispatch(decrement())}>Decrement</button>
    </div>
  );
};

export default Counter;
" > src/components/Counter.jsx

# Create unit tests for the Dashboard component
echo "import React from 'react';
import { render, screen } from '@testing-library/react';
import { Provider } from 'react-redux';
import store from '../../store/store';
import Dashboard from '../Dashboard';
import { vi } from 'vitest';

// Mock the Counter component
vi.mock('../Counter', () => ({
  default: () => <div>Mocked Counter</div>
}));

describe('Dashboard', () => {
  it('renders the Dashboard component', () => {
    render(
      <Provider store={store}>
        <Dashboard />
      </Provider>
    );

    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Mocked Counter')).toBeInTheDocument();
  });

  it('renders the Counter component with initial state', () => {
    render(
      <Provider store={store}>
        <Dashboard />
      </Provider>
    );

    expect(screen.getByText('Mocked Counter')).toBeInTheDocument();
  });
});
" > src/components/__tests__/Dashboard.test.jsx

# Create unit tests for the Redux store
mkdir -p src/store/__test__
echo "import store from '../store';
import { increment, decrement } from '../features/counter/counterSlice';

describe('Redux Store', () => {
  it('should have initial state', () => {
    const state = store.getState();
    expect(state.counter.value).toBe(0);
  });

  it('should increment the counter value', () => {
    store.dispatch(increment());
    const state = store.getState();
    expect(state.counter.value).toBe(1);
  });

  it('should decrement the counter value', () => {
    store.dispatch(increment());
    store.dispatch(decrement());
    const state = store.getState();
    expect(state.counter.value).toBe(0);
  });
});
" > src/store/__test__/store.test.js


# Create the utils directory
mkdir -p src/utils

# Create the test-utils.js file with the provided content
echo "import React from 'react'
import { render } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { Provider } from 'react-redux'
import { Auth0Provider, Auth0Context } from '@auth0/auth0-react'
import store from '../store/store'

const defaultAuth0State = {
  isAuthenticated: true,
  isLoading: false,
  user: {
    name: 'John Doe',
    email: 'john.doe@example.com',
  },
  loginWithRedirect: vi.fn(),
  logout: vi.fn(),
}

const renderWithProviders = (
  ui,
  { route = '/', auth0State, ...renderOptions } = {}
) => {
  console.log('route', route)
  const Wrapper = ({ children }) => (
    <MemoryRouter initialEntries={[route]}>
      <Provider store={store}>
        <Auth0Context.Provider value={{ ...defaultAuth0State, ...auth0State }}>
          <Auth0Provider
            domain='test-domain'
            clientId='test-client-id'
            authorizationParams={{
              redirect_uri: window.location.origin,
            }}
          >
            {children}
          </Auth0Provider>
        </Auth0Context.Provider>
      </Provider>
    </MemoryRouter>
  )

  return render(ui, { wrapper: Wrapper, ...renderOptions })
}

export * from '@testing-library/react'
export { renderWithProviders }
" > src/utils/test-utils.js

# Create unit tests for the Counter component
echo "import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { Provider } from 'react-redux';
import store from '../../store/store';
import Counter from '../Counter';

describe('Counter', () => {
  it('renders the Counter component with initial state', () => {
    render(
      <Provider store={store}>
        <Counter />
      </Provider>
    );

    expect(screen.getByText('Counter')).toBeInTheDocument();
    expect(screen.getByText('0')).toBeInTheDocument();
  });

  it('increments the counter value when Increment button is clicked', () => {
    render(
      <Provider store={store}>
        <Counter />
      </Provider>
    );

    fireEvent.click(screen.getByText('Increment'));
    expect(screen.getByText('1')).toBeInTheDocument();
  });

  it('decrements the counter value when Decrement button is clicked', () => {
    render(
      <Provider store={store}>
        <Counter />
      </Provider>
    );

    fireEvent.click(screen.getByText('Increment'));
    fireEvent.click(screen.getByText('Decrement'));
    expect(screen.getByText('1')).toBeInTheDocument();
  });
});
" > src/components/__tests__/Counter.test.jsx

# Create unit tests for the Dashboard component
echo "
import React from 'react';
import { render, screen } from '@testing-library/react';
import { Provider } from 'react-redux';
import store from '../../store/store';
import Dashboard from '../Dashboard';
import { vi } from 'vitest';

// Mock the Counter component
vi.mock('../Counter', () => ({
  default: () => <div>Mocked Counter</div>
}));

describe('Dashboard', () => {
  it('renders the Dashboard component', () => {
    render(
      <Provider store={store}>
        <Dashboard />
      </Provider>
    );

    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Mocked Counter')).toBeInTheDocument();
  });

  it('renders the Counter component with initial state', () => {
    render(
      <Provider store={store}>
        <Dashboard />
      </Provider>
    );

    expect(screen.getByText('Mocked Counter')).toBeInTheDocument();
  });
});" > src/components/__tests__/Dashboard.test.jsx

# Create unit tests for the App component
echo "import React from 'react';
import { render, screen } from '@testing-library/react';
import { renderWithProviders } from '../utils/test-utils';

import App from '../App';
import { vi } from 'vitest';
import { BrowserRouter, MemoryRouter } from 'react-router-dom';

// Mock the components
vi.mock('../components/Home', () => ({
  default: () => <div>Mocked Home</div>,
}));

vi.mock('../components/LoginButton', () => ({
  default: () => <div>Mocked Login</div>,
}));

vi.mock('../components/Dashboard', () => ({
  default: () => <div>Mocked Dashboard</div>,
}));

vi.mock('../components/Counter', () => ({
  default: () => <div>Mocked Counter</div>,
}));

describe('App', () => {
  it('renders the Home component for the root route', () => {
    render(<BrowserRouter initialEntries={['/']}><App /> </BrowserRouter>, { route: '/' });
    expect(screen.getByText('Mocked Home')).toBeInTheDocument();
  });

  it('renders the LoginButton component for the /login route', () => {
    render(<BrowserRouter initialEntries={["/login"]}><App /> </BrowserRouter>, { route: '/login' });
    console.log(window.location.pathname);
    expect(screen.getByText('Mocked Login')).toBeInTheDocument();
  });
  
  it('renders the Dashboard component for the /dashboard route when authenticated', () => {
    render(<BrowserRouter initialEntries={['/dashboard']}><App /> </BrowserRouter>, { route: '/dashboard', auth0State: { isAuthenticated: true } });
    console.log(window.location.pathname);
    console.log(window.location.pathname);
    expect(screen.getByText('Mocked Dashboard')).toBeInTheDocument();
  });
  
  it('renders the LoginButton component for the /dashboard route when not authenticated', () => {
    render(<BrowserRouter initialEntries={['/dashboard']}><App /> </BrowserRouter>, {
      route: '/dashboard',
      auth0State: { isAuthenticated: true },
    });
    console.log(window.location.pathname);
    expect(screen.getByText(/Mocked Login/)).toBeInTheDocument();
  });
});" > src/__tests__/App.test.jsx


# Move tempUI to UI, replacing existing files
cd ..
rm -rf ui
mv tempUI ui


# Update package.json name property
sed -i 's/"name": "tempui"/"name": "ui"/' ui/package.json