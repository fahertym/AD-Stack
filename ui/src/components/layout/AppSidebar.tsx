import React from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import {
  PageSidebar,
  PageSidebarBody,
  Nav,
  NavList,
  NavItem,
  NavExpandable,
} from '@patternfly/react-core';
import {
  DashboardIcon,
  UsersIcon,
  UsersAltIcon,
  CogIcon,
  ChartAreaIcon,
  NetworkIcon,
  SecurityIcon,
} from '@patternfly/react-icons';

export const AppSidebar: React.FC = () => {
  const location = useLocation();
  const navigate = useNavigate();

  const getActiveItem = (pathname: string) => {
    if (pathname.startsWith('/users')) return 'users';
    if (pathname.startsWith('/groups')) return 'groups';
    if (pathname.startsWith('/system')) return 'system';
    if (pathname.startsWith('/dashboard')) return 'dashboard';
    return 'dashboard';
  };

  const activeItem = getActiveItem(location.pathname);

  const onNavSelect = (
    _event: React.FormEvent<HTMLInputElement>,
    result: { itemId: string | number }
  ) => {
    const itemId = result.itemId as string;
    navigate(`/${itemId}`);
  };

  const navigation = (
    <Nav onSelect={onNavSelect} aria-label="Main navigation">
      <NavList>
        <NavItem
          itemId="dashboard"
          isActive={activeItem === 'dashboard'}
          icon={<DashboardIcon />}
        >
          Dashboard
        </NavItem>
        
        <NavExpandable
          title="Identity Management"
          groupId="identity"
          isActive={activeItem === 'users' || activeItem === 'groups'}
          isExpanded={activeItem === 'users' || activeItem === 'groups'}
        >
          <NavItem
            itemId="users"
            isActive={activeItem === 'users'}
            icon={<UsersIcon />}
          >
            Users
          </NavItem>
          <NavItem
            itemId="groups"
            isActive={activeItem === 'groups'}
            icon={<UsersAltIcon />}
          >
            Groups
          </NavItem>
        </NavExpandable>

        <NavExpandable
          title="Services"
          groupId="services"
          isActive={false}
          isExpanded={false}
        >
          <NavItem itemId="dns" icon={<NetworkIcon />}>
            DNS Management
          </NavItem>
          <NavItem itemId="certificates" icon={<SecurityIcon />}>
            Certificates
          </NavItem>
          <NavItem itemId="file-shares" icon={<CogIcon />}>
            File Shares
          </NavItem>
        </NavExpandable>

        <NavExpandable
          title="System"
          groupId="system"
          isActive={activeItem === 'system'}
          isExpanded={activeItem === 'system'}
        >
          <NavItem
            itemId="system/status"
            isActive={location.pathname === '/system/status'}
            icon={<ChartAreaIcon />}
          >
            System Status
          </NavItem>
          <NavItem
            itemId="system/logs"
            isActive={location.pathname === '/system/logs'}
            icon={<CogIcon />}
          >
            System Logs
          </NavItem>
          <NavItem
            itemId="system/settings"
            isActive={location.pathname === '/system/settings'}
            icon={<CogIcon />}
          >
            Settings
          </NavItem>
        </NavExpandable>
      </NavList>
    </Nav>
  );

  return (
    <PageSidebar theme="dark">
      <PageSidebarBody>{navigation}</PageSidebarBody>
    </PageSidebar>
  );
};