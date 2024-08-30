#!/bin/bash
cd ui
# Step 3: Install Ant Design
echo "Installing Ant Design..."
npm install antd

# Step 6: Add Tailwind CSS to your CSS file
echo "Adding Tailwind CSS to your CSS file..."
cat > src/index.css <<EOL
@import 'antd/dist/antd.css';
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

# Step 8: Create a sample component using Ant Design and Tailwind CSS
echo "Creating a sample component..."
cat > src/components/MyButton.js <<EOL
import React from 'react';
import { Button } from 'antd';

const MyButton = () => {
  return <Button type="primary" className="bg-blue-500">Click Me</Button>;
};

export default MyButton;
EOL
# unit test for mybutton 
cat > src/components/__tests__/MyButton.test.js <<EOL
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import MyButton from './MyButton';

test('renders Click Me button', () => {
  render(<MyButton />);
  const buttonElement = screen.getByText(/Click Me/i);
  expect(buttonElement).toBeInTheDocument();
});
EOL

# Step 9: Update the Home component using Ant Design and Tailwind CSS
echo "Updating the Home component..."
cat > src/components/Home.jsx <<EOL
import React from 'react';
import { Button } from 'antd';
import { useAuth0 } from '@auth0/auth0-react';

const Home = () => {
  const { loginWithRedirect } = useAuth0();

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100">
      <h1 className="text-4xl mb-4">
        <img
          src="https://media.giphy.com/media/d8v1ADcWh73B9PlyjH/giphy.gif"
          alt="Dancing Mushroom"
          className="w-16 h-16 mr-2 inline-block align-middle"
        />
        <span className="text-red-500 inline-block align-middle">Welcome</span>{' '}
        <span className="text-blue-500 inline-block align-middle">to</span>{' '}
        <span className="text-green-500 font-bold inline-block align-middle">Bhavesh</span>{' '}
        <span className="text-yellow-500 font-bold inline-block align-middle">Kakadiya's</span>{' '}
        <span className="text-purple-500 inline-block align-middle">world!</span>
        <img
          src="https://media.giphy.com/media/d8v1ADcWh73B9PlyjH/giphy.gif"
          alt="Dancing Mushroom"
          className="w-16 h-16 ml-2 inline-block align-middle"
        />
      </h1>
      <Button type="primary" size="large" onClick={() => loginWithRedirect()}>
        Log In
      </Button>
    </div>
  );
};

export default Home;
EOL

# Step 10: Create a unit test for the Home component
echo "Creating a unit test for the Home component..."
cat > src/components/__tests__/Home.test.jsx <<EOL
import React from 'react';
import { render, screen } from '@testing-library/react';
import { useAuth0 } from '@auth0/auth0-react';
import Home from '../Home';
import { vi } from 'vitest';

vi.mock('@auth0/auth0-react');
vi.mock('antd', () => ({
  __esModule: true,
  Button: ({ children, onClick }) => <button onClick={onClick}>{children}</button>,
}));

describe('Home', () => {
  beforeEach(() => {
    useAuth0.mockReturnValue({
      loginWithRedirect: vi.fn(),
    });
  });

  it('renders the welcome message with colored text', () => {
    render(<Home />);

    expect(screen.getByText('Welcome')).toBeInTheDocument();
    expect(screen.getByText('to')).toBeInTheDocument();
    expect(screen.getByText('Bhavesh')).toBeInTheDocument();
    expect(screen.getByText("Kakadiya's")).toBeInTheDocument();
    expect(screen.getByText('world!')).toBeInTheDocument();
  });

  it('renders the dancing mushroom GIFs', () => {
    render(<Home />);

    const images = screen.getAllByAltText('Dancing Mushroom');
    expect(images).toHaveLength(2);
    images.forEach((img) => {
      expect(img).toHaveClass('w-16 h-16 inline-block align-middle');
    });
  });

  it('renders the login button and calls loginWithRedirect on click', () => {
    const { loginWithRedirect } = useAuth0();

    render(<Home />);

    const button = screen.getByText('Log In');
    expect(button).toBeInTheDocument();

    button.click();
    expect(loginWithRedirect).toHaveBeenCalled();
  });
});
EOL

# Step 11: Update the App component with routing and protected routes
echo "Updating the App component..."
cat > src/App.jsx <<EOL
import { Route, Routes } from 'react-router-dom'
import ProtectedRoute from './components/ProtectedRoute'
import Home from './components/Home'
import Dashboard from './components/Dashboard'

const App = () => {
  return (
      <div className='flex flex-col min-h-screen'>
        <main className='flex-grow'>
          <Routes>
            <Route path='/' element={<Home />} />
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
EOL

# Step 12: Create a unit test for the App component with protected routes
echo "Creating a unit test for the App component..."
cat > src/__tests__/App.test.jsx <<EOL
import React from 'react';
import { render, screen } from '@testing-library/react';
import { MemoryRouter, Route } from 'react-router-dom';
import { useAuth0 } from '@auth0/auth0-react';
import App from '../App';
import { vi } from 'vitest';

vi.mock('@auth0/auth0-react');
vi.mock('../components/ProtectedRoute', () => ({
  __esModule: true,
  default: ({ children }) => <div>{children}</div>,
}));
vi.mock('../components/Home', () => ({
  __esModule: true,
  default: () => <div>Home Component</div>,
}));
vi.mock('../components/Dashboard', () => ({
  __esModule: true,
  default: () => <div>Dashboard Component</div>,
}));

describe('App', () => {
  beforeEach(() => {
    useAuth0.mockReturnValue({
      isAuthenticated: false,
    });
  });

  it('renders the Home component on the root path', () => {
    render(
      <MemoryRouter initialEntries={['/']}>
        <App />
      </MemoryRouter>
    );

    expect(screen.getByText('Home Component')).toBeInTheDocument();
  });

  // it('redirects to Home when trying to access a protected route while not authenticated', () => {
  //   useAuth0.mockReturnValue({
  //     isAuthenticated: false,
  //   });
  //   render(
  //     <MemoryRouter initialEntries={['/dashboard']}>
  //       <App />
  //     </MemoryRouter>
  //   );

  //   // expect(screen.queryByText('Dashboard Component')).not.toBeInTheDocument();
  //   expect(screen.getByText('Home Component')).toBeInTheDocument();
  // });

  it('renders the Dashboard component on the /dashboard path when authenticated', () => {
    useAuth0.mockReturnValue({
      isAuthenticated: true,
    });

    render(
      <MemoryRouter initialEntries={['/dashboard']}>
        <App />
      </MemoryRouter>
    );

    expect(screen.getByText('Dashboard Component')).toBeInTheDocument();
    // expect(screen.getByText('Home Component')).not.toBeInTheDocument();
  });
});
EOL

echo "Setup complete! You can now run 'npm start' to start your React app."