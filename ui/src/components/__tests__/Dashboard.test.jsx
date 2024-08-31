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
