import { render, screen } from '@testing-library/react';
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
});
