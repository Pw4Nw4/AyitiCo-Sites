# 🚀 Deploying AyitiCo on Coolify

## Quick Start Guide

### Step 1: Push Code to GitHub

```bash
cd /Users/rock/Desktop/AyitiCo

# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - AyitiCo marketplace"

# Add your GitHub repository
git remote add origin https://github.com/YOUR_USERNAME/AyitiCo.git

# Push to GitHub
git push -u origin main
```

---

### Step 2: Create PostgreSQL Database in Coolify

1. **Go to Coolify Dashboard**
2. Click **"+ New"** → **"Database"**
3. Select **"PostgreSQL"**
4. Configure:
   - **Name:** `ayitico-db`
   - **Database Name:** `ayitico`
   - **Username:** `ayitico_user`
   - **Password:** (auto-generated or set your own)
5. Click **"Create"**
6. **Copy the connection string** - you'll need it for environment variables

---

### Step 3: Create Application in Coolify

1. Click **"+ New"** → **"Application"**
2. **Repository Configuration:**
   - **Repository URL:** `https://github.com/YOUR_USERNAME/AyitiCo`
   - **Branch:** `main`
   - Click **"Check Repository"**

3. **Build Configuration:**
   - **Build Pack:** `nixpacks` (auto-selected)
   - **Base Directory:** (leave empty)
   - **Port:** `3000`
   - **Is it a static site?** `No` ❌

4. Click **"Continue"**

---

### Step 4: Configure Application Settings

#### **General Tab:**
- **Name:** `ayitico-marketplace`
- **Description:** `Haitian e-commerce marketplace`

#### **Domains Tab:**
- Click **"Generate Domain"** or add custom domain
- **Direction:** `Both` (HTTP + HTTPS)

#### **Build Tab:**
- Leave all fields empty (Nixpacks auto-detects)
- **Post-deployment Command:**
  ```bash
  npx prisma generate && npx prisma db push
  ```

#### **Network Tab:**
- **Ports Exposes:** `3000`

---

### Step 5: Add Environment Variables

Click **"Environment Variables"** tab and add these:

```env
# Database (Use connection string from Step 2)
DATABASE_URL=postgresql://ayitico_user:password@postgres-service:5432/ayitico

# NextAuth (Generate with: openssl rand -base64 32)
NEXTAUTH_SECRET=your-generated-32-char-secret
NEXTAUTH_URL=https://your-coolify-domain.com

# App URL
NEXT_PUBLIC_APP_URL=https://your-coolify-domain.com

# Stripe Keys (from stripe.com dashboard)
STRIPE_SECRET_KEY=sk_test_your_stripe_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_key

# Email Service (optional - from resend.com)
RESEND_API_KEY=re_your_resend_key

# Node Environment
NODE_ENV=production
```

**To generate NEXTAUTH_SECRET:**
```bash
openssl rand -base64 32
```

---

### Step 6: Deploy

1. Click **"Save"**
2. Click **"Deploy"**
3. Watch the build logs
4. Wait for deployment to complete (3-5 minutes)

---

## 📋 Post-Deployment Setup

### 1. Create Admin User

**Option A: Via Coolify Terminal**
```bash
# Click "Terminal" in Coolify
npx prisma studio
# Opens Prisma Studio - create user there
```

**Option B: Via Database**
```bash
# In Coolify, go to your PostgreSQL database
# Click "Execute SQL"
# First register a user normally at /register, then run:
UPDATE "User" SET "isAdmin" = true WHERE email = 'admin@ayitico.com';
```

### 2. Configure Stripe Webhook

1. Go to **Stripe Dashboard** → **Developers** → **Webhooks**
2. Click **"Add endpoint"**
3. **Endpoint URL:** `https://your-domain.com/api/stripe/webhook`
4. **Events to listen:**
   - `checkout.session.completed`
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
5. Copy **Webhook Secret**
6. Update `STRIPE_WEBHOOK_SECRET` in Coolify environment variables
7. Click **"Redeploy"** in Coolify

### 3. Test Your Application

Visit your domain and test:
- ✅ Homepage loads
- ✅ Register new user
- ✅ Login
- ✅ Browse products
- ✅ Add to cart
- ✅ Checkout (use test card: 4242 4242 4242 4242)
- ✅ Admin dashboard (after creating admin user)

---

## 🔧 Coolify Configuration Files

### Required Files (Already Created):

✅ **Dockerfile** - For containerized deployment
✅ **.dockerignore** - Excludes unnecessary files
✅ **next.config.js** - Configured with `output: 'standalone'`
✅ **package.json** - All dependencies listed

---

## 🐛 Troubleshooting

### Build Fails

**Check build logs in Coolify:**
1. Go to your application
2. Click "Deployments"
3. Click on failed deployment
4. Review logs

**Common issues:**
- Missing environment variables
- Database connection failed
- Node version mismatch

**Solution:**
```bash
# Verify all environment variables are set
# Check PostgreSQL database is running
# Ensure DATABASE_URL is correct
```

### Database Connection Error

```bash
# In Coolify PostgreSQL service, check:
# 1. Service is running (green status)
# 2. Connection string is correct
# 3. Network connectivity between services

# Test connection:
psql "postgresql://ayitico_user:password@postgres-service:5432/ayitico"
```

### Application Won't Start

```bash
# Check logs in Coolify
# Common issues:
# - Port 3000 already in use
# - Missing dependencies
# - Environment variables not loaded

# Solution: Redeploy with correct configuration
```

### Stripe Webhook Not Working

```bash
# Verify:
# 1. Webhook URL is correct (https://your-domain.com/api/stripe/webhook)
# 2. Webhook secret matches environment variable
# 3. Events are configured correctly

# Test webhook:
# Use Stripe CLI: stripe listen --forward-to https://your-domain.com/api/stripe/webhook
```

---

## 📊 Monitoring in Coolify

### View Logs
1. Go to your application in Coolify
2. Click **"Logs"**
3. View real-time application logs

### Check Metrics
1. Click **"Metrics"**
2. Monitor CPU, Memory, Network usage

### Restart Application
1. Click **"Restart"**
2. Application will restart without rebuilding

### Redeploy
1. Click **"Redeploy"**
2. Pulls latest code and rebuilds

---

## 🔄 Updating Your Application

### Push Updates to GitHub
```bash
cd /Users/rock/Desktop/AyitiCo

# Make your changes
git add .
git commit -m "Update: description of changes"
git push origin main
```

### Deploy in Coolify
1. Go to your application
2. Click **"Redeploy"**
3. Coolify will pull latest code and rebuild

---

## 🔒 Production Checklist

Before going live:

- [ ] Switch Stripe to live keys
- [ ] Configure custom domain with SSL
- [ ] Set up email service (Resend) with verified domain
- [ ] Create admin user
- [ ] Add initial products
- [ ] Test complete purchase flow
- [ ] Configure database backups in Coolify
- [ ] Set up monitoring/alerts
- [ ] Review security settings
- [ ] Test on mobile devices
- [ ] Update legal pages with real information

---

## 🎯 Quick Reference

### Coolify URLs
- **Dashboard:** Your Coolify instance URL
- **Application:** `https://your-generated-domain.coolify.io`
- **Database:** Internal service URL

### Important Commands (in Coolify Terminal)
```bash
# View application status
pm2 status

# View logs
pm2 logs

# Restart application
pm2 restart all

# Database management
npx prisma studio

# Run migrations
npx prisma db push
```

### Environment Variables to Update
1. `NEXTAUTH_URL` - Your actual domain
2. `NEXT_PUBLIC_APP_URL` - Your actual domain
3. `STRIPE_SECRET_KEY` - Live key for production
4. `STRIPE_WEBHOOK_SECRET` - From Stripe webhook setup

---

## 📞 Support

If you encounter issues:
1. Check Coolify logs
2. Review build logs
3. Verify environment variables
4. Check database connectivity
5. Test Stripe webhook

---

Your AyitiCo marketplace is ready to deploy on Coolify! 🚀
