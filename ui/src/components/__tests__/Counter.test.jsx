import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { Provider } from 'react-redux';
import store from '../../store/storeSetup';
import Counter from '../Counter';

describe('Counter', () => {
  it('renders the Counter component with initial state', () => {
    render(
      <Provider store={store}>
        <Counter />
      </Provider>
    );

    expect(screen.getByText('Counter')).toBeInTheDocument();
    expect(screen.getByText('0')).toBeInTheDocument();
  });

  it('increments the counter value when Increment button is clicked', () => {
    render(
      <Provider store={store}>
        <Counter />
      </Provider>
    );

    fireEvent.click(screen.getByText('Increment'));
    expect(screen.getByText('1')).toBeInTheDocument();
  });

  it('decrements the counter value when Decrement button is clicked', () => {
    render(
      <Provider store={store}>
        <Counter />
      </Provider>
    );

    fireEvent.click(screen.getByText('Increment'));
    fireEvent.click(screen.getByText('Decrement'));
    expect(screen.getByText('1')).toBeInTheDocument();
  });
});

