import React, { createContext, useContext, useEffect, useState } from 'react';
import { toast } from 'react-toastify';
import { authService } from '../services/api';
import { User, LoginRequest } from '../types';

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  login: (credentials: LoginRequest) => Promise<void>;
  logout: () => Promise<void>;
  checkAuth: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

interface AuthProviderProps {
  children: React.ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const login = async (credentials: LoginRequest): Promise<void> => {
    try {
      setIsLoading(true);
      const response = await authService.login(credentials);
      
      // For now, we'll create a mock user object since we don't have a /me endpoint yet
      // In the real implementation, you would call a /me or /profile endpoint here
      const mockUser: User = {
        id: '1',
        username: credentials.username,
        email: `${credentials.username}@example.local`,
        fullName: credentials.username === 'administrator' ? 'Administrator' : 'User',
        enabled: true,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        groups: credentials.username === 'administrator' ? ['Domain Admins'] : ['Domain Users'],
      };
      
      setUser(mockUser);
      toast.success('Login successful');
    } catch (error: any) {
      toast.error(error.message || 'Login failed');
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async (): Promise<void> => {
    try {
      await authService.logout();
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      setUser(null);
      toast.info('Logged out successfully');
    }
  };

  const checkAuth = async (): Promise<void> => {
    try {
      const token = authService.getToken();
      if (!token) {
        setIsLoading(false);
        return;
      }

      // Try to refresh the token to verify it's still valid
      // In a real implementation, you might have a separate /me endpoint
      try {
        await authService.refreshToken();
        
        // Mock user for demonstration - replace with actual user fetch
        const mockUser: User = {
          id: '1',
          username: 'current-user',
          email: 'current-user@example.local',
          fullName: 'Current User',
          enabled: true,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
          groups: ['Domain Users'],
        };
        
        setUser(mockUser);
      } catch (error) {
        // Token is invalid, remove it
        authService.removeToken();
        setUser(null);
      }
    } catch (error) {
      console.error('Auth check error:', error);
      setUser(null);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    checkAuth();
  }, []);

  const value: AuthContextType = {
    user,
    isLoading,
    login,
    logout,
    checkAuth,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};