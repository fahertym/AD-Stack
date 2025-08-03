# AD-Stack Development Guide

## Getting Started

This guide will help you set up a development environment for AD-Stack and make your first contribution.

## Prerequisites

### Required Software
- **Rust** 1.70+ (latest stable recommended)
- **Node.js** 18+ and npm
- **Docker** and Docker Compose
- **Git** version control
- **PostgreSQL** 14+ (for database development)
- **Redis** 6+ (for caching)

### Development Tools (Recommended)
- **VS Code** or **IntelliJ IDEA** with Rust plugin
- **pgAdmin** or **DBeaver** for database management
- **Postman** or **Insomnia** for API testing
- **GitKraken** or **SourceTree** for Git GUI

## Environment Setup

### 1. Clone the Repository
```bash
git clone https://github.com/fahertym/AD-Stack.git
cd AD-Stack
```

### 2. Install Rust
```bash
# Install rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# Install required components
rustup component add clippy rustfmt
rustup target add x86_64-unknown-linux-musl
```

### 3. Install Node.js
```bash
# Using Node Version Manager (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18

# Or using package manager
sudo apt install nodejs npm  # Ubuntu/Debian
sudo dnf install nodejs npm  # RHEL/Fedora
```

### 4. Install Docker
```bash
# Install Docker
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER

# Install Docker Compose plugin
sudo apt install docker-compose-plugin  # Ubuntu/Debian
sudo dnf install docker-compose-plugin  # RHEL/Fedora
```

### 5. Setup Development Environment
```bash
# Start development services
docker compose -f docker/dev/docker-compose.yml up -d

# Install Rust dependencies
cargo build

# Install frontend dependencies
cd ui && npm install && cd ..

# Run database migrations (when available)
# cargo run --bin migrate

# Initialize development data
./scripts/dev-setup.sh
```

## Project Structure

```
AD-Stack/
├── .github/              # GitHub templates and workflows
├── ansible/              # Deployment automation
├── cmd/                  # Binary applications
│   ├── ad-stack-cli/     # Command-line interface
│   └── orchestrator/     # Service orchestrator
├── docker/               # Container configurations
│   ├── dev/              # Development environment
│   └── production/       # Production containers
├── docs/                 # Documentation
├── scripts/              # Utility scripts
├── src/                  # Core library code
│   ├── api/              # REST API endpoints
│   ├── config/           # Configuration management
│   └── orchestration/    # Service coordination
├── tests/                # Test files
├── ui/                   # Frontend React application
└── Cargo.toml            # Rust workspace configuration
```

## Development Workflow

### 1. Create a Feature Branch
```bash
git checkout -b feature/user-management-api
```

### 2. Make Changes
Follow the coding standards and write tests for new functionality.

### 3. Run Tests
```bash
# Run all Rust tests
cargo test

# Run frontend tests
cd ui && npm test

# Run integration tests
cargo test --test integration_tests

# Run linting
cargo clippy -- -D warnings
cargo fmt --check
```

### 4. Commit Changes
```bash
git add .
git commit -m "feat: add user management API endpoints

- Add CRUD operations for user management
- Include input validation and error handling
- Add comprehensive test coverage
- Update API documentation

Closes #123"
```

### 5. Push and Create PR
```bash
git push origin feature/user-management-api
# Create pull request via GitHub web interface
```

## Coding Standards

### Rust Code Style

#### 1. Use `rustfmt` for Formatting
```bash
cargo fmt
```

#### 2. Follow Rust Naming Conventions
```rust
// Good
struct UserAccount {
    user_name: String,
    email_address: String,
}

impl UserAccount {
    pub fn new(user_name: String, email_address: String) -> Self {
        Self { user_name, email_address }
    }
    
    pub fn get_display_name(&self) -> &str {
        &self.user_name
    }
}

// Function names use snake_case
pub async fn create_user_account(user_data: UserData) -> Result<User, Error> {
    // Implementation
}

// Constants use SCREAMING_SNAKE_CASE
const MAX_USERNAME_LENGTH: usize = 64;
```

#### 3. Error Handling
```rust
use anyhow::{Context, Result};
use thiserror::Error;

#[derive(Debug, Error)]
pub enum UserError {
    #[error("User not found: {username}")]
    NotFound { username: String },
    
    #[error("Invalid email format: {email}")]
    InvalidEmail { email: String },
    
    #[error("Database error")]
    Database(#[from] sqlx::Error),
}

pub async fn get_user(username: &str) -> Result<User> {
    let user = database::find_user(username)
        .await
        .context("Failed to query user database")?
        .ok_or_else(|| UserError::NotFound { 
            username: username.to_string() 
        })?;
    
    Ok(user)
}
```

#### 4. Documentation
```rust
/// Creates a new user account with the specified details.
/// 
/// # Arguments
/// 
/// * `username` - The unique username for the account
/// * `email` - The user's email address
/// * `password` - The user's password (will be hashed)
/// 
/// # Returns
/// 
/// Returns `Ok(User)` if successful, or an error if:
/// - Username already exists
/// - Email format is invalid
/// - Password doesn't meet complexity requirements
/// 
/// # Examples
/// 
/// ```rust
/// let user = create_user("johndoe", "john@example.com", "SecurePass123!").await?;
/// println!("Created user: {}", user.username);
/// ```
pub async fn create_user(
    username: &str, 
    email: &str, 
    password: &str
) -> Result<User, UserError> {
    // Implementation
}
```

### Frontend Code Style

#### 1. Use Prettier and ESLint
```bash
cd ui
npm run lint
npm run format
```

#### 2. Component Structure
```typescript
// UserList.tsx
import React, { useState, useEffect } from 'react';
import { 
  Page, 
  PageSection, 
  Title,
  Button,
  Toolbar,
  ToolbarContent,
  ToolbarItem
} from '@patternfly/react-core';
import { Table, Thead, Tr, Th, Tbody, Td } from '@patternfly/react-table';

interface User {
  id: string;
  username: string;
  email: string;
  fullName: string;
  createdAt: string;
}

interface UserListProps {
  onUserSelect?: (user: User) => void;
}

export const UserList: React.FC<UserListProps> = ({ onUserSelect }) => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/v1/users');
      if (!response.ok) {
        throw new Error('Failed to fetch users');
      }
      const data = await response.json();
      setUsers(data.data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Page>
      <PageSection variant="light">
        <Title headingLevel="h1" size="lg">
          User Management
        </Title>
      </PageSection>
      
      <PageSection>
        <Toolbar>
          <ToolbarContent>
            <ToolbarItem>
              <Button variant="primary" onClick={() => {}}>
                Create User
              </Button>
            </ToolbarItem>
          </ToolbarContent>
        </Toolbar>
        
        {/* Table implementation */}
        <Table aria-label="Users table">
          <Thead>
            <Tr>
              <Th>Username</Th>
              <Th>Full Name</Th>
              <Th>Email</Th>
              <Th>Created</Th>
              <Th>Actions</Th>
            </Tr>
          </Thead>
          <Tbody>
            {users.map((user) => (
              <Tr key={user.id}>
                <Td>{user.username}</Td>
                <Td>{user.fullName}</Td>
                <Td>{user.email}</Td>
                <Td>{new Date(user.createdAt).toLocaleDateString()}</Td>
                <Td>
                  <Button 
                    variant="link" 
                    onClick={() => onUserSelect?.(user)}
                  >
                    Edit
                  </Button>
                </Td>
              </Tr>
            ))}
          </Tbody>
        </Table>
      </PageSection>
    </Page>
  );
};
```

#### 3. API Integration
```typescript
// api/users.ts
export interface CreateUserRequest {
  username: string;
  email: string;
  fullName: string;
  password: string;
}

export interface User {
  id: string;
  username: string;
  email: string;
  fullName: string;
  createdAt: string;
  updatedAt: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
}

class UserService {
  private baseUrl = '/api/v1/users';

  async getUsers(): Promise<User[]> {
    const response = await fetch(this.baseUrl);
    const data: ApiResponse<User[]> = await response.json();
    
    if (!data.success) {
      throw new Error(data.error || 'Failed to fetch users');
    }
    
    return data.data || [];
  }

  async createUser(userData: CreateUserRequest): Promise<User> {
    const response = await fetch(this.baseUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(userData),
    });

    const data: ApiResponse<User> = await response.json();
    
    if (!data.success) {
      throw new Error(data.error || 'Failed to create user');
    }
    
    return data.data!;
  }

  async updateUser(id: string, userData: Partial<CreateUserRequest>): Promise<User> {
    const response = await fetch(`${this.baseUrl}/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(userData),
    });

    const data: ApiResponse<User> = await response.json();
    
    if (!data.success) {
      throw new Error(data.error || 'Failed to update user');
    }
    
    return data.data!;
  }

  async deleteUser(id: string): Promise<void> {
    const response = await fetch(`${this.baseUrl}/${id}`, {
      method: 'DELETE',
    });

    if (!response.ok) {
      const data: ApiResponse<void> = await response.json();
      throw new Error(data.error || 'Failed to delete user');
    }
  }
}

export const userService = new UserService();
```

## Testing Guidelines

### Unit Tests
```rust
#[cfg(test)]
mod tests {
    use super::*;
    use mockall::predicate::*;

    #[tokio::test]
    async fn test_create_user_success() {
        // Arrange
        let mut mock_db = MockDatabase::new();
        mock_db
            .expect_find_user()
            .with(eq("johndoe"))
            .returning(|_| Ok(None));
        
        mock_db
            .expect_create_user()
            .returning(|user| Ok(user));

        // Act
        let result = create_user_with_db(
            &mock_db,
            "johndoe",
            "john@example.com",
            "password123"
        ).await;

        // Assert
        assert!(result.is_ok());
        let user = result.unwrap();
        assert_eq!(user.username, "johndoe");
        assert_eq!(user.email, "john@example.com");
    }

    #[tokio::test]
    async fn test_create_user_duplicate_username() {
        // Arrange
        let mut mock_db = MockDatabase::new();
        mock_db
            .expect_find_user()
            .with(eq("johndoe"))
            .returning(|_| Ok(Some(User::default())));

        // Act
        let result = create_user_with_db(
            &mock_db,
            "johndoe",
            "john@example.com",
            "password123"
        ).await;

        // Assert
        assert!(result.is_err());
        match result.unwrap_err() {
            UserError::DuplicateUsername { username } => {
                assert_eq!(username, "johndoe");
            }
            _ => panic!("Expected DuplicateUsername error"),
        }
    }
}
```

### Integration Tests
```rust
// tests/integration_tests.rs
use ad_stack::api::create_router;
use axum::{
    body::Body,
    http::{Request, StatusCode},
};
use serde_json::Value;
use tower::util::ServiceExt;

#[tokio::test]
async fn test_user_crud_workflow() {
    // Setup test database
    let test_db = setup_test_database().await;
    let app = create_router_with_db(test_db);

    // Test user creation
    let create_request = Request::builder()
        .uri("/api/v1/users")
        .method("POST")
        .header("content-type", "application/json")
        .body(Body::from(r#"
            {
                "username": "testuser",
                "email": "test@example.com",
                "fullName": "Test User",
                "password": "TestPassword123!"
            }
        "#))
        .unwrap();

    let response = app.clone().oneshot(create_request).await.unwrap();
    assert_eq!(response.status(), StatusCode::CREATED);

    // Test user retrieval
    let get_request = Request::builder()
        .uri("/api/v1/users/testuser")
        .body(Body::empty())
        .unwrap();

    let response = app.clone().oneshot(get_request).await.unwrap();
    assert_eq!(response.status(), StatusCode::OK);

    // Test user update
    let update_request = Request::builder()
        .uri("/api/v1/users/testuser")
        .method("PUT")
        .header("content-type", "application/json")
        .body(Body::from(r#"
            {
                "fullName": "Updated Test User"
            }
        "#))
        .unwrap();

    let response = app.clone().oneshot(update_request).await.unwrap();
    assert_eq!(response.status(), StatusCode::OK);

    // Test user deletion
    let delete_request = Request::builder()
        .uri("/api/v1/users/testuser")
        .method("DELETE")
        .body(Body::empty())
        .unwrap();

    let response = app.oneshot(delete_request).await.unwrap();
    assert_eq!(response.status(), StatusCode::NO_CONTENT);
}
```

### Frontend Tests
```typescript
// UserList.test.tsx
import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserList } from './UserList';

// Mock fetch
global.fetch = jest.fn();

const mockUsers = [
  {
    id: '1',
    username: 'johndoe',
    email: 'john@example.com',
    fullName: 'John Doe',
    createdAt: '2024-01-01T00:00:00Z',
  },
  {
    id: '2',
    username: 'janedoe',
    email: 'jane@example.com',
    fullName: 'Jane Doe',
    createdAt: '2024-01-02T00:00:00Z',
  },
];

describe('UserList', () => {
  beforeEach(() => {
    (fetch as jest.Mock).mockClear();
  });

  it('renders user list successfully', async () => {
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        success: true,
        data: mockUsers,
      }),
    });

    render(<UserList />);

    // Check loading state initially
    expect(screen.getByText('Loading...')).toBeInTheDocument();

    // Wait for users to load
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });

    expect(screen.getByText('Jane Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });

  it('handles user selection', async () => {
    const onUserSelect = jest.fn();
    
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        success: true,
        data: mockUsers,
      }),
    });

    render(<UserList onUserSelect={onUserSelect} />);

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });

    // Click edit button for first user
    const editButtons = screen.getAllByText('Edit');
    await userEvent.click(editButtons[0]);

    expect(onUserSelect).toHaveBeenCalledWith(mockUsers[0]);
  });

  it('displays error message on fetch failure', async () => {
    (fetch as jest.Mock).mockRejectedValueOnce(new Error('Network error'));

    render(<UserList />);

    await waitFor(() => {
      expect(screen.getByText(/Network error/i)).toBeInTheDocument();
    });
  });
});
```

## Database Development

### Schema Migrations
```rust
// migrations/001_initial_schema.sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(64) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(64) UNIQUE NOT NULL,
    description TEXT,
    group_type VARCHAR(32) NOT NULL DEFAULT 'security',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_groups (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, group_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_groups_name ON groups(name);
CREATE INDEX idx_user_groups_user_id ON user_groups(user_id);
CREATE INDEX idx_user_groups_group_id ON user_groups(group_id);

-- Updated timestamp triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_groups_updated_at 
    BEFORE UPDATE ON groups 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Database Testing
```rust
#[cfg(test)]
mod db_tests {
    use super::*;
    use sqlx::PgPool;
    use testcontainers::{clients::Cli, images::postgres::Postgres, Container};

    struct TestDatabase {
        _container: Container<'static, Postgres>,
        pool: PgPool,
    }

    impl TestDatabase {
        async fn new() -> Self {
            let docker = Cli::default();
            let container = docker.run(Postgres::default());
            let port = container.get_host_port_ipv4(5432);
            
            let database_url = format!(
                "postgresql://postgres:postgres@localhost:{}/postgres",
                port
            );
            
            let pool = PgPool::connect(&database_url).await.unwrap();
            
            // Run migrations
            sqlx::migrate!("./migrations").run(&pool).await.unwrap();
            
            Self {
                _container: container,
                pool,
            }
        }
    }

    #[tokio::test]
    async fn test_user_crud_operations() {
        let test_db = TestDatabase::new().await;
        
        // Test user creation
        let user = create_user(&test_db.pool, "testuser", "test@example.com").await.unwrap();
        assert_eq!(user.username, "testuser");
        
        // Test user retrieval
        let retrieved_user = get_user_by_username(&test_db.pool, "testuser").await.unwrap();
        assert_eq!(retrieved_user.id, user.id);
        
        // Test user update
        update_user_email(&test_db.pool, user.id, "newemail@example.com").await.unwrap();
        let updated_user = get_user_by_id(&test_db.pool, user.id).await.unwrap();
        assert_eq!(updated_user.email, "newemail@example.com");
        
        // Test user deletion
        delete_user(&test_db.pool, user.id).await.unwrap();
        let deleted_user = get_user_by_id(&test_db.pool, user.id).await;
        assert!(deleted_user.is_err());
    }
}
```

## Debugging

### Rust Debugging
```rust
// Enable debug logging
RUST_LOG=debug cargo run

// Use dbg! macro for quick debugging
let user = dbg!(create_user("test").await?);

// Use tracing for structured logging
use tracing::{info, warn, error, debug};

#[tracing::instrument]
async fn create_user(username: &str) -> Result<User> {
    info!("Creating user: {}", username);
    
    match validate_username(username) {
        Ok(_) => debug!("Username validation passed"),
        Err(e) => {
            warn!("Username validation failed: {}", e);
            return Err(e.into());
        }
    }
    
    // ...
}
```

### Frontend Debugging
```typescript
// Enable debug logs
localStorage.setItem('debug', 'ad-stack:*');

// Use React Developer Tools
// Chrome Extension: React Developer Tools

// Debug API calls
const debugFetch = async (url: string, options?: RequestInit) => {
  console.log('API Request:', { url, options });
  const response = await fetch(url, options);
  const data = await response.json();
  console.log('API Response:', { url, data });
  return data;
};
```

## Contributing Guidelines

### 1. Code of Conduct
Please read and follow our [Code of Conduct](../CODE_OF_CONDUCT.md).

### 2. Issue Tracking
- Check existing issues before creating new ones
- Use issue templates for bug reports and feature requests
- Provide detailed reproduction steps for bugs

### 3. Pull Request Process
- Fork the repository
- Create a feature branch from `develop`
- Make your changes with appropriate tests
- Ensure all tests pass and code is formatted
- Create a pull request with detailed description
- Respond to code review feedback

### 4. Documentation
- Update documentation for new features
- Include code examples in documentation
- Update API documentation for endpoint changes

### 5. Testing
- Write unit tests for new functionality
- Add integration tests for API endpoints
- Ensure all tests pass before submitting PR

## Getting Help

### Community Resources
- **GitHub Discussions**: https://github.com/fahertym/AD-Stack/discussions
- **Discord**: https://discord.gg/ad-stack
- **Documentation**: https://docs.ad-stack.org

### Mentorship Program
New contributors can request mentorship for:
- First-time contributions
- Complex feature development
- Architecture discussions
- Code review guidance

Contact: mentorship@ad-stack.org

## Release Process

### Development Flow
```
develop -> feature/branch -> develop -> release/x.y.z -> main
```

### Version Numbering
We follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version numbers bumped
- [ ] Security review completed
- [ ] Performance testing completed