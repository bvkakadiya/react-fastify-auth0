#!/bin/bash
cd ui
# Step 3: Install Ant Design
echo "Installing Ant Design..."
npm install antd @ant-design/icons --save

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

# Create Dashboard.jsx
cat <<EOL > src/components/Dashboard.jsx
import { useAuth0 } from '@auth0/auth0-react'
import { Layout, Avatar, Typography, Button } from 'antd'
import { LogoutOutlined } from '@ant-design/icons'
import Counter from './Counter'


const Dashboard = () => {
  const { user, logout } = useAuth0()

  return (
    <Layout className='min-h-screen'>
      <Layout.Header className='bg-transparent flex justify-between items-center p-4'>
      <Typography.Title level={3} className="flex-1 text-3xl font-bold mb-8">
          <span className="text-red-500">My </span> 
          <span className="text-green-500">Demo </span> 
          <span className="text-blue-500">for </span> 
          <span className="text-yellow-500">the </span> 
          <span className="text-purple-500">Day!</span>
        </Typography.Title>
        <div className='flex items-center'>
          <span className='text-lg mr-3'>{user.name}</span>
          <Avatar src={user.picture} alt={user.name} className='mr-3' />
          <Button
            shape='circle'
            icon={<LogoutOutlined className='-rotate-90 text-red-900' />}
            onClick={() => logout({ returnTo: window.location.origin })}
          />
        </div>
      </Layout.Header>
      <Layout.Content className='p-6 bg-gray-100'>
        <Counter />
      </Layout.Content>
    </Layout>
  )
}

export default Dashboard;
EOL

# Create Dashboard.test.jsx
cat <<EOL > src/components/__tests__/Dashboard.test.jsx
import { vi } from 'vitest';
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { useAuth0 } from '@auth0/auth0-react';
import { Provider } from 'react-redux';
import store from '../../store/storeSetup';
import Dashboard from '../Dashboard';

// Mock the Counter component
vi.mock('../Counter', () => ({
  default: () => <div>Mocked Counter</div>,
}));

// Mock the useAuth0 hook
vi.mock('@auth0/auth0-react', () => ({
  useAuth0: vi.fn(),
}));

// Mock the antd components
vi.mock('antd', () => {
  const Layout = ({ children }) => children;
  Layout.Header = ({ children }) => children;
  Layout.Content = ({ children }) => children;
  return {
  __esModule: true,
  Avatar: ({ src, alt }) => <img src={src} alt={alt} />,
  Typography: {
    Title: ({ children }) => <h1>{children}</h1>,
  },
  Button: ({ icon, onClick }) => <button onClick={onClick}>{icon}</button>,
  Layout
}});

// Mock the @ant-design/icons components
vi.mock('@ant-design/icons', () => ({
  __esModule: true,
  LogoutOutlined: () => <span>LogoutIcon</span>,
}));

describe('Dashboard', () => {
  beforeEach(() => {
    useAuth0.mockReturnValue({
      user: {
        name: 'John Doe',
        picture: 'https://example.com/johndoe.jpg',
      },
      logout: vi.fn(),
    });
  });

  it('renders the user information and Counter component', () => {
    render(
      <Provider store={store}>
        <Dashboard />
      </Provider>
    );

    // Check if the user's name is rendered
    expect(screen.getByText('John Doe')).toBeInTheDocument();

    // Check if the user's avatar is rendered
    const avatar = screen.getByAltText('John Doe');
    expect(avatar).toBeInTheDocument();
    expect(avatar).toHaveAttribute('src', 'https://example.com/johndoe.jpg');

    // Check if the Counter component is rendered
    expect(screen.getByText('Mocked Counter')).toBeInTheDocument();
  });

  it('renders the colorful title', () => {
    render(
      <Provider store={store}>
        <Dashboard />
      </Provider>
    );

    // Check if the colorful title is rendered
    expect(screen.getByText('My')).toBeInTheDocument();
    expect(screen.getByText('Demo')).toBeInTheDocument();
    expect(screen.getByText('for')).toBeInTheDocument();
    expect(screen.getByText('the')).toBeInTheDocument();
    expect(screen.getByText('Day!')).toBeInTheDocument();
  });

  it('calls logout function when logout button is clicked', () => {
    const { logout } = useAuth0();
    render(
      <Provider store={store}>
        <Dashboard />
      </Provider>
    );

    // Click the logout button
    const logoutButton = screen.getByRole('button');
    fireEvent.click(logoutButton);

    // Check if the logout function is called
    expect(logout).toHaveBeenCalled();
  });
});
EOL

echo "Dashboard component and its unit tests have been set up!"
echo "Setup complete! You can now run 'npm start' to start your React app."