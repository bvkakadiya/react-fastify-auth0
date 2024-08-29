import React from 'react';
import useAuth from '../hooks/useAuth';

const LoginButton = () => {
  const { loginWithRedirect } = useAuth();

  return <button onClick={() => loginWithRedirect()}>Log In</button>;
};

export default LoginButton;
