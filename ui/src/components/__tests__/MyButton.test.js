import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import MyButton from './MyButton';

test('renders Click Me button', () => {
  render(<MyButton />);
  const buttonElement = screen.getByText(/Click Me/i);
  expect(buttonElement).toBeInTheDocument();
});
