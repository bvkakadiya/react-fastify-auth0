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
