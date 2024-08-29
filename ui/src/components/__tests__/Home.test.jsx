import React from 'react';
import { render, screen } from '@testing-library/react';
import Home from '../Home';

describe('Home', () => {
  it('renders the Home component', () => {
    render(<Home />);
    expect(screen.getByText('Home')).toBeInTheDocument();
    expect(screen.getByText('Welcome to the Home page!')).toBeInTheDocument();
  });
});

