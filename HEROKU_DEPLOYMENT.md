# Heroku Deployment Guide for Nova Social Network

## Prerequisites

- Heroku CLI installed
- Git repository initialized
- GitHub account (for auto-deployment)

## Deployment Steps

### 1. Create Heroku Apps

```bash
# Login to Heroku
heroku login

# Create main app (backend + frontend)
heroku create nova-social-network

# Or create separate apps
heroku create nova-social-backend
heroku create nova-social-frontend
```

### 2. Add PostgreSQL and Redis Add-ons

```bash
# Add PostgreSQL
heroku addons:create heroku-postgresql:standard-0 --app nova-social-network

# Add Redis
heroku addons:create heroku-redis:premium-0 --app nova-social-network
```

### 3. Set Environment Variables

```bash
# Set required environment variables
heroku config:set NODE_ENV=production --app nova-social-network
heroku config:set JWT_SECRET=$(openssl rand -base64 32) --app nova-social-network
heroku config:set BACKEND_PORT=5000 --app nova-social-network
heroku config:set FRONTEND_URL=https://nova-social-network.herokuapp.com --app nova-social-network
heroku config:set CORS_ORIGIN=https://nova-social-network.herokuapp.com --app nova-social-network

# Database and Redis URLs are set automatically by add-ons
# Verify with:
heroku config --app nova-social-network
```

### 4. Add Heroku Remote

```bash
git remote add heroku https://git.heroku.com/nova-social-network.git
```

### 5. Deploy

```bash
# Deploy to Heroku
git push heroku main

# Or if deploying from a different branch
git push heroku develop:main
```

### 6. Check Logs

```bash
heroku logs --tail --app nova-social-network
```

### 7. Run Migrations (if not in build process)

```bash
heroku run "cd packages/backend && npm run prisma:migrate" --app nova-social-network
```

### 8. Seed Database

```bash
heroku run "cd packages/backend && npm run prisma:seed" --app nova-social-network
```

## Alternative: Deploy Frontend to Heroku

If you want to serve frontend separately:

### 1. Create Frontend App

```bash
heroku create nova-social-frontend
```

### 2. Deploy Frontend

```bash
# Add buildpack for static site
heroku buildpacks:add https://github.com/heroku/heroku-buildpack-static.git -a nova-social-frontend

# Create static.json in frontend directory
cd packages/frontend
```

### 3. Configure static.json

Create `packages/frontend/static.json`:

```json
{
  "root": "dist/",
  "clean_urls": true,
  "routes": {
    "/**": "index.html"
  }
}
```

### 4. Set Environment Variables

```bash
heroku config:set VITE_API_URL=https://nova-social-backend.herokuapp.com/api --app nova-social-frontend
```

### 5. Deploy

```bash
# From root directory
git push heroku main --app nova-social-frontend
```

## Enable GitHub Auto-Deployment

1. Go to Heroku Dashboard
2. Select your app
3. Go to Deploy tab
4. Click "Connect to GitHub"
5. Search for your repository
6. Click "Connect"
7. Enable "Automatic deploys" for main branch

## Database Backups

```bash
# Create backup
heroku pg:backups:capture --app nova-social-network

# Download backup
heroku pg:backups:download --app nova-social-network

# List backups
heroku pg:backups --app nova-social-network
```

## Monitoring

```bash
# Check app status
heroku ps --app nova-social-network

# Check resource usage
heroku ps:type --app nova-social-network

# Scale dynos
heroku ps:scale web=2 --app nova-social-network
```

## Troubleshooting

### Build Errors

```bash
# Clear build cache
heroku builds:cancel --app nova-social-network
heroku config:set NODE_BUILD_FLAGS=--unsafe-perm --app nova-social-network
```

### Database Connection Issues

```bash
# Check database
heroku pg:info --app nova-social-network

# Reset database (careful!)
heroku pg:reset DATABASE --app nova-social-network
```

### View Full Logs

```bash
heroku logs --tail --app nova-social-network --lines 50
```

## Production Checklist

- [ ] Environment variables set correctly
- [ ] Database migrations run
- [ ] Database seeded with initial data
- [ ] SSL/HTTPS enabled (automatic with Heroku)
- [ ] CORS configured properly
- [ ] JWT secret is strong and unique
- [ ] Database backups configured
- [ ] Monitoring enabled
- [ ] Error tracking configured (optional: Sentry)
- [ ] Email service configured (optional)

## Useful Commands

```bash
# Open app in browser
heroku open --app nova-social-network

# Run command on Heroku
heroku run "command" --app nova-social-network

# View config
heroku config --app nova-social-network

# View app info
heroku apps:info --app nova-social-network

# Restart app
heroku restart --app nova-social-network

# Scale up
heroku ps:scale web=2 --app nova-social-network
```

## Cost Considerations

- **Free Tier**: Limited (no longer available for new apps)
- **Standard Dyno**: ~$50/month per dyno
- **PostgreSQL**: ~$50/month for Standard
- **Redis**: ~$30/month for Premium-0
- **Total Estimate**: ~$130-150/month for production setup

## Next Steps

1. Set up monitoring with Sentry or similar
2. Configure email service for notifications
3. Set up CI/CD pipeline
4. Configure CDN for static assets
5. Set up log aggregation
6. Configure alerting

## Support

For more information, visit:
- https://devcenter.heroku.com/
- https://devcenter.heroku.com/articles/git
- https://devcenter.heroku.com/articles/config-vars
