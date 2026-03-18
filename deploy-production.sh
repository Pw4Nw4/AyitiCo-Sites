#!/bin/bash
set -e

echo "🚀 Production Deployment Checklist"
echo "===================================="

# Check environment variables
echo "📋 Checking environment variables..."
required_vars=("DATABASE_URL" "NEXTAUTH_SECRET" "NEXTAUTH_URL" "STRIPE_SECRET_KEY" "STRIPE_WEBHOOK_SECRET")
missing_vars=()

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    missing_vars+=("$var")
  fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
  echo "❌ Missing required environment variables:"
  printf '   - %s\n' "${missing_vars[@]}"
  exit 1
fi
echo "✓ All required environment variables set"

# Install dependencies
echo "📦 Installing dependencies..."
npm ci --production=false
echo "✓ Dependencies installed"

# Generate Prisma client
echo "🔧 Generating Prisma client..."
npx prisma generate
echo "✓ Prisma client generated"

# Run database migrations
echo "🗄️  Running database migrations..."
npx prisma migrate deploy
echo "✓ Database migrations completed"

# Build application
echo "🏗️  Building application..."
npm run build
echo "✓ Application built"

echo ""
echo "✅ Deployment preparation complete!"
echo ""
echo "Next steps:"
echo "1. Start application: npm start"
echo "2. Run seed (first time): npx tsx prisma/seed.ts"
echo "3. Configure Stripe webhook: https://yourdomain.com/api/stripe/webhook"
