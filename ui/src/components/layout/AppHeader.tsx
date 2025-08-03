import React from 'react';
import {
  Masthead,
  MastheadMain,
  MastheadBrand,
  MastheadContent,
  Toolbar,
  ToolbarContent,
  ToolbarGroup,
  ToolbarItem,
  Button,
  Dropdown,
  DropdownItem,
  DropdownList,
  MenuToggle,
  MenuToggleElement,
} from '@patternfly/react-core';
import { UserIcon, CogIcon } from '@patternfly/react-icons';
import { useAuth } from '../../contexts/AuthContext';

export const AppHeader: React.FC = () => {
  const { user, logout } = useAuth();
  const [isUserMenuOpen, setIsUserMenuOpen] = React.useState(false);

  const handleUserMenuToggle = () => {
    setIsUserMenuOpen(!isUserMenuOpen);
  };

  const handleLogout = async () => {
    await logout();
  };

  const userMenuItems = (
    <DropdownList>
      <DropdownItem key="profile" icon={<UserIcon />}>
        Profile
      </DropdownItem>
      <DropdownItem key="settings" icon={<CogIcon />}>
        Settings
      </DropdownItem>
      <DropdownItem key="separator" isDivider />
      <DropdownItem key="logout" onClick={handleLogout}>
        Logout
      </DropdownItem>
    </DropdownList>
  );

  return (
    <Masthead>
      <MastheadMain>
        <MastheadBrand href="/dashboard">
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <img
              src="/favicon.ico"
              alt="AD-Stack"
              style={{ height: '32px', width: '32px' }}
            />
            <span style={{ fontSize: '18px', fontWeight: 600, color: 'white' }}>
              AD-Stack
            </span>
          </div>
        </MastheadBrand>
      </MastheadMain>
      <MastheadContent>
        <Toolbar id="header-toolbar" isFullHeight>
          <ToolbarContent>
            <ToolbarGroup variant="icon-button-group" align={{ default: 'alignRight' }}>
              <ToolbarItem>
                <Dropdown
                  isOpen={isUserMenuOpen}
                  onSelect={handleUserMenuToggle}
                  onOpenChange={(isOpen) => setIsUserMenuOpen(isOpen)}
                  toggle={(toggleRef: React.Ref<MenuToggleElement>) => (
                    <MenuToggle
                      ref={toggleRef}
                      onClick={handleUserMenuToggle}
                      isExpanded={isUserMenuOpen}
                      variant="plain"
                      aria-label="User menu"
                    >
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <UserIcon />
                        <span>{user?.fullName || user?.username}</span>
                      </div>
                    </MenuToggle>
                  )}
                  shouldFocusToggleOnSelect
                >
                  {userMenuItems}
                </Dropdown>
              </ToolbarItem>
            </ToolbarGroup>
          </ToolbarContent>
        </Toolbar>
      </MastheadContent>
    </Masthead>
  );
};