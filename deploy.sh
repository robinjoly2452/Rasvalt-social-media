#!/bin/bash
# Heroku deployment script

set -e

echo "🚀 Nova Social Network - Heroku Deployment Script"
echo ""

# Check if Heroku CLI is installed
if ! command -v heroku &> /dev/null; then
    echo "❌ Heroku CLI is not installed. Please install it first:"
    echo "   https://devcenter.heroku.com/articles/heroku-cli"
    exit 1
fi

# Check if git is initialized
if [ ! -d .git ]; then
    echo "❌ Git is not initialized. Run 'git init' first."
    exit 1
fi

echo "1️⃣  Logging in to Heroku..."
heroku login

read -p "Enter app name (e.g., nova-social-network): " APP_NAME

echo ""
echo "2️⃣  Creating Heroku app: $APP_NAME"
heroku create $APP_NAME

echo ""
echo "3️⃣  Adding PostgreSQL database..."
heroku addons:create heroku-postgresql:standard-0 --app $APP_NAME

echo ""
echo "4️⃣  Adding Redis cache..."
heroku addons:create heroku-redis:premium-0 --app $APP_NAME

echo ""
echo "5️⃣  Waiting for add-ons to be ready..."
sleep 10

echo ""
echo "6️⃣  Setting environment variables..."
heroku config:set NODE_ENV=production --app $APP_NAME
heroku config:set JWT_SECRET=$(openssl rand -base64 32) --app $APP_NAME
heroku config:set BACKEND_PORT=5000 --app $APP_NAME

FRONTEND_URL="https://$APP_NAME.herokuapp.com"
heroku config:set FRONTEND_URL=$FRONTEND_URL --app $APP_NAME
heroku config:set CORS_ORIGIN=$FRONTEND_URL --app $APP_NAME

echo ""
echo "7️⃣  Adding Heroku git remote..."
git remote add heroku https://git.heroku.com/$APP_NAME.git

echo ""
echo "8️⃣  Deploying to Heroku..."
git push heroku main

echo ""
echo "9️⃣  Running database migrations..."
heroku run "cd packages/backend && npm run prisma:migrate" --app $APP_NAME

echo ""
echo "🔟 Seeding database..."
heroku run "cd packages/backend && npm run prisma:seed" --app $APP_NAME

echo ""
echo "✅ Deployment completed!"
echo ""
echo "App URL: $FRONTEND_URL"
echo "API URL: https://$APP_NAME.herokuapp.com/api"
echo ""
echo "View logs: heroku logs --tail --app $APP_NAME"
echo "Open app: heroku open --app $APP_NAME"
