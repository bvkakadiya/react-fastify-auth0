import { useAuth0 } from '@auth0/auth0-react';
import { Button, Layout, Menu } from 'antd';
import LoginButton from './LoginButton';
import LogoutButton from './LogoutButton';
import Profile from './Profile';

const { Header: AntHeader } = Layout;

const Header = () => {
  const { isAuthenticated } = useAuth0();

  return (
    <AntHeader className='bg-gray-800 text-white p-4 flex justify-between items-center'>
      <div className='text-xl font-bold'>App Name</div>
      <Menu theme="dark" mode="horizontal" className='flex-grow'>
        <Menu.Item key="1">Home</Menu.Item>
        <Menu.Item key="2">About</Menu.Item>
        <Menu.Item key="3">Contact</Menu.Item>
      </Menu>
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
    </AntHeader>
  );
};

export default Header;