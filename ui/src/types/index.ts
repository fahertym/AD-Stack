// Global type definitions for AD-Stack UI

export interface User {
  id: string;
  username: string;
  email: string;
  fullName: string;
  enabled: boolean;
  createdAt: string;
  updatedAt: string;
  lastLogin?: string;
  groups: string[];
  attributes?: {
    department?: string;
    title?: string;
    phone?: string;
  };
}

export interface Group {
  id: string;
  name: string;
  description: string;
  type: 'security' | 'distribution';
  memberCount: number;
  createdAt: string;
  updatedAt: string;
  members?: GroupMember[];
}

export interface GroupMember {
  username: string;
  fullName: string;
  email: string;
}

export interface CreateUserRequest {
  username: string;
  email: string;
  fullName: string;
  password: string;
  enabled?: boolean;
  attributes?: {
    department?: string;
    title?: string;
    phone?: string;
  };
}

export interface UpdateUserRequest {
  email?: string;
  fullName?: string;
  enabled?: boolean;
  attributes?: {
    department?: string;
    title?: string;
    phone?: string;
  };
}

export interface CreateGroupRequest {
  name: string;
  description?: string;
  type?: 'security' | 'distribution';
}

export interface UpdateGroupRequest {
  description?: string;
  type?: 'security' | 'distribution';
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  limit: number;
  offset: number;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  expiresAt: string;
}

export interface SystemStatus {
  services: {
    orchestrator: 'running' | 'stopped' | 'error';
    samba: 'running' | 'stopped' | 'error';
    dns: 'running' | 'stopped' | 'error';
    database: 'running' | 'stopped' | 'error';
    cache: 'running' | 'stopped' | 'error';
  };
  stats: {
    userCount: number;
    groupCount: number;
    uptimeSeconds: number;
    memoryUsageMb: number;
    cpuUsagePercent: number;
  };
  version: string;
}

export interface LogEntry {
  timestamp: string;
  level: 'debug' | 'info' | 'warn' | 'error';
  service: string;
  message: string;
  metadata?: Record<string, unknown>;
}

export interface ChangePasswordRequest {
  newPassword: string;
  currentPassword?: string;
}

// Form validation types
export interface FormErrors {
  [key: string]: string | undefined;
}

// Navigation types
export interface NavItem {
  id: string;
  label: string;
  path: string;
  icon?: React.ComponentType<any>;
  children?: NavItem[];
}

// Theme types
export type Theme = 'light' | 'dark';

// Table types
export interface TableColumn<T> {
  key: keyof T;
  label: string;
  sortable?: boolean;
  render?: (value: any, item: T) => React.ReactNode;
}

export interface TableProps<T> {
  data: T[];
  columns: TableColumn<T>[];
  loading?: boolean;
  onSort?: (key: keyof T, direction: 'asc' | 'desc') => void;
  onRowClick?: (item: T) => void;
}

// Notification types
export type NotificationType = 'success' | 'error' | 'warning' | 'info';

export interface Notification {
  id: string;
  type: NotificationType;
  title: string;
  message?: string;
  autoClose?: boolean;
  duration?: number;
}