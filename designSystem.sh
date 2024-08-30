#!/bin/bash
cd ui
# Step 3: Install Ant Design
echo "Installing Ant Design..."
npm install antd

# Step 6: Add Tailwind CSS to your CSS file
echo "Adding Tailwind CSS to your CSS file..."
cat > src/index.css <<EOL
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

# Step 7: Import Ant Design styles in your main CSS file
echo "Importing Ant Design styles..."
echo "@import 'antd/dist/antd.css';" >> src/index.css

# Step 8: Create a sample component using Ant Design and Tailwind CSS
echo "Creating a sample component..."
cat > src/components/MyButton.js <<EOL
import React from 'react';
import { Button } from 'antd';

const MyButton = () => {
  return <Button type="primary" className="bg-blue-500">Click Me</Button>;
};

export default MyButton;
EOL
# unit test for mybutton 
cat > src/components/MyButton.test.js <<EOL
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import MyButton from './MyButton';

test('renders Click Me button', () => {
  render(<MyButton />);
  const buttonElement = screen.getByText(/Click Me/i);
  expect(buttonElement).toBeInTheDocument();
});
EOL

echo "Setup complete! You can now run 'npm start' to start your React app."