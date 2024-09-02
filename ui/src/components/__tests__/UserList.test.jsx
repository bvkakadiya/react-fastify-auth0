// __tests__/UserList.test.jsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import UserList from '../UserList';
import useUserReducer from '../../reducers/useUserReducer';

// Mock useUserReducer hook
vi.mock('../../reducers/useUserReducer');

describe('UserList', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should display loading state', () => {
    useUserReducer.mockReturnValue({
      state: { status: 'loading', users: [], error: null },
      createUser: vi.fn(),
    });

    render(<UserList />);

    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('should display error state', () => {
    const mockError = 'Failed to fetch users';
    useUserReducer.mockReturnValue({
      state: { status: 'failed', users: [], error: mockError },
      createUser: vi.fn(),
    });

    render(<UserList />);

    expect(screen.getByText(mockError)).toBeInTheDocument();
  });

  it('should display users', () => {
    const mockUsers = [{ id: 1, name: 'John Doe' }, { id: 2, name: 'Jane Doe' }];
    useUserReducer.mockReturnValue({
      state: { status: 'succeeded', users: mockUsers, error: null },
      createUser: vi.fn(),
    });

    render(<UserList />);

    mockUsers.forEach(user => {
      expect(screen.getByText(user.name)).toBeInTheDocument();
    });
  });

  it('should call createUser on button click', async () => {
    const mockCreateUser = vi.fn();
    useUserReducer.mockReturnValue({
      state: { status: 'succeeded', users: [], error: null },
      createUser: mockCreateUser,
    });

    render(<UserList />);

    fireEvent.click(screen.getByText('Add User'));

    await waitFor(() => {
      expect(mockCreateUser).toHaveBeenCalledWith({ name: 'New User', email: 'newuser@example.com' });
    });
  });
});
