#!/bin/bash
cd ui
# Step 3: Install Ant Design
echo "Installing Ant Design..."
npm install antd @ant-design/icons --save

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
import { useAuth0, User } from '@auth0/auth0-react'
import { Layout, Avatar, Typography, Button } from 'antd'
import { LogoutOutlined } from '@ant-design/icons'
import Counter from './Counter'
import UserList from './UserList'


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
        <UserList></UserList>
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

vi.mock('../UserList', () => ({
  default: () => <div>Mocked UserList</div>,
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

mkdir -p src/reducers/__tests__
cat <<EOL > src/reducers/useUserReducer.jsx
import { useReducer, useEffect, useCallback, useRef } from 'react';
import { useAuth0 } from '@auth0/auth0-react';

const API_URL =  window.location.origin + '/api/users';

const initialState = {
  users: [],
  status: 'idle',
  error: null,
};

const userReducer = (state, action) => {
  switch (action.type) {
    case 'FETCH_USERS_REQUEST':
      return { ...state, status: 'loading' };
    case 'FETCH_USERS_SUCCESS':
      return { ...state, status: 'succeeded', users: action.payload };
    case 'FETCH_USERS_FAILURE':
      return { ...state, status: 'failed', error: action.error };
    case 'ADD_USER_SUCCESS':
      return { ...state, users: [...state.users, action.payload] };
    default:
      return state;
  }
};

const useUserReducer = () => {
  const [state, dispatch] = useReducer(userReducer, initialState);
  const { getAccessTokenSilently } = useAuth0();
  const hasFetchedUsers = useRef(false);

  const fetchUsers = useCallback(async () => {
    if (hasFetchedUsers.current) return;
    hasFetchedUsers.current = true;
    dispatch({ type: 'FETCH_USERS_REQUEST' });
    try {
      const token = await getAccessTokenSilently();
      const response = await fetch(API_URL, {
        headers: {
          Authorization: \`Bearer \${token}\`,
        },
      });
      if (!response.ok) {
        throw new Error('Failed to fetch users');
      }
      const users = await response.json();
      dispatch({ type: 'FETCH_USERS_SUCCESS', payload: users });
      hasFetchedUsers.current = false
    } catch (error) {
      dispatch({ type: 'FETCH_USERS_FAILURE', error: error.message });
    }
  }, [getAccessTokenSilently]);

  const createUser = useCallback(async (user) => {
    try {
      const token = await getAccessTokenSilently();
      const response = await fetch(API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: \`Bearer \${token}\`,
        },
        body: JSON.stringify(user),
      });
      if (!response.ok) {
        throw new Error('Failed to create user');
      }
      const addedUser = await response.json();
      fetchUsers();
      dispatch({ type: 'ADD_USER_SUCCESS', payload: addedUser });
    } catch (error) {
      console.error('Failed to add user:', error);
    }
  }, [getAccessTokenSilently, fetchUsers]);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  return {
    state,
    fetchUsers,
    createUser,
  };
};

export default useUserReducer;
EOL

cat <<EOL > src/reducers/__tests__/useUserReducer.test.jsx
// hooks/__tests__/useUserReducer.test.jsx
import { render, act } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useAuth0 } from '@auth0/auth0-react';
import useUserReducer from '../useUserReducer';

// Mock useAuth0 hook
vi.mock('@auth0/auth0-react', () => ({
  useAuth0: vi.fn(),
}));

// Mock fetch API
global.fetch = vi.fn();

describe('useUserReducer', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should fetch users successfully', async () => {
    const mockToken = 'mock-token';
    const mockUsers = [{ id: 1, name: 'John Doe' }];
    
    useAuth0.mockReturnValue({
      getAccessTokenSilently: vi.fn().mockResolvedValue(mockToken),
    });

    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => mockUsers,
    });

    let result;
    function TestComponent() {
      result = useUserReducer();
      return null;
    }

    render(<TestComponent />);

    await act(async () => {});

    expect(result.state.status).toBe('succeeded');
    expect(result.state.users).toEqual(mockUsers);
  });

  it('should handle fetch users failure', async () => {
    const mockToken = 'mock-token';
    const mockError = 'Failed to fetch users';

    useAuth0.mockReturnValue({
      getAccessTokenSilently: vi.fn().mockResolvedValue(mockToken),
    });

    fetch.mockResolvedValueOnce({
      ok: false,
    });

    let result;
    function TestComponent() {
      result = useUserReducer();
      return null;
    }

    render(<TestComponent />);

    await act(async () => {});

    expect(result.state.status).toBe('failed');
    expect(result.state.error).toBe(mockError);
  });

  it('should add a user successfully', async () => {
    const mockToken = 'mock-token';
    const newUser = { id: 2, name: 'Jane Doe' };

    useAuth0.mockReturnValue({
      getAccessTokenSilently: vi.fn().mockResolvedValue(mockToken),
    });

    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => newUser,
    });

    let result;
    function TestComponent() {
      result = useUserReducer();
      return null;
    }

    render(<TestComponent />);

    await act(async () => {
      await result.createUser(newUser);
    });
    console.log(result.state.users);
    expect(result.state.users).toStrictEqual(newUser);
  });
});
EOL

cat <<EOL > src/components/UserList.jsx
import useUserReducer from '../reducers/useUserReducer';

const UserList = () => {
  const { state, createUser } = useUserReducer();

  const handleAddUser = async () => {
    const newUser = { name: 'New User', email: 'newuser@example.com' };
    await createUser(newUser);
  };
  
  console.log(state);

  return (
    <div>
      <h1>User List</h1>
      {state.status === 'loading' && <div>Loading...</div>}
      {state.status === 'failed' && <div>{state.error}</div>}
      <ul>
        {state.users.map((user) => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
      <button onClick={handleAddUser}>Add User</button>
    </div>
  );
};

export default UserList;
EOL

cat <<EOL > src/components/__tests__/UserList.test.jsx
// __tests__/UserList.test.jsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import UserList from '../components/UserList';
import useUserReducer from '../reducers/useUserReducer';

// Mock useUserReducer hook
vi.mock('../reducers/useUserReducer');

describe('UserList', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should display loading state', () => {
    useUserReducer.mockReturnValue({
      state: { status: 'loading', users: [], error: null },
      createUser: vi.fn(),
    });

    render(<UserList />);

    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('should display error state', () => {
    const mockError = 'Failed to fetch users';
    useUserReducer.mockReturnValue({
      state: { status: 'failed', users: [], error: mockError },
      createUser: vi.fn(),
    });

    render(<UserList />);

    expect(screen.getByText(mockError)).toBeInTheDocument();
  });

  it('should display users', () => {
    const mockUsers = [{ id: 1, name: 'John Doe' }, { id: 2, name: 'Jane Doe' }];
    useUserReducer.mockReturnValue({
      state: { status: 'succeeded', users: mockUsers, error: null },
      createUser: vi.fn(),
    });

    render(<UserList />);

    mockUsers.forEach(user => {
      expect(screen.getByText(user.name)).toBeInTheDocument();
    });
  });

  it('should call createUser on button click', async () => {
    const mockCreateUser = vi.fn();
    useUserReducer.mockReturnValue({
      state: { status: 'succeeded', users: [], error: null },
      createUser: mockCreateUser,
    });

    render(<UserList />);

    fireEvent.click(screen.getByText('Add User'));

    await waitFor(() => {
      expect(mockCreateUser).toHaveBeenCalledWith({ name: 'New User', email: 'newuser@example.com' });
    });
  });
});
EOL
echo "Dashboard component and its unit tests have been set up!"
echo "Setup complete! You can now run 'npm start' to start your React app."