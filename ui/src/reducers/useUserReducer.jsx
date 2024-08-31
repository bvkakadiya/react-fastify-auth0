import { useReducer, useEffect, useCallback, useRef } from 'react';
import { useAuth0 } from '@auth0/auth0-react';

const API_URL =  window.location.origin + '/api/users';

const initialState = {
  users: [],
  status: 'idle',
  error: null,
};

const userReducer = (state, action) => {
  switch (action.type) {
    case 'FETCH_USERS_REQUEST':
      return { ...state, status: 'loading' };
    case 'FETCH_USERS_SUCCESS':
      return { ...state, status: 'succeeded', users: action.payload };
    case 'FETCH_USERS_FAILURE':
      return { ...state, status: 'failed', error: action.error };
    case 'ADD_USER_SUCCESS':
      return { ...state, users: [...state.users, action.payload] };
    default:
      return state;
  }
};

const useUserReducer = () => {
  const [state, dispatch] = useReducer(userReducer, initialState);
  const { getAccessTokenSilently } = useAuth0();
  const hasFetchedUsers = useRef(false);

  const fetchUsers = useCallback(async () => {
    if (hasFetchedUsers.current) return;
    hasFetchedUsers.current = true;
    dispatch({ type: 'FETCH_USERS_REQUEST' });
    try {
      const token = await getAccessTokenSilently();
      const response = await fetch(API_URL, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      if (!response.ok) {
        throw new Error('Failed to fetch users');
      }
      const users = await response.json();
      dispatch({ type: 'FETCH_USERS_SUCCESS', payload: users });
      hasFetchedUsers.current = false
    } catch (error) {
      dispatch({ type: 'FETCH_USERS_FAILURE', error: error.message });
    }
  }, [getAccessTokenSilently]);

  const createUser = useCallback(async (user) => {
    try {
      const token = await getAccessTokenSilently();
      const response = await fetch(API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(user),
      });
      if (!response.ok) {
        throw new Error('Failed to create user');
      }
      const addedUser = await response.json();
      fetchUsers();
      dispatch({ type: 'ADD_USER_SUCCESS', payload: addedUser });
    } catch (error) {
      console.error('Failed to add user:', error);
    }
  }, [getAccessTokenSilently, fetchUsers]);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  return {
    state,
    fetchUsers,
    createUser,
  };
};

export default useUserReducer;
