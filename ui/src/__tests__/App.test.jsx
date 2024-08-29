import React from 'react';
import { render, screen } from '@testing-library/react';
// import { renderWithProviders } from '../utils/test-utils';

import App from '../App.jsx';
import { vi } from 'vitest';
import { BrowserRouter, MemoryRouter } from 'react-router-dom';

// Mock the components
vi.mock('../components/Home', () => ({
  default: () => <div>Mocked Home</div>,
}));

vi.mock('../components/LoginButton', () => ({
  default: () => <div>Mocked Login</div>,
}));

vi.mock('../components/Dashboard', () => ({
  default: () => <div>Mocked Dashboard</div>,
}));

vi.mock('../components/Counter', () => ({
  default: () => <div>Mocked Counter</div>,
}));

describe('App', () => {
  it('renders the Home component for the root route', () => {
    render(<BrowserRouter initialEntries={['/']}><App /> </BrowserRouter>, { route: '/' });
    expect(screen.getByText('Mocked Home')).toBeInTheDocument();
  });

  it('renders the LoginButton component for the /login route', () => {
    render(<BrowserRouter initialEntries={['/login']}><App /> </BrowserRouter>, { route: '/login' });
    expect(screen.getByText('Mocked Login')).toBeInTheDocument();
  });
  
  it('renders the Dashboard component for the /dashboard route when authenticated', () => {
    render(<BrowserRouter initialEntries={['/dashboard']}><App /> </BrowserRouter>, { route: '/dashboard', auth0State: { isAuthenticated: true } });
    expect(screen.getByText('Mocked Dashboard')).toBeInTheDocument();
  });
  
  it('renders the LoginButton component for the /dashboard route when not authenticated', () => {
    render(<BrowserRouter initialEntries={['/dashboard']}><App /> </BrowserRouter>, {
      route: '/dashboard',
      auth0State: { isAuthenticated: true },
    });
    console.log(window.location.pathname);
    expect(screen.getByText(/Mocked Login/)).toBeInTheDocument();
  });
});
