import { createContext, useContext, useState, useEffect } from 'react';
import { CognitoUserPool, CognitoUser, AuthenticationDetails } from 'amazon-cognito-identity-js';
import { getSecrets } from '../api/config';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  // ✅ Rehidrata auth inmediatamente desde sessionStorage, sin esperar secrets
  const [auth, setAuth] = useState(() => {
    const token    = sessionStorage.getItem('idToken');
    const username = sessionStorage.getItem('username');
    if (!token || !username) return null;
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      const group   = (payload['cognito:groups'] ?? [])[0] ?? null;
      return { token, username, group };
    } catch {
      sessionStorage.clear();
      return null;
    }
  });

  const [secrets, setSecrets] = useState(null);
  // ✅ loading arranca en true solo si no hay sesión previa
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState(null);

  useEffect(() => {
    getSecrets()
      .then(setSecrets)
      .catch((e) => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  function login(username, password) {
    return new Promise((resolve, reject) => {
      if (!secrets) return reject(new Error('Configuración no disponible'));

      const pool = new CognitoUserPool({
        UserPoolId: secrets.UserPoolId,
        ClientId:   secrets.ClientId,
      });

      const cognitoUser = new CognitoUser({ Username: username, Pool: pool });
      const authDetails = new AuthenticationDetails({ Username: username, Password: password });

      cognitoUser.authenticateUser(authDetails, {
        onSuccess(result) {
          const idToken  = result.getIdToken().getJwtToken();
          const payload  = result.getIdToken().decodePayload();
          const groups   = payload['cognito:groups'] ?? [];
          const group    = groups[0] ?? null;
          sessionStorage.setItem('idToken',   idToken);
          sessionStorage.setItem('username',  payload['cognito:username']);
          setAuth({ token: idToken, username: payload['cognito:username'], group });
          resolve(group);
        },
        onFailure: reject,
        newPasswordRequired(userAttributes, requiredAttributes) {
          const newPassword = prompt('Debe establecer una nueva contraseña:');
          const attrs = {};
          requiredAttributes.forEach((a) => { if (userAttributes[a]) attrs[a] = userAttributes[a]; });
          cognitoUser.completeNewPasswordChallenge(newPassword, attrs, this);
        },
      });
    });
  }

  function logout() {
    sessionStorage.removeItem('idToken');
    sessionStorage.removeItem('username');
    setAuth(null);
  }

  // ✅ useEffect de rehidratación eliminado — ya no es necesario

  return (
    <AuthContext.Provider value={{ auth, secrets, loading, error, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);