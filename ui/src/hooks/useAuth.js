import { useAuth0 } from '@auth0/auth0-react';

const useAuth = () => {
  const { loginWithRedirect, logout, user, isAuthenticated, isLoading } = useAuth0();

  return {
    loginWithRedirect,
    logout,
    user,
    isAuthenticated,
    isLoading,
  };
};

export default useAuth;
