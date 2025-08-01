# FiTrack Backend Setup Guide

## Prerequisites
- Node.js (v18 or higher)
- Bun (v1.2.19 or higher)
- MongoDB (running locally or cloud instance)

## Installation

1. **Install dependencies:**
   ```bash
   bun install
   ```

2. **Environment Configuration:**
   Create a `.env` file in the backend directory with the following variables:

   ```env
   # Database Configuration
   MONGODB_URI=mongodb://localhost:27017/fitrack

   # Server Configuration
   PORT=4000
   CLIENT_URL=http://localhost:8080

   # JWT and Session Secrets (Generated securely)
   JWT_SECRET=b77ad0216f9f611045bd2ac0d12fc24ebef7c959426d23f1fef56f174e025493e85a1d3a321abcba858c74fe4c038433c1b44dc330b3ec3f380d13ba5b8e03f7
   SESSION_SECRET=2923881343270f4fbaed48a573c01271ecd028407d94b944b354034e4557b0a0c3e31fca6092583b3bac543564dbe9b2eac9703f98996a3a032c5f833e84ff1e

   # Google OAuth Configuration
   GOOGLE_CLIENT_ID=your_google_client_id_here
   GOOGLE_CLIENT_SECRET=your_google_client_secret_here
   GOOGLE_CLIENT_REDIRECT=http://localhost:4000/api/v1/auth/google/callback
   ```

## Google OAuth Setup

1. **Create Google OAuth Credentials:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing one
   - Enable Google+ API
   - Go to Credentials → Create Credentials → OAuth 2.0 Client IDs
   - Set Application Type to "Web application"
   - Add authorized redirect URIs:
     - `http://localhost:4000/api/v1/auth/google/callback`
     - `http://localhost:8080/auth/google/callback` (for development)

2. **Update Environment Variables:**
   - Replace `your_google_client_id_here` with your actual Google Client ID
   - Replace `your_google_client_secret_here` with your actual Google Client Secret

## Available Routes

### Authentication Routes
- `POST /api/v1/auth/signup` - User registration
- `POST /api/v1/auth/signin` - User login
- `GET /api/v1/auth/google` - Google OAuth initiation
- `GET /api/v1/auth/google/callback` - Google OAuth callback
- `GET /api/v1/auth/google/failure` - Google OAuth failure
- `GET /api/v1/auth/logout` - User logout
- `GET /api/v1/auth/protected` - Protected route test

### Health Data Routes (Protected)
- `POST /api/v1/health/createHealthData` - Create health profile
- `GET /api/v1/health/getHealthDetauls` - Get health details
- `PUT /api/v1/health/updateHealthRecord` - Update health record

### Activity Routes (Protected)
- `POST /api/v1/activity/logActivity` - Log activity data
- `GET /api/v1/activity/getActivityLog` - Get activity logs
- `PUT /api/v1/activity/updateActivityLog` - Update activity log

## Running the Server

### Development Mode
```bash
bun run dev
```

### Production Mode
```bash
bun run build
bun run start
```

## Security Features

- **Rate Limiting:** Implemented on all routes
- **JWT Authentication:** Secure token-based authentication
- **Session Management:** Express sessions with secure configuration
- **CORS:** Configured for cross-origin requests
- **Input Validation:** Zod schema validation for all inputs
- **Password Hashing:** bcryptjs for secure password storage

## Database Models

### User Model
- Basic user information
- Google OAuth integration
- Password hashing
- JWT token support

### Health Input Details Model
- Gender, height, weight
- Body type and health goals
- User association

### Activity Model
- Sleep hours, steps, water intake
- Food calories tracking
- Date-based logging

## Error Handling

- Centralized error handling with asyncHandler
- Proper HTTP status codes
- Detailed error messages
- Validation error responses

## Testing

The server includes a health check endpoint:
- `GET /stats` - Returns server status

## Frontend Integration

The backend is configured to work with the Flutter frontend:
- CORS enabled for localhost:8080
- JWT token storage in SharedPreferences
- Google OAuth redirect handling
- API service integration ready 