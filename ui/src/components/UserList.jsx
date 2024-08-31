import useUserReducer from '../reducers/useUserReducer';

const UserList = () => {
  const { state, createUser } = useUserReducer();

  const handleAddUser = async () => {
    const newUser = { name: 'New User', email: 'newuser@example.com' };
    await createUser(newUser);
  };
  
  console.log(state);

  return (
    <div>
      <h1>User List</h1>
      {state.status === 'loading' && <div>Loading...</div>}
      {state.status === 'failed' && <div>{state.error}</div>}
      <ul>
        {state.users.map((user) => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
      <button onClick={handleAddUser}>Add User</button>
    </div>
  );
};

export default UserList;
