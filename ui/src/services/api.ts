import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { toast } from 'react-toastify';
import {
  ApiResponse,
  User,
  Group,
  CreateUserRequest,
  UpdateUserRequest,
  CreateGroupRequest,
  UpdateGroupRequest,
  LoginRequest,
  LoginResponse,
  SystemStatus,
  LogEntry,
  PaginatedResponse,
  ChangePasswordRequest,
} from '../types';

class ApiClient {
  private client: AxiosInstance;
  private tokenKey = 'ad-stack-token';

  constructor() {
    this.client = axios.create({
      baseURL: '/api/v1',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Request interceptor to add auth token
    this.client.interceptors.request.use((config) => {
      const token = this.getToken();
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });

    // Response interceptor for error handling
    this.client.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          this.removeToken();
          window.location.href = '/login';
        } else if (error.response?.status >= 500) {
          toast.error('Server error occurred. Please try again.');
        }
        return Promise.reject(error);
      }
    );
  }

  // Token management
  setToken(token: string): void {
    localStorage.setItem(this.tokenKey, token);
  }

  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  removeToken(): void {
    localStorage.removeItem(this.tokenKey);
  }

  // Generic API request method
  private async request<T>(
    method: 'GET' | 'POST' | 'PUT' | 'DELETE',
    url: string,
    data?: any,
    params?: any
  ): Promise<T> {
    try {
      const response: AxiosResponse<ApiResponse<T>> = await this.client.request({
        method,
        url,
        data,
        params,
      });

      if (!response.data.success) {
        throw new Error(response.data.error || 'API request failed');
      }

      return response.data.data as T;
    } catch (error: any) {
      if (error.response?.data?.error) {
        throw new Error(error.response.data.error);
      }
      throw error;
    }
  }

  // Authentication endpoints
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    const response = await this.request<LoginResponse>('POST', '/auth/login', credentials);
    this.setToken(response.token);
    return response;
  }

  async logout(): Promise<void> {
    try {
      await this.request<void>('POST', '/auth/logout');
    } finally {
      this.removeToken();
    }
  }

  async refreshToken(): Promise<LoginResponse> {
    const response = await this.request<LoginResponse>('POST', '/auth/refresh');
    this.setToken(response.token);
    return response;
  }

  // Health check
  async getHealth(): Promise<{ status: string; version: string }> {
    return this.request('GET', '/health');
  }

  // User management endpoints
  async getUsers(params?: {
    limit?: number;
    offset?: number;
    search?: string;
    enabled?: boolean;
  }): Promise<PaginatedResponse<User>> {
    return this.request('GET', '/users', undefined, params);
  }

  async getUser(username: string): Promise<User> {
    return this.request('GET', `/users/${username}`);
  }

  async createUser(userData: CreateUserRequest): Promise<User> {
    return this.request('POST', '/users', userData);
  }

  async updateUser(username: string, userData: UpdateUserRequest): Promise<User> {
    return this.request('PUT', `/users/${username}`, userData);
  }

  async deleteUser(username: string): Promise<void> {
    return this.request('DELETE', `/users/${username}`);
  }

  async changePassword(username: string, passwordData: ChangePasswordRequest): Promise<void> {
    return this.request('POST', `/users/${username}/password`, passwordData);
  }

  async enableUser(username: string): Promise<void> {
    return this.request('POST', `/users/${username}/enable`);
  }

  async disableUser(username: string): Promise<void> {
    return this.request('POST', `/users/${username}/disable`);
  }

  // Group management endpoints
  async getGroups(params?: {
    limit?: number;
    offset?: number;
    search?: string;
    type?: 'security' | 'distribution';
  }): Promise<PaginatedResponse<Group>> {
    return this.request('GET', '/groups', undefined, params);
  }

  async getGroup(name: string): Promise<Group> {
    return this.request('GET', `/groups/${name}`);
  }

  async createGroup(groupData: CreateGroupRequest): Promise<Group> {
    return this.request('POST', '/groups', groupData);
  }

  async updateGroup(name: string, groupData: UpdateGroupRequest): Promise<Group> {
    return this.request('PUT', `/groups/${name}`, groupData);
  }

  async deleteGroup(name: string): Promise<void> {
    return this.request('DELETE', `/groups/${name}`);
  }

  async addUserToGroup(groupName: string, username: string): Promise<void> {
    return this.request('POST', `/groups/${groupName}/members`, { username });
  }

  async removeUserFromGroup(groupName: string, username: string): Promise<void> {
    return this.request('DELETE', `/groups/${groupName}/members/${username}`);
  }

  // System information endpoints
  async getSystemStatus(): Promise<SystemStatus> {
    return this.request('GET', '/system/status');
  }

  async getSystemLogs(params?: {
    service?: string;
    level?: 'debug' | 'info' | 'warn' | 'error';
    since?: string;
    limit?: number;
  }): Promise<{ logs: LogEntry[]; total: number }> {
    return this.request('GET', '/system/logs', undefined, params);
  }
}

// Create and export a singleton instance
export const apiClient = new ApiClient();

// Export individual service functions for easier testing and modularity
export const authService = {
  login: (credentials: LoginRequest) => apiClient.login(credentials),
  logout: () => apiClient.logout(),
  refreshToken: () => apiClient.refreshToken(),
  getToken: () => apiClient.getToken(),
  removeToken: () => apiClient.removeToken(),
};

export const userService = {
  getUsers: (params?: Parameters<typeof apiClient.getUsers>[0]) => apiClient.getUsers(params),
  getUser: (username: string) => apiClient.getUser(username),
  createUser: (userData: CreateUserRequest) => apiClient.createUser(userData),
  updateUser: (username: string, userData: UpdateUserRequest) => 
    apiClient.updateUser(username, userData),
  deleteUser: (username: string) => apiClient.deleteUser(username),
  changePassword: (username: string, passwordData: ChangePasswordRequest) => 
    apiClient.changePassword(username, passwordData),
  enableUser: (username: string) => apiClient.enableUser(username),
  disableUser: (username: string) => apiClient.disableUser(username),
};

export const groupService = {
  getGroups: (params?: Parameters<typeof apiClient.getGroups>[0]) => apiClient.getGroups(params),
  getGroup: (name: string) => apiClient.getGroup(name),
  createGroup: (groupData: CreateGroupRequest) => apiClient.createGroup(groupData),
  updateGroup: (name: string, groupData: UpdateGroupRequest) => 
    apiClient.updateGroup(name, groupData),
  deleteGroup: (name: string) => apiClient.deleteGroup(name),
  addUserToGroup: (groupName: string, username: string) => 
    apiClient.addUserToGroup(groupName, username),
  removeUserFromGroup: (groupName: string, username: string) => 
    apiClient.removeUserFromGroup(groupName, username),
};

export const systemService = {
  getHealth: () => apiClient.getHealth(),
  getStatus: () => apiClient.getSystemStatus(),
  getLogs: (params?: Parameters<typeof apiClient.getSystemLogs>[0]) => 
    apiClient.getSystemLogs(params),
};