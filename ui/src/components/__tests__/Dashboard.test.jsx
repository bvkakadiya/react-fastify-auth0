
import React from 'react';
import { render, screen } from '@testing-library/react';
import { Provider } from 'react-redux';
import store from '../../store/storeSetup';
import Dashboard from '../Dashboard';
import { vi } from 'vitest';

// Mock the Counter component
vi.mock('../Counter', () => ({
  default: () => <div>Mocked Counter</div>
}));

describe('Dashboard', () => {
  it('renders the Dashboard component', () => {
    render(
      <Provider store={store}>
        <Dashboard />
      </Provider>
    );

    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Mocked Counter')).toBeInTheDocument();
  });

  it('renders the Counter component with initial state', () => {
    render(
      <Provider store={store}>
        <Dashboard />
      </Provider>
    );

    expect(screen.getByText('Mocked Counter')).toBeInTheDocument();
  });
});
