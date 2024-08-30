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
