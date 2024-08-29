import React from 'react';
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
});
