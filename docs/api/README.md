# AD-Stack API Documentation

## Overview

The AD-Stack REST API provides programmatic access to all identity management functions. This API is designed for:

- Web console frontend integration
- Third-party application integration
- Automation and scripting
- Mobile applications

## Base URL

```
https://your-ad-server:8080/api/v1
```

## Authentication

All API requests require authentication using JWT tokens.

### Obtaining a Token

```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "administrator",
  "password": "your-password"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_at": "2024-12-31T23:59:59Z"
  }
}
```

### Using the Token

Include the token in the Authorization header:

```bash
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Response Format

All API responses follow this format:

```json
{
  "success": boolean,
  "data": object | array | null,
  "error": string | null
}
```

## Error Handling

HTTP status codes and error responses:

| Status Code | Description |
|-------------|-------------|
| 200 | OK - Request successful |
| 201 | Created - Resource created successfully |
| 400 | Bad Request - Invalid request data |
| 401 | Unauthorized - Authentication required |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource not found |
| 409 | Conflict - Resource already exists |
| 500 | Internal Server Error - Server error |

Error response example:
```json
{
  "success": false,
  "data": null,
  "error": "User with username 'johndoe' already exists"
}
```

## API Endpoints

### Health Check

#### GET /health

Check API health status.

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "ok",
    "version": "0.1.0"
  }
}
```

### Authentication

#### POST /auth/login

Authenticate user and obtain JWT token.

**Request:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "string",
    "expires_at": "string (ISO 8601)"
  }
}
```

#### POST /auth/logout

Invalidate current token.

**Headers:** Authorization required

**Response:**
```json
{
  "success": true,
  "data": null
}
```

#### POST /auth/refresh

Refresh JWT token.

**Headers:** Authorization required

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "string",
    "expires_at": "string (ISO 8601)"
  }
}
```

### Users

#### GET /users

List all users.

**Headers:** Authorization required

**Query Parameters:**
- `limit` (optional): Number of results (default: 50, max: 100)
- `offset` (optional): Number of results to skip (default: 0)
- `search` (optional): Search term for username or email
- `enabled` (optional): Filter by enabled status (true/false)

**Response:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "uuid",
        "username": "string",
        "email": "string",
        "full_name": "string",
        "enabled": boolean,
        "created_at": "string (ISO 8601)",
        "updated_at": "string (ISO 8601)",
        "last_login": "string (ISO 8601) | null",
        "groups": ["string"]
      }
    ],
    "total": number,
    "limit": number,
    "offset": number
  }
}
```

#### GET /users/{username}

Get user details by username.

**Headers:** Authorization required

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "username": "string",
    "email": "string",
    "full_name": "string",
    "enabled": boolean,
    "created_at": "string (ISO 8601)",
    "updated_at": "string (ISO 8601)",
    "last_login": "string (ISO 8601) | null",
    "groups": ["string"],
    "attributes": {
      "department": "string",
      "title": "string",
      "phone": "string"
    }
  }
}
```

#### POST /users

Create a new user.

**Headers:** Authorization required

**Request:**
```json
{
  "username": "string (required, 3-64 chars, alphanumeric + underscore)",
  "email": "string (required, valid email)",
  "full_name": "string (required, 1-255 chars)",
  "password": "string (required, min 8 chars)",
  "enabled": boolean (optional, default: true),
  "attributes": {
    "department": "string (optional)",
    "title": "string (optional)",
    "phone": "string (optional)"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "username": "string",
    "email": "string",
    "full_name": "string",
    "enabled": boolean,
    "created_at": "string (ISO 8601)",
    "updated_at": "string (ISO 8601)",
    "groups": []
  }
}
```

#### PUT /users/{username}

Update user details.

**Headers:** Authorization required

**Request:**
```json
{
  "email": "string (optional)",
  "full_name": "string (optional)",
  "enabled": boolean (optional),
  "attributes": {
    "department": "string (optional)",
    "title": "string (optional)",
    "phone": "string (optional)"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "username": "string",
    "email": "string",
    "full_name": "string",
    "enabled": boolean,
    "created_at": "string (ISO 8601)",
    "updated_at": "string (ISO 8601)",
    "groups": ["string"]
  }
}
```

#### DELETE /users/{username}

Delete a user.

**Headers:** Authorization required

**Response:**
```json
{
  "success": true,
  "data": null
}
```

#### POST /users/{username}/password

Change user password.

**Headers:** Authorization required

**Request:**
```json
{
  "new_password": "string (required, min 8 chars)",
  "current_password": "string (required if changing own password)"
}
```

**Response:**
```json
{
  "success": true,
  "data": null
}
```

#### POST /users/{username}/enable

Enable a user account.

**Headers:** Authorization required

**Response:**
```json
{
  "success": true,
  "data": null
}
```

#### POST /users/{username}/disable

Disable a user account.

**Headers:** Authorization required

**Response:**
```json
{
  "success": true,
  "data": null
}
```

### Groups

#### GET /groups

List all groups.

**Headers:** Authorization required

**Query Parameters:**
- `limit` (optional): Number of results (default: 50, max: 100)
- `offset` (optional): Number of results to skip (default: 0)
- `search` (optional): Search term for group name
- `type` (optional): Filter by group type (security/distribution)

**Response:**
```json
{
  "success": true,
  "data": {
    "groups": [
      {
        "id": "uuid",
        "name": "string",
        "description": "string",
        "type": "security | distribution",
        "member_count": number,
        "created_at": "string (ISO 8601)",
        "updated_at": "string (ISO 8601)"
      }
    ],
    "total": number,
    "limit": number,
    "offset": number
  }
}
```

#### GET /groups/{name}

Get group details by name.

**Headers:** Authorization required

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "description": "string",
    "type": "security | distribution",
    "members": [
      {
        "username": "string",
        "full_name": "string",
        "email": "string"
      }
    ],
    "created_at": "string (ISO 8601)",
    "updated_at": "string (ISO 8601)"
  }
}
```

#### POST /groups

Create a new group.

**Headers:** Authorization required

**Request:**
```json
{
  "name": "string (required, 3-64 chars, alphanumeric + underscore)",
  "description": "string (optional, max 255 chars)",
  "type": "security | distribution (optional, default: security)"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "description": "string",
    "type": "security | distribution",
    "members": [],
    "created_at": "string (ISO 8601)",
    "updated_at": "string (ISO 8601)"
  }
}
```

#### PUT /groups/{name}

Update group details.

**Headers:** Authorization required

**Request:**
```json
{
  "description": "string (optional)",
  "type": "security | distribution (optional)"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "description": "string",
    "type": "security | distribution",
    "member_count": number,
    "created_at": "string (ISO 8601)",
    "updated_at": "string (ISO 8601)"
  }
}
```

#### DELETE /groups/{name}

Delete a group.

**Headers:** Authorization required

**Response:**
```json
{
  "success": true,
  "data": null
}
```

#### POST /groups/{name}/members

Add user to group.

**Headers:** Authorization required

**Request:**
```json
{
  "username": "string (required)"
}
```

**Response:**
```json
{
  "success": true,
  "data": null
}
```

#### DELETE /groups/{name}/members/{username}

Remove user from group.

**Headers:** Authorization required

**Response:**
```json
{
  "success": true,
  "data": null
}
```

### System Information

#### GET /system/status

Get system status information.

**Headers:** Authorization required

**Response:**
```json
{
  "success": true,
  "data": {
    "services": {
      "orchestrator": "running",
      "samba": "running",
      "dns": "running",
      "database": "running",
      "cache": "running"
    },
    "stats": {
      "user_count": number,
      "group_count": number,
      "uptime_seconds": number,
      "memory_usage_mb": number,
      "cpu_usage_percent": number
    },
    "version": "string"
  }
}
```

#### GET /system/logs

Get system logs.

**Headers:** Authorization required

**Query Parameters:**
- `service` (optional): Filter by service name
- `level` (optional): Filter by log level (debug/info/warn/error)
- `since` (optional): ISO 8601 timestamp for start time
- `limit` (optional): Number of log entries (default: 100, max: 1000)

**Response:**
```json
{
  "success": true,
  "data": {
    "logs": [
      {
        "timestamp": "string (ISO 8601)",
        "level": "debug | info | warn | error",
        "service": "string",
        "message": "string",
        "metadata": object
      }
    ],
    "total": number
  }
}
```

## Code Examples

### JavaScript/TypeScript

```typescript
class ADStackClient {
  private baseUrl: string;
  private token: string | null = null;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  async login(username: string, password: string): Promise<void> {
    const response = await fetch(`${this.baseUrl}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ username, password }),
    });

    const data = await response.json();
    if (data.success) {
      this.token = data.data.token;
    } else {
      throw new Error(data.error);
    }
  }

  async getUsers(): Promise<User[]> {
    const response = await this.request('/users');
    return response.data.users;
  }

  async createUser(userData: CreateUserRequest): Promise<User> {
    const response = await this.request('/users', {
      method: 'POST',
      body: JSON.stringify(userData),
    });
    return response.data;
  }

  private async request(path: string, options: RequestInit = {}): Promise<any> {
    const response = await fetch(`${this.baseUrl}${path}`, {
      ...options,
      headers: {
        'Authorization': `Bearer ${this.token}`,
        'Content-Type': 'application/json',
        ...options.headers,
      },
    });

    const data = await response.json();
    if (!data.success) {
      throw new Error(data.error);
    }
    return data;
  }
}

// Usage
const client = new ADStackClient('https://ad-server:8080/api/v1');
await client.login('admin', 'password');

const users = await client.getUsers();
console.log('Users:', users);

const newUser = await client.createUser({
  username: 'johndoe',
  email: 'john@example.com',
  full_name: 'John Doe',
  password: 'SecurePassword123!',
});
console.log('Created user:', newUser);
```

### Python

```python
import requests
from typing import Optional, List, Dict, Any

class ADStackClient:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.token: Optional[str] = None
        self.session = requests.Session()

    def login(self, username: str, password: str) -> None:
        response = self.session.post(
            f"{self.base_url}/auth/login",
            json={"username": username, "password": password}
        )
        data = response.json()
        
        if data["success"]:
            self.token = data["data"]["token"]
            self.session.headers.update({
                "Authorization": f"Bearer {self.token}"
            })
        else:
            raise Exception(data["error"])

    def get_users(self, limit: int = 50, offset: int = 0) -> List[Dict[str, Any]]:
        response = self._request("GET", "/users", params={
            "limit": limit,
            "offset": offset
        })
        return response["data"]["users"]

    def create_user(self, user_data: Dict[str, Any]) -> Dict[str, Any]:
        response = self._request("POST", "/users", json=user_data)
        return response["data"]

    def get_user(self, username: str) -> Dict[str, Any]:
        response = self._request("GET", f"/users/{username}")
        return response["data"]

    def update_user(self, username: str, user_data: Dict[str, Any]) -> Dict[str, Any]:
        response = self._request("PUT", f"/users/{username}", json=user_data)
        return response["data"]

    def delete_user(self, username: str) -> None:
        self._request("DELETE", f"/users/{username}")

    def _request(self, method: str, path: str, **kwargs) -> Dict[str, Any]:
        response = self.session.request(method, f"{self.base_url}{path}", **kwargs)
        response.raise_for_status()
        
        data = response.json()
        if not data["success"]:
            raise Exception(data["error"])
        
        return data

# Usage
client = ADStackClient("https://ad-server:8080/api/v1")
client.login("admin", "password")

# List users
users = client.get_users()
print(f"Found {len(users)} users")

# Create user
new_user = client.create_user({
    "username": "johndoe",
    "email": "john@example.com",
    "full_name": "John Doe",
    "password": "SecurePassword123!"
})
print(f"Created user: {new_user['username']}")

# Get user details
user = client.get_user("johndoe")
print(f"User details: {user}")
```

### Bash/cURL

```bash
#!/bin/bash

API_BASE="https://ad-server:8080/api/v1"
TOKEN=""

# Login and get token
login() {
    local username="$1"
    local password="$2"
    
    response=$(curl -s -X POST "$API_BASE/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\": \"$username\", \"password\": \"$password\"}")
    
    TOKEN=$(echo "$response" | jq -r '.data.token')
    
    if [ "$TOKEN" = "null" ]; then
        echo "Login failed"
        exit 1
    fi
    
    echo "Logged in successfully"
}

# Make authenticated request
api_request() {
    local method="$1"
    local path="$2"
    local data="$3"
    
    if [ -n "$data" ]; then
        curl -s -X "$method" "$API_BASE$path" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$data"
    else
        curl -s -X "$method" "$API_BASE$path" \
            -H "Authorization: Bearer $TOKEN"
    fi
}

# Create user
create_user() {
    local username="$1"
    local email="$2"
    local full_name="$3"
    local password="$4"
    
    data=$(jq -n \
        --arg username "$username" \
        --arg email "$email" \
        --arg full_name "$full_name" \
        --arg password "$password" \
        '{username: $username, email: $email, full_name: $full_name, password: $password}')
    
    api_request "POST" "/users" "$data"
}

# Usage
login "admin" "password"

# List users
echo "Users:"
api_request "GET" "/users" | jq '.data.users[] | {username, email, full_name}'

# Create user
echo "Creating user..."
create_user "johndoe" "john@example.com" "John Doe" "SecurePassword123!"

# Get user details
echo "User details:"
api_request "GET" "/users/johndoe" | jq '.data'
```

## Rate Limiting

API requests are rate limited to prevent abuse:

- **Authentication endpoints**: 5 requests per minute per IP
- **User management**: 60 requests per minute per token
- **System information**: 30 requests per minute per token

Rate limit headers are included in responses:
- `X-RateLimit-Limit`: Request limit per window
- `X-RateLimit-Remaining`: Remaining requests in current window
- `X-RateLimit-Reset`: Time when the rate limit resets (Unix timestamp)

## Webhooks

AD-Stack can send webhooks for important events:

### Configuration

Configure webhooks in the admin console or via API:

```json
{
  "url": "https://your-app.com/webhooks/ad-stack",
  "events": ["user.created", "user.deleted", "user.disabled"],
  "secret": "your-webhook-secret"
}
```

### Event Types

- `user.created`: New user created
- `user.updated`: User details updated
- `user.deleted`: User deleted
- `user.enabled`: User account enabled
- `user.disabled`: User account disabled
- `user.password_changed`: User password changed
- `group.created`: New group created
- `group.updated`: Group details updated
- `group.deleted`: Group deleted
- `group.member_added`: User added to group
- `group.member_removed`: User removed from group

### Payload Format

```json
{
  "event": "user.created",
  "timestamp": "2024-01-01T12:00:00Z",
  "data": {
    "user": {
      "id": "uuid",
      "username": "johndoe",
      "email": "john@example.com",
      "full_name": "John Doe"
    }
  }
}
```

### Security

Webhooks are signed with HMAC-SHA256. Verify the signature using the `X-Signature` header:

```python
import hmac
import hashlib

def verify_webhook(payload, signature, secret):
    expected = hmac.new(
        secret.encode('utf-8'),
        payload.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()
    
    return hmac.compare_digest(f"sha256={expected}", signature)
```

## SDK Libraries

Official SDKs are available for popular languages:

- **JavaScript/TypeScript**: `npm install @ad-stack/client`
- **Python**: `pip install ad-stack-client`
- **Go**: `go get github.com/ad-stack/go-client`
- **PHP**: `composer require ad-stack/php-client`

Community SDKs:
- **C#**: Available on NuGet
- **Ruby**: Available as gem
- **Java**: Available on Maven Central

For the latest SDK documentation, visit: https://docs.ad-stack.org/sdks