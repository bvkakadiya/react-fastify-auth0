import React from 'react';
import { Button } from 'antd';
import { useAuth0 } from '@auth0/auth0-react';

const Home = () => {
  const { loginWithRedirect } = useAuth0();

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100">
      <h1 className="text-4xl mb-4">
        <img
          src="https://media.giphy.com/media/d8v1ADcWh73B9PlyjH/giphy.gif"
          alt="Dancing Mushroom"
          className="w-16 h-16 mr-2 inline-block align-middle"
        />
        <span className="text-red-500 inline-block align-middle">Welcome</span>{' '}
        <span className="text-blue-500 inline-block align-middle">to</span>{' '}
        <span className="text-green-500 font-bold inline-block align-middle">Bhavesh</span>{' '}
        <span className="text-yellow-500 font-bold inline-block align-middle">Kakadiya's</span>{' '}
        <span className="text-purple-500 inline-block align-middle">world!</span>
        <img
          src="https://media.giphy.com/media/d8v1ADcWh73B9PlyjH/giphy.gif"
          alt="Dancing Mushroom"
          className="w-16 h-16 ml-2 inline-block align-middle"
        />
      </h1>
      <Button type="primary" size="large" onClick={() => loginWithRedirect()}>
        Log In
      </Button>
    </div>
  );
};

export default Home;
