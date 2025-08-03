import React from 'react';
import {
  PageSection,
  Title,
  Card,
  CardTitle,
  CardBody,
  Grid,
  GridItem,
  Flex,
  FlexItem,
  Progress,
  Icon,
} from '@patternfly/react-core';
import {
  CheckCircleIcon,
  ExclamationTriangleIcon,
  TimesCircleIcon,
  UsersIcon,
  UsersAltIcon,
  ServerIcon,
} from '@patternfly/react-icons';
import { useQuery } from '@tanstack/react-query';
import { systemService } from '../services/api';
import { LoadingSpinner } from '../components/common/LoadingSpinner';

export const DashboardPage: React.FC = () => {
  const {
    data: systemStatus,
    isLoading,
    error,
  } = useQuery({
    queryKey: ['system', 'status'],
    queryFn: systemService.getStatus,
    refetchInterval: 30000, // Refresh every 30 seconds
  });

  if (isLoading) {
    return <LoadingSpinner text="Loading dashboard..." />;
  }

  if (error) {
    return (
      <PageSection>
        <Title headingLevel="h1" size="lg">
          Dashboard
        </Title>
        <Card>
          <CardBody>
            <p>Error loading dashboard data. Please try again later.</p>
          </CardBody>
        </Card>
      </PageSection>
    );
  }

  const getServiceStatusIcon = (status: string) => {
    switch (status) {
      case 'running':
        return <Icon status="success"><CheckCircleIcon /></Icon>;
      case 'stopped':
        return <Icon status="warning"><ExclamationTriangleIcon /></Icon>;
      case 'error':
        return <Icon status="danger"><TimesCircleIcon /></Icon>;
      default:
        return <Icon status="info"><ServerIcon /></Icon>;
    }
  };

  const formatUptime = (seconds: number) => {
    const days = Math.floor(seconds / (24 * 60 * 60));
    const hours = Math.floor((seconds % (24 * 60 * 60)) / (60 * 60));
    const minutes = Math.floor((seconds % (60 * 60)) / 60);
    
    if (days > 0) {
      return `${days}d ${hours}h ${minutes}m`;
    } else if (hours > 0) {
      return `${hours}h ${minutes}m`;
    } else {
      return `${minutes}m`;
    }
  };

  return (
    <PageSection>
      <Title headingLevel="h1" size="lg" style={{ marginBottom: '24px' }}>
        Dashboard
      </Title>

      <Grid hasGutter>
        {/* Statistics Cards */}
        <GridItem xl={3} lg={4} md={6} sm={12}>
          <Card>
            <CardTitle>
              <Flex alignItems={{ default: 'alignItemsCenter' }}>
                <FlexItem>
                  <Icon size="lg">
                    <UsersIcon />
                  </Icon>
                </FlexItem>
                <FlexItem>Total Users</FlexItem>
              </Flex>
            </CardTitle>
            <CardBody>
              <Title headingLevel="h2" size="2xl">
                {systemStatus?.stats.userCount || 0}
              </Title>
            </CardBody>
          </Card>
        </GridItem>

        <GridItem xl={3} lg={4} md={6} sm={12}>
          <Card>
            <CardTitle>
              <Flex alignItems={{ default: 'alignItemsCenter' }}>
                <FlexItem>
                  <Icon size="lg">
                    <UsersAltIcon />
                  </Icon>
                </FlexItem>
                <FlexItem>Total Groups</FlexItem>
              </Flex>
            </CardTitle>
            <CardBody>
              <Title headingLevel="h2" size="2xl">
                {systemStatus?.stats.groupCount || 0}
              </Title>
            </CardBody>
          </Card>
        </GridItem>

        <GridItem xl={3} lg={4} md={6} sm={12}>
          <Card>
            <CardTitle>System Uptime</CardTitle>
            <CardBody>
              <Title headingLevel="h2" size="2xl">
                {systemStatus?.stats.uptimeSeconds
                  ? formatUptime(systemStatus.stats.uptimeSeconds)
                  : 'Unknown'}
              </Title>
            </CardBody>
          </Card>
        </GridItem>

        <GridItem xl={3} lg={4} md={6} sm={12}>
          <Card>
            <CardTitle>Version</CardTitle>
            <CardBody>
              <Title headingLevel="h2" size="2xl">
                {systemStatus?.version || 'Unknown'}
              </Title>
            </CardBody>
          </Card>
        </GridItem>

        {/* System Resources */}
        <GridItem xl={6} lg={6} md={12} sm={12}>
          <Card>
            <CardTitle>System Resources</CardTitle>
            <CardBody>
              <div style={{ marginBottom: '16px' }}>
                <Flex justifyContent={{ default: 'justifyContentSpaceBetween' }}>
                  <FlexItem>Memory Usage</FlexItem>
                  <FlexItem>
                    {systemStatus?.stats.memoryUsageMb
                      ? `${systemStatus.stats.memoryUsageMb} MB`
                      : 'Unknown'}
                  </FlexItem>
                </Flex>
              </div>
              
              <div style={{ marginBottom: '16px' }}>
                <Flex justifyContent={{ default: 'justifyContentSpaceBetween' }}>
                  <FlexItem>CPU Usage</FlexItem>
                  <FlexItem>
                    {systemStatus?.stats.cpuUsagePercent !== undefined
                      ? `${systemStatus.stats.cpuUsagePercent.toFixed(1)}%`
                      : 'Unknown'}
                  </FlexItem>
                </Flex>
                {systemStatus?.stats.cpuUsagePercent !== undefined && (
                  <Progress
                    value={systemStatus.stats.cpuUsagePercent}
                    title="CPU Usage"
                    variant={
                      systemStatus.stats.cpuUsagePercent > 80
                        ? 'danger'
                        : systemStatus.stats.cpuUsagePercent > 60
                        ? 'warning'
                        : 'success'
                    }
                  />
                )}
              </div>
            </CardBody>
          </Card>
        </GridItem>

        {/* Service Status */}
        <GridItem xl={6} lg={6} md={12} sm={12}>
          <Card>
            <CardTitle>Service Status</CardTitle>
            <CardBody>
              {systemStatus?.services ? (
                Object.entries(systemStatus.services).map(([service, status]) => (
                  <Flex
                    key={service}
                    justifyContent={{ default: 'justifyContentSpaceBetween' }}
                    alignItems={{ default: 'alignItemsCenter' }}
                    style={{ marginBottom: '12px' }}
                  >
                    <FlexItem>
                      <span style={{ textTransform: 'capitalize' }}>{service}</span>
                    </FlexItem>
                    <FlexItem>
                      <Flex alignItems={{ default: 'alignItemsCenter' }}>
                        <FlexItem spacer={{ default: 'spacerSm' }}>
                          {getServiceStatusIcon(status)}
                        </FlexItem>
                        <FlexItem>
                          <span style={{ textTransform: 'capitalize' }}>{status}</span>
                        </FlexItem>
                      </Flex>
                    </FlexItem>
                  </Flex>
                ))
              ) : (
                <p>No service information available</p>
              )}
            </CardBody>
          </Card>
        </GridItem>
      </Grid>
    </PageSection>
  );
};