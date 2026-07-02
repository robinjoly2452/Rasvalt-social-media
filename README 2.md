# Nova Social Network

A modern, full-stack social network application built with cutting-edge technologies.

## Project Overview

Nova is a comprehensive social networking platform featuring user profiles, posts, direct messaging, real-time notifications, and more.

## Tech Stack

### Backend
- **Runtime**: Node.js with TypeScript
- **Framework**: Express.js
- **Database**: PostgreSQL with Prisma ORM
- **Cache**: Redis
- **Authentication**: JWT
- **Password**: bcrypt

### Frontend
- **Framework**: React 18
- **Language**: TypeScript
- **Routing**: React Router v6
- **State Management**: Zustand
- **HTTP Client**: Axios
- **Styling**: Tailwind CSS
- **Build Tool**: Vite

### DevOps
- **Containerization**: Docker
- **Orchestration**: Docker Compose

## Static Preview

You can open `/index.html` directly in a browser to explore a frontend-only Nova Social demo with mock data, hash-based navigation, notifications, profile views, and an interactive network graph — no server required.

## Quick Start

### Prerequisites

- Node.js 18+
- Docker & Docker Compose
- Git

### Using Docker Compose (Recommended)

```bash
# Clone the repository
git clone https://github.com/robinjoly2452/nova-social-network.git
cd nova-social-network

# Start the application
docker-compose up -d

# Run migrations and seed database
docker exec nova_backend npm run prisma:migrate
docker exec nova_backend npm run prisma:seed
```

Application will be available at:
- **Frontend**: http://localhost:5173
- **Backend**: http://localhost:3000
- **Database**: postgresql://nova_user:nova_password_123@localhost:5432/nova_db
- **Redis**: redis://localhost:6379

### Local Development

```bash
# Install dependencies
npm install

# Backend setup
cd packages/backend
npm install
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
npm run dev

# Frontend setup (in another terminal)
cd packages/frontend
npm install
npm run dev
```

## Project Structure

```
nova-social-network/
├── packages/
│   ├── backend/
│   │   ├── src/
│   │   │   ├── controllers/     # Route controllers
│   │   │   ├── routes/          # API routes
│   │   │   ├── middleware/      # Express middleware
│   │   │   ├── lib/             # Utilities
│   │   │   └── index.ts         # Entry point
│   │   ├── prisma/
│   │   │   ├── schema.prisma    # Database schema
│   │   │   └── seed.ts          # Database seeding
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── frontend/
│       ├── src/
│       │   ├── components/      # React components
│       │   ├── pages/          # Page components
│       │   ├── services/       # API services
│       │   ├── store/          # Zustand stores
│       │   ├── types/          # TypeScript types
│       │   ├── App.tsx
│       │   └── main.tsx
│       ├── Dockerfile
│       ├── vite.config.ts
│       ├── tailwind.config.js
│       └── package.json
├── docker-compose.yml
└── README.md
```

## Features

### User Management
- User registration and login
- User profiles with bio and avatar
- Follow/unfollow users
- User verification badges

### Posts
- Create posts with text, images, and videos
- Like and unlike posts
- Save posts for later
- Delete own posts
- View post feed

### Comments
- Comment on posts
- Reply to comments
- Like comments
- Delete own comments

### Messaging
- Send direct messages
- View conversations
- Real-time message notifications
- Mark messages as read

### Notifications
- Like notifications
- Comment notifications
- Follow notifications
- Message notifications
- Mark as read

### Hashtags
- Hashtag extraction from posts
- Trending hashtags

## API Documentation

### Authentication Endpoints
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh token
- `GET /api/auth/me` - Get current user

### User Endpoints
- `GET /api/users/profile/:id` - Get user profile
- `POST /api/users/follow/:id` - Follow user
- `POST /api/users/unfollow/:id` - Unfollow user
- `GET /api/users/followers/:id` - Get followers
- `GET /api/users/following/:id` - Get following

### Post Endpoints
- `POST /api/posts` - Create post
- `GET /api/posts/feed` - Get feed
- `GET /api/posts/:id` - Get post
- `GET /api/posts/user/:id` - Get user posts
- `POST /api/posts/:id/like` - Like post
- `DELETE /api/posts/:id/like` - Unlike post
- `DELETE /api/posts/:id` - Delete post

### Comment Endpoints
- `POST /api/comments` - Create comment
- `GET /api/comments/post/:postId` - Get comments
- `POST /api/comments/:id/like` - Like comment
- `DELETE /api/comments/:id` - Delete comment

### Message Endpoints
- `POST /api/messages` - Send message
- `GET /api/messages/conversations` - Get conversations
- `GET /api/messages/:conversationId` - Get messages

### Notification Endpoints
- `GET /api/notifications` - Get notifications
- `PUT /api/notifications/:id/read` - Mark as read
- `DELETE /api/notifications/:id` - Delete notification

## Database Schema

The application uses PostgreSQL with Prisma ORM. Key models:

- **User**: User accounts with profiles
- **Post**: User posts with content and media
- **Comment**: Comments on posts with nesting support
- **Like**: Likes on posts and comments
- **Follow**: User follow relationships
- **Message**: Direct messages between users
- **Notification**: User notifications
- **Hashtag**: Hashtag tracking

## Security

- JWT-based authentication
- Password hashing with bcrypt
- CORS protection
- Input validation
- Error handling

## Future Enhancements

- [ ] Real-time WebSocket support
- [ ] Advanced search with filters
- [ ] Trending page
- [ ] User recommendations
- [ ] Video streaming
- [ ] Email notifications
- [ ] Two-factor authentication
- [ ] Admin dashboard
- [ ] Content moderation
- [ ] Analytics

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - feel free to use this project for personal or commercial purposes.

## Support

For support, email support@novasocial.com or open an issue on GitHub.

## Author

Created by Robin Joly

---

**Happy coding! 🚀**
