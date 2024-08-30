import { Route, Routes } from 'react-router-dom'
import ProtectedRoute from './components/ProtectedRoute'
import Home from './components/Home'
import Dashboard from './components/Dashboard'

const App = () => {
  return (
      <div className='flex flex-col min-h-screen'>
        <main className='flex-grow'>
          <Routes>
            <Route path='/' element={<Home />} />
            <Route
              path='/dashboard'
              element={
                <ProtectedRoute>
                  <Dashboard />
                </ProtectedRoute>
              }
            />
          </Routes>
        </main>
      </div>
  )
}

export default App
