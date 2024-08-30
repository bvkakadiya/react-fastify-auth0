import { render, screen } from '@testing-library/react';
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

