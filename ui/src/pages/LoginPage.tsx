import React, { useState } from 'react';
import {
  Page,
  PageSection,
  LoginPage as PFLoginPage,
  LoginMainFooterBandItem,
  LoginForm,
  ListItem,
  ListVariant,
  Alert,
} from '@patternfly/react-core';
import { ExclamationCircleIcon } from '@patternfly/react-icons';
import { useAuth } from '../contexts/AuthContext';

export const LoginPage: React.FC = () => {
  const { login } = useAuth();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    setError(null);
    setIsLoading(true);

    try {
      await login({ username, password });
    } catch (err: any) {
      setError(err.message || 'Login failed');
    } finally {
      setIsLoading(false);
    }
  };

  const loginForm = (
    <LoginForm
      showHelperText={false}
      helperText=""
      helperTextIcon={<ExclamationCircleIcon />}
      usernameLabel="Username"
      usernameValue={username}
      onChangeUsername={(_event, value) => setUsername(value)}
      passwordLabel="Password"
      passwordValue={password}
      onChangePassword={(_event, value) => setPassword(value)}
      rememberMeAriaLabel="Remember me"
      onLoginButtonClick={handleSubmit}
      loginButtonLabel="Log in"
      isLoginButtonDisabled={isLoading || !username || !password}
      isValidUsername={!error}
      isValidPassword={!error}
    />
  );

  const backgroundImages = {
    lg: '/images/pfbg_1200.jpg',
    sm: '/images/pfbg_768.jpg',
    sm2x: '/images/pfbg_768@2x.jpg',
    xs: '/images/pfbg_576.jpg',
    xs2x: '/images/pfbg_576@2x.jpg',
  };

  return (
    <PFLoginPage
      footerListVariants={ListVariant.inline}
      brandImgSrc="/favicon.ico"
      brandImgAlt="AD-Stack"
      backgroundImgSrc={backgroundImages}
      footerListItems={
        <LoginMainFooterBandItem>
          <div style={{ textAlign: 'center', color: '#72767b' }}>
            AD-Stack - Open Source Active Directory for SMBs
          </div>
        </LoginMainFooterBandItem>
      }
      textContent="Access your organization's identity management system."
      loginTitle="Sign in to AD-Stack"
      loginSubtitle="Enter your credentials to continue"
    >
      {error && (
        <Alert
          variant="danger"
          title="Login failed"
          style={{ marginBottom: '16px' }}
          isInline
        >
          {error}
        </Alert>
      )}
      {loginForm}
    </PFLoginPage>
  );
};