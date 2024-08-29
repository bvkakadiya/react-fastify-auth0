import { render, screen } from '@testing-library/react';
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
});
