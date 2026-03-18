# Production Deployment Checklist

## Pre-Deployment

### 1. Environment Configuration
- [ ] Generate secure `NEXTAUTH_SECRET` (32+ chars)
- [ ] Set production `DATABASE_URL` with strong password
- [ ] Configure production `NEXTAUTH_URL` (your domain)
- [ ] Set `NEXT_PUBLIC_APP_URL` (your domain)
- [ ] Add Stripe live keys (not test keys)
- [ ] Configure Resend API key for emails
- [ ] Set `NODE_ENV=production`

### 2. Database Setup
- [ ] Create production PostgreSQL database
- [ ] Run migrations: `npx prisma migrate deploy`
- [ ] Seed database: `npx tsx prisma/seed.ts`
- [ ] Change default admin password
- [ ] Set up automated backups

### 3. Stripe Configuration
- [ ] Switch to live Stripe keys
- [ ] Configure webhook endpoint: `https://yourdomain.com/api/stripe/webhook`
- [ ] Add webhook events: checkout.session.completed, payment_intent.succeeded, payment_intent.payment_failed
- [ ] Update `STRIPE_WEBHOOK_SECRET` with production secret
- [ ] Test payment flow with real card

### 4. Security
- [ ] Enable HTTPS/SSL certificate
- [ ] Verify security headers are active
- [ ] Test rate limiting on API endpoints
- [ ] Review CORS configuration
- [ ] Scan for exposed secrets in code
- [ ] Enable firewall rules (ports 80, 443 only)

### 5. Application
- [ ] Build application: `npm run build`
- [ ] Test build locally: `npm start`
- [ ] Verify all pages load correctly
- [ ] Test authentication flow
- [ ] Test checkout process
- [ ] Test admin dashboard
- [ ] Verify email sending works

## Deployment

### 6. Server Setup
- [ ] Install Node.js 18+
- [ ] Install PostgreSQL 14+
- [ ] Install PM2 or process manager
- [ ] Configure Nginx/reverse proxy
- [ ] Set up SSL certificate (Let's Encrypt)
- [ ] Configure domain DNS

### 7. Deploy Application
- [ ] Upload code to server
- [ ] Install dependencies: `npm ci --production`
- [ ] Run deployment script: `./deploy-production.sh`
- [ ] Start application with PM2
- [ ] Configure PM2 to start on boot
- [ ] Set up Nginx reverse proxy

### 8. Monitoring
- [ ] Test health endpoint: `/api/health`
- [ ] Set up uptime monitoring
- [ ] Configure error logging
- [ ] Set up database monitoring
- [ ] Configure backup automation
- [ ] Test backup restoration

## Post-Deployment

### 9. Testing
- [ ] Test homepage loads
- [ ] Register new user account
- [ ] Verify email verification works
- [ ] Login with new account
- [ ] Browse products
- [ ] Add items to cart
- [ ] Complete checkout with test card
- [ ] Verify order appears in admin
- [ ] Test on mobile devices
- [ ] Test on different browsers

### 10. Content
- [ ] Add real product images
- [ ] Upload product catalog
- [ ] Update legal pages (Privacy, Terms, Cookies)
- [ ] Add company information
- [ ] Configure contact information
- [ ] Set up customer support email

### 11. Performance
- [ ] Enable CDN for static assets
- [ ] Configure image optimization
- [ ] Enable caching headers
- [ ] Test page load speeds
- [ ] Optimize database queries
- [ ] Set up Redis for sessions (optional)

### 12. Final Checks
- [ ] Remove test data
- [ ] Verify all environment variables
- [ ] Check error logs
- [ ] Test all critical user flows
- [ ] Verify Stripe webhooks working
- [ ] Test email notifications
- [ ] Review security scan results
- [ ] Document deployment process

## Emergency Contacts

- Database Admin: _______________
- Hosting Provider: _______________
- Domain Registrar: _______________
- Stripe Support: https://support.stripe.com
- SSL Certificate: _______________

## Rollback Plan

If deployment fails:
1. Stop application: `pm2 stop ayitico`
2. Restore database backup: `psql < backup.sql`
3. Revert code to previous version
4. Restart application: `pm2 start ayitico`
5. Verify health endpoint

## Maintenance

### Daily
- [ ] Check error logs
- [ ] Monitor uptime
- [ ] Review failed payments

### Weekly
- [ ] Database backup verification
- [ ] Security updates check
- [ ] Performance monitoring

### Monthly
- [ ] Update dependencies
- [ ] Security audit
- [ ] Backup restoration test
- [ ] SSL certificate renewal check
