// hooks/__tests__/useUserReducer.test.jsx
import { render, act } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useAuth0 } from '@auth0/auth0-react';
import useUserReducer from '../useUserReducer';

// Mock useAuth0 hook
vi.mock('@auth0/auth0-react', () => ({
  useAuth0: vi.fn(),
}));

// Mock fetch API
global.fetch = vi.fn();

describe('useUserReducer', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should fetch users successfully', async () => {
    const mockToken = 'mock-token';
    const mockUsers = [{ id: 1, name: 'John Doe' }];
    
    useAuth0.mockReturnValue({
      getAccessTokenSilently: vi.fn().mockResolvedValue(mockToken),
    });

    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => mockUsers,
    });

    let result;
    function TestComponent() {
      result = useUserReducer();
      return null;
    }

    render(<TestComponent />);

    await act(async () => {});

    expect(result.state.status).toBe('succeeded');
    expect(result.state.users).toEqual(mockUsers);
  });

  it('should handle fetch users failure', async () => {
    const mockToken = 'mock-token';
    const mockError = 'Failed to fetch users';

    useAuth0.mockReturnValue({
      getAccessTokenSilently: vi.fn().mockResolvedValue(mockToken),
    });

    fetch.mockResolvedValueOnce({
      ok: false,
    });

    let result;
    function TestComponent() {
      result = useUserReducer();
      return null;
    }

    render(<TestComponent />);

    await act(async () => {});

    expect(result.state.status).toBe('failed');
    expect(result.state.error).toBe(mockError);
  });

  it('should add a user successfully', async () => {
    const mockToken = 'mock-token';
    const newUser = { id: 2, name: 'Jane Doe' };

    useAuth0.mockReturnValue({
      getAccessTokenSilently: vi.fn().mockResolvedValue(mockToken),
    });

    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => newUser,
    });

    let result;
    function TestComponent() {
      result = useUserReducer();
      return null;
    }

    render(<TestComponent />);

    await act(async () => {
      await result.createUser(newUser);
    });
    console.log(result.state.users);
    expect(result.state.users).toStrictEqual(newUser);
  });
});
