import React from 'react'
import { render } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { Provider } from 'react-redux'
import { Auth0Provider, Auth0Context } from '@auth0/auth0-react'
import store from '../store/storeSetup'

const defaultAuth0State = {
  isAuthenticated: true,
  isLoading: false,
  user: {
    name: 'John Doe',
    email: 'john.doe@example.com',
  },
  loginWithRedirect: vi.fn(),
  logout: vi.fn(),
}

const renderWithProviders = (
  ui,
  { route = '/', auth0State, ...renderOptions } = {}
) => {
  console.log('route', route)
  const Wrapper = ({ children }) => (
    <MemoryRouter initialEntries={[route]}>
      <Provider store={store}>
        <Auth0Context.Provider value={{ ...defaultAuth0State, ...auth0State }}>
          <Auth0Provider
            domain='test-domain'
            clientId='test-client-id'
            authorizationParams={{
              redirect_uri: window.location.origin,
            }}
          >
            {children}
          </Auth0Provider>
        </Auth0Context.Provider>
      </Provider>
    </MemoryRouter>
  )

  return render(ui, { wrapper: Wrapper, ...renderOptions })
}

export * from '@testing-library/react'
export { renderWithProviders }

