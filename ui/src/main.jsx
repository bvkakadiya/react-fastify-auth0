import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { Provider } from 'react-redux'
import { Auth0Provider } from '@auth0/auth0-react'
import App from './App.jsx'
import store from './store/storeSetup'
import './index.css'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <BrowserRouter>
      <Provider store={store}>
        <Auth0Provider
          domain={import.meta.env.VITE_AUTH0_DOMAIN}
          clientId={import.meta.env.VITE_AUTH0_CLIENT_ID}
          authorizationParams={{
            redirect_uri: window.location.origin + '/dashboard',
          }}
        >
          <App />
        </Auth0Provider>
      </Provider>
    </BrowserRouter>
  </StrictMode>
)

