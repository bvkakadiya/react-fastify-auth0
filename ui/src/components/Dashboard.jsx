import { useAuth0, User } from '@auth0/auth0-react'
import { Layout, Avatar, Typography, Button } from 'antd'
import { LogoutOutlined } from '@ant-design/icons'
import Counter from './Counter'
import UserList from './UserList'


const Dashboard = () => {
  const { user, logout } = useAuth0()

  return (
    <Layout className='min-h-screen'>
      <Layout.Header className='bg-transparent flex justify-between items-center p-4'>
      <Typography.Title level={3} className="flex-1 text-3xl font-bold mb-8">
          <span className="text-red-500">My </span> 
          <span className="text-green-500">Demo </span> 
          <span className="text-blue-500">for </span> 
          <span className="text-yellow-500">the </span> 
          <span className="text-purple-500">Day!</span>
        </Typography.Title>
        <div className='flex items-center'>
          <span className='text-lg mr-3'>{user.name}</span>
          <Avatar src={user.picture} alt={user.name} className='mr-3' />
          <Button
            shape='circle'
            icon={<LogoutOutlined className='-rotate-90 text-red-900' />}
            onClick={() => logout({ returnTo: window.location.origin })}
          />
        </div>
      </Layout.Header>
      <Layout.Content className='p-6 bg-gray-100'>
        <Counter />
        <UserList></UserList>
      </Layout.Content>
    </Layout>
  )
}

export default Dashboard;
