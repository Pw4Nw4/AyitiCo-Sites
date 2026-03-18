#!/bin/bash

echo "🔒 Running Security Audit"
echo "========================="

# Check for exposed secrets
echo "1. Checking for exposed secrets..."
if grep -r "sk_live_\|pk_live_\|whsec_" --exclude-dir={node_modules,.next,.git} . 2>/dev/null; then
  echo "❌ WARNING: Live API keys found in code!"
else
  echo "✓ No exposed live API keys"
fi

# Check .env is in .gitignore
echo "2. Checking .gitignore..."
if grep -q "^\.env$" .gitignore; then
  echo "✓ .env is in .gitignore"
else
  echo "❌ WARNING: .env not in .gitignore"
fi

# Check for weak passwords
echo "3. Checking for weak passwords..."
if grep -r "password.*=.*123\|password.*=.*admin" --exclude-dir={node_modules,.next,.git} . 2>/dev/null; then
  echo "❌ WARNING: Weak passwords found"
else
  echo "✓ No obvious weak passwords"
fi

# Check Node.js version
echo "4. Checking Node.js version..."
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -ge 18 ]; then
  echo "✓ Node.js version is up to date ($NODE_VERSION)"
else
  echo "⚠️  Node.js version is outdated. Upgrade to 18+"
fi

# Check for npm audit issues
echo "5. Running npm audit..."
npm audit --production 2>/dev/null | grep -E "vulnerabilities|found" || echo "✓ No vulnerabilities found"

# Check SSL/HTTPS
echo "6. Checking HTTPS enforcement..."
if grep -q "x-forwarded-proto" middleware.ts; then
  echo "✓ HTTPS enforcement configured"
else
  echo "⚠️  HTTPS enforcement not found in middleware"
fi

# Check rate limiting
echo "7. Checking rate limiting..."
if [ -f "lib/rate-limit.ts" ]; then
  echo "✓ Rate limiting implemented"
else
  echo "⚠️  Rate limiting not found"
fi

echo ""
echo "✅ Security audit complete"
