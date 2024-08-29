import { render, screen } from '@testing-library/react';
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
});
