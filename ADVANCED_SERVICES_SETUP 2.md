# Advanced Services Setup Guide

## 🎯 Services à Ajouter

Ce guide vous montre comment ajouter les 4 services avancés manquants.

---

## 📊 1. Sentry - Error Tracking & Monitoring

### Installation Backend

```bash
cd packages/backend
npm install @sentry/node @sentry/tracing
```

### Installation Frontend

```bash
cd packages/frontend
npm install @sentry/react @sentry/tracing
```

### Fichier: packages/backend/src/lib/sentry.ts

```typescript
import * as Sentry from '@sentry/node'
import * as Tracing from '@sentry/tracing'
import express, { Express } from 'express'

export function initSentry(app: Express): void {
  if (!process.env.SENTRY_DSN) return
  
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.NODE_ENV,
    integrations: [
      new Sentry.Integrations.Http({ tracing: true }),
      new Tracing.Integrations.Express({
        app: true,
        request: true,
        transaction: true,
      }),
    ],
    tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
    attachStacktrace: true,
  })

  app.use(Sentry.Handlers.requestHandler())
  app.use(Sentry.Handlers.tracingHandler())
}

export function attachSentryErrorHandler(app: Express): void {
  app.use(Sentry.Handlers.errorHandler())
}

export function captureException(error: Error, context?: Record<string, any>): void {
  if (context) {
    Sentry.captureException(error, { contexts: { error: context } })
  } else {
    Sentry.captureException(error)
  }
}
```

### Fichier: packages/frontend/src/lib/sentry.ts

```typescript
import * as Sentry from '@sentry/react'
import { BrowserTracing } from '@sentry/tracing'

if (import.meta.env.VITE_SENTRY_DSN) {
  Sentry.init({
    dsn: import.meta.env.VITE_SENTRY_DSN,
    environment: import.meta.env.MODE,
    integrations: [
      new BrowserTracing(),
      new Sentry.Replay({
        maskAllText: true,
        blockAllMedia: true,
      }),
    ],
    tracesSampleRate: import.meta.env.MODE === 'production' ? 0.1 : 1.0,
    replaysSessionSampleRate: 0.1,
    replaysOnErrorSampleRate: 1.0,
  })
}
```

### Environment Variables

```env
SENTRY_DSN=https://your-key@sentry.io/your-project-id
VITE_SENTRY_DSN=https://your-key@sentry.io/your-project-id
```

---

## 📧 2. SendGrid - Email Service

### Installation

```bash
cd packages/backend
npm install nodemailer
```

### Fichier: packages/backend/src/lib/email.ts

```typescript
import nodemailer from 'nodemailer'

export interface EmailOptions {
  to: string | string[]
  subject: string
  html: string
  text?: string
}

class EmailService {
  private transporter: nodemailer.Transporter

  constructor() {
    if (process.env.SENDGRID_API_KEY) {
      this.transporter = nodemailer.createTransport({
        host: 'smtp.sendgrid.net',
        port: 587,
        auth: {
          user: 'apikey',
          pass: process.env.SENDGRID_API_KEY,
        },
      })
    }
  }

  async sendEmail(options: EmailOptions): Promise<void> {
    try {
      await this.transporter.sendMail({
        from: process.env.EMAIL_FROM || 'noreply@novasocial.com',
        to: Array.isArray(options.to) ? options.to.join(', ') : options.to,
        subject: options.subject,
        html: options.html,
      })
    } catch (error) {
      console.error('Failed to send email:', error)
      throw error
    }
  }

  async sendWelcomeEmail(email: string, displayName: string): Promise<void> {
    await this.sendEmail({
      to: email,
      subject: 'Welcome to Nova Social Network',
      html: `<h1>Welcome ${displayName}!</h1><p>Start connecting with friends.</p>`,
    })
  }
}

export default new EmailService()
```

### Environment Variables

```env
SENDGRID_API_KEY=your_sendgrid_api_key
EMAIL_FROM=noreply@novasocial.com
```

---

## 🔐 3. Swagger/OpenAPI Documentation

### Installation

```bash
cd packages/backend
npm install swagger-jsdoc swagger-ui-express
```

### Fichier: packages/backend/src/lib/swagger.ts

```typescript
import swaggerJsdoc from 'swagger-jsdoc'
import swaggerUi from 'swagger-ui-express'
import { Express } from 'express'

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Nova Social Network API',
      version: '1.0.0',
      description: 'Complete REST API for Nova Social Network',
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: 'Development',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
  },
  apis: ['./src/routes/*.ts'],
}

const specs = swaggerJsdoc(options)

export function setupSwagger(app: Express): void {
  app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(specs))
  app.get('/api/swagger.json', (req, res) => {
    res.setHeader('Content-Type', 'application/json')
    res.send(specs)
  })
}
```

### Utilisation dans index.ts

```typescript
import { setupSwagger } from './lib/swagger'

const app = express()

// ... middleware ...

setupSwagger(app)

// ... routes ...
```

### Accès

- Development: http://localhost:3000/api/docs
- Production: https://your-app.herokuapp.com/api/docs

---

## ⚙️ 4. GitHub Actions CI/CD

### Créer: .github/workflows/ci-cd.yml

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install Backend
        run: npm install --prefix packages/backend
      
      - name: Install Frontend
        run: npm install --prefix packages/frontend
      
      - name: Build Backend
        run: npm run build --prefix packages/backend
        env:
          DATABASE_URL: test
          REDIS_URL: test
          JWT_SECRET: test
      
      - name: Build Frontend
        run: npm run build --prefix packages/frontend

  deploy-to-heroku:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - name: Deploy to Heroku
        uses: akhileshns/heroku-deploy@v3.12.12
        with:
          heroku_api_key: ${{ secrets.HEROKU_API_KEY }}
          heroku_app_name: ${{ secrets.HEROKU_APP_NAME }}
          heroku_email: ${{ secrets.HEROKU_EMAIL }}
```

### Configuration des Secrets GitHub

1. Allez à: Repository → Settings → Secrets and variables → Actions
2. Créez les secrets:
   - `HEROKU_API_KEY`
   - `HEROKU_EMAIL`
   - `HEROKU_APP_NAME`

---

## 📋 Checklist d'Intégration

### Backend
- [ ] `npm install @sentry/node @sentry/tracing`
- [ ] `npm install nodemailer`
- [ ] `npm install swagger-jsdoc swagger-ui-express`
- [ ] Créer `src/lib/sentry.ts`
- [ ] Créer `src/lib/email.ts`
- [ ] Créer `src/lib/swagger.ts`
- [ ] Mettre à jour `src/index.ts` pour initialiser ces services

### Frontend
- [ ] `npm install @sentry/react @sentry/tracing`
- [ ] Créer `src/lib/sentry.ts`
- [ ] Importer dans `src/main.tsx` avant l'app

### GitHub
- [ ] Créer `.github/workflows/ci-cd.yml`
- [ ] Ajouter les secrets
- [ ] Pousser vers main pour tester

### Heroku
- [ ] `heroku config:set SENTRY_DSN=...`
- [ ] `heroku config:set SENDGRID_API_KEY=...`
- [ ] `heroku config:set EMAIL_FROM=...`

---

## 🚀 Étapes Suivantes

1. **Créez les fichiers** listés ci-dessus
2. **Testez localement** avec `npm run dev`
3. **Accédez à Swagger** à http://localhost:3000/api/docs
4. **Poussez vers GitHub** pour déclencher les workflows
5. **Vérifiez les déploiements** dans l'onglet Actions

---

## 📚 Liens Utiles

- [Sentry Documentation](https://docs.sentry.io/)
- [SendGrid Documentation](https://docs.sendgrid.com/)
- [Swagger/OpenAPI](https://swagger.io/)
- [GitHub Actions](https://docs.github.com/en/actions)
