import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { Page } from '@patternfly/react-core';

import { useAuth } from './contexts/AuthContext';
import { AppHeader } from './components/layout/AppHeader';
import { AppSidebar } from './components/layout/AppSidebar';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import { UsersPage } from './pages/UsersPage';
import { GroupsPage } from './pages/GroupsPage';
import { SystemPage } from './pages/SystemPage';
import { LoadingSpinner } from './components/common/LoadingSpinner';

export const App: React.FC = () => {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (!user) {
    return <LoginPage />;
  }

  return (
    <Page
      header={<AppHeader />}
      sidebar={<AppSidebar />}
      isManagedSidebar
      skipToContent={{
        href: '#main-content',
        text: 'Skip to main content',
      }}
    >
      <Routes>
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/users/*" element={<UsersPage />} />
        <Route path="/groups/*" element={<GroupsPage />} />
        <Route path="/system/*" element={<SystemPage />} />
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </Page>
  );
};