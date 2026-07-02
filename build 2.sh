#!/bin/bash
set -e

echo "Installing dependencies..."
npm install --prefix packages/backend
npm install --prefix packages/frontend

echo "Building backend..."
npm run build --prefix packages/backend

echo "Building frontend..."
npm run build --prefix packages/frontend

echo "Running migrations..."
cd packages/backend && npx prisma migrate deploy

echo "Seeding database..."
node --loader tsx prisma/seed.ts || true

echo "Build completed successfully!"
