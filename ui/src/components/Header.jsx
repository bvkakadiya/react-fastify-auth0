import { useAuth0 } from '@auth0/auth0-react';
import LoginButton from './LoginButton';
import LogoutButton from './LogoutButton';
import Profile from './Profile';

const Header = () => {
  const { isAuthenticated } = useAuth0();

  return (
    <header className='bg-gray-800 text-white p-4 flex justify-between items-center'>
      <div className='text-xl font-bold'>App Name</div>
      <div className='flex items-center space-x-4'>
        {isAuthenticated ? (
          <>
            <Profile />
            <LogoutButton />
          </>
        ) : (
          <LoginButton />
        )}
      </div>
    </header>
  );
};

export default Header;
