# AyitiCo Marketplace

Haitian e-commerce platform built with Next.js 14, PostgreSQL, and Stripe.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL 14+
- Stripe account
- Resend account (optional, for emails)

### Installation

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your credentials

# Generate Prisma client
npm run db:generate

# Push database schema
npm run db:push

# Seed database (creates admin user and sample data)
npx tsx prisma/seed.ts

# Run development server
npm run dev
```

Visit http://localhost:3000

### Default Admin Credentials
- Email: admin@ayitico.com
- Password: Admin@123

**⚠️ Change these immediately in production!**

## 🐳 Docker Deployment

```bash
# Build and start services
docker-compose up -d

# Run migrations
docker-compose exec app npx prisma migrate deploy

# Seed database
docker-compose exec app npx tsx prisma/seed.ts
```

## 📦 Production Deployment

### Environment Variables

Generate secure secrets:
```bash
# NEXTAUTH_SECRET
openssl rand -base64 32

# Strong database password
openssl rand -base64 24
```

Required variables:
- `DATABASE_URL` - PostgreSQL connection string
- `NEXTAUTH_SECRET` - 32+ character secret
- `NEXTAUTH_URL` - Your domain URL
- `STRIPE_SECRET_KEY` - From Stripe dashboard
- `STRIPE_WEBHOOK_SECRET` - From Stripe webhook setup
- `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` - Stripe public key

### Deploy Script

```bash
chmod +x deploy-production.sh
./deploy-production.sh
```

### Stripe Webhook Setup

1. Go to Stripe Dashboard → Webhooks
2. Add endpoint: `https://yourdomain.com/api/stripe/webhook`
3. Select events:
   - `checkout.session.completed`
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
4. Copy webhook secret to `STRIPE_WEBHOOK_SECRET`

## 🔒 Security Features

- ✅ HTTPS enforcement in production
- ✅ Security headers (CSP, HSTS, X-Frame-Options)
- ✅ Rate limiting on API endpoints
- ✅ Input sanitization
- ✅ SQL injection protection (Prisma)
- ✅ Password hashing (bcrypt)
- ✅ JWT session tokens
- ✅ CORS configuration

## 📊 Monitoring

Health check endpoint: `/api/health`

Returns:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "database": "connected",
  "version": "1.0.0"
}
```

## 🛠️ Scripts

- `npm run dev` - Development server
- `npm run build` - Production build
- `npm start` - Start production server
- `npm run db:generate` - Generate Prisma client
- `npm run db:push` - Push schema to database
- `npm run db:studio` - Open Prisma Studio
- `npm run db:migrate` - Run migrations

## 📁 Project Structure

```
├── app/                  # Next.js app directory
│   ├── api/             # API routes
│   ├── admin/           # Admin dashboard
│   ├── shop/            # Shop pages
│   └── ...
├── components/          # React components
├── lib/                 # Utilities
│   ├── prisma.ts       # Database client
│   ├── auth-options.ts # NextAuth config
│   ├── rate-limit.ts   # Rate limiting
│   └── ...
├── prisma/             # Database schema
│   ├── schema.prisma   # Prisma schema
│   └── seed.ts         # Database seeding
└── public/             # Static assets
```

## 🔧 Configuration Files

- `next.config.js` - Next.js configuration
- `tsconfig.json` - TypeScript configuration
- `tailwind.config.js` - Tailwind CSS configuration
- `docker-compose.yml` - Docker orchestration
- `Dockerfile` - Container image definition

## 📝 License

Private - All rights reserved
