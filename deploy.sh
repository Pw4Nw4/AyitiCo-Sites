#!/bin/bash

# AyitiCo Deployment Script for Linux
# This script automates the complete deployment process

set -e  # Exit on any error

echo "🚀 Starting AyitiCo Deployment..."
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root (use sudo)"
    exit 1
fi

# Get the actual user (not root)
ACTUAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo ~$ACTUAL_USER)

print_info "Deploying for user: $ACTUAL_USER"
print_info "Home directory: $USER_HOME"

# 1. Update system
print_info "Step 1/12: Updating system packages..."
apt update && apt upgrade -y
print_success "System updated"

# 2. Install Node.js 18
print_info "Step 2/12: Installing Node.js 18..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs
    print_success "Node.js installed"
else
    print_success "Node.js already installed ($(node --version))"
fi

# 3. Install PostgreSQL
print_info "Step 3/12: Installing PostgreSQL..."
if ! command -v psql &> /dev/null; then
    apt install -y postgresql postgresql-contrib
    systemctl start postgresql
    systemctl enable postgresql
    print_success "PostgreSQL installed"
else
    print_success "PostgreSQL already installed"
fi

# 4. Install PM2
print_info "Step 4/12: Installing PM2..."
npm install -g pm2
print_success "PM2 installed"

# 5. Install Nginx
print_info "Step 5/12: Installing Nginx..."
if ! command -v nginx &> /dev/null; then
    apt install -y nginx
    systemctl enable nginx
    print_success "Nginx installed"
else
    print_success "Nginx already installed"
fi

# 6. Set up PostgreSQL database
print_info "Step 6/12: Setting up PostgreSQL database..."
sudo -u postgres psql -c "SELECT 1 FROM pg_database WHERE datname = 'ayitico'" | grep -q 1 || \
sudo -u postgres psql <<EOF
CREATE DATABASE ayitico;
CREATE USER ayitico_user WITH PASSWORD 'ayitico_secure_password_2024';
GRANT ALL PRIVILEGES ON DATABASE ayitico TO ayitico_user;
ALTER DATABASE ayitico OWNER TO ayitico_user;
EOF
print_success "Database created"

# 7. Navigate to project directory
PROJECT_DIR="$USER_HOME/AyitiCo"
print_info "Step 7/12: Setting up project directory..."

if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory not found at $PROJECT_DIR"
    print_info "Please copy your project to $PROJECT_DIR first"
    exit 1
fi

cd "$PROJECT_DIR"
print_success "Project directory found"

# 8. Create .env file
print_info "Step 8/12: Creating environment configuration..."
NEXTAUTH_SECRET=$(openssl rand -base64 32)

cat > .env <<EOF
# Database
DATABASE_URL="postgresql://ayitico_user:ayitico_secure_password_2024@localhost:5432/ayitico"

# NextAuth
NEXTAUTH_SECRET="$NEXTAUTH_SECRET"
NEXTAUTH_URL="http://localhost:3000"

# App URL
NEXT_PUBLIC_APP_URL="http://localhost:3000"

# Stripe (Replace with your keys from stripe.com)
STRIPE_SECRET_KEY="sk_test_your_key_here"
STRIPE_PUBLISHABLE_KEY="pk_test_your_key_here"
STRIPE_WEBHOOK_SECRET="whsec_your_webhook_secret_here"
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="pk_test_your_key_here"

# Email (Optional - from resend.com)
RESEND_API_KEY="re_your_api_key_here"

# Node Environment
NODE_ENV="production"
EOF

chown $ACTUAL_USER:$ACTUAL_USER .env
print_success "Environment file created"

# 9. Install dependencies
print_info "Step 9/12: Installing Node.js dependencies..."
sudo -u $ACTUAL_USER npm install
print_success "Dependencies installed"

# 10. Set up database
print_info "Step 10/12: Setting up database schema..."
sudo -u $ACTUAL_USER npm run db:generate
sudo -u $ACTUAL_USER npm run db:push
print_success "Database schema created"

# 11. Build application
print_info "Step 11/12: Building application..."
sudo -u $ACTUAL_USER npm run build
print_success "Application built"

# 12. Set up PM2
print_info "Step 12/12: Setting up PM2 process manager..."
sudo -u $ACTUAL_USER pm2 delete ayitico 2>/dev/null || true
sudo -u $ACTUAL_USER pm2 start npm --name "ayitico" -- start
sudo -u $ACTUAL_USER pm2 save
sudo -u $ACTUAL_USER pm2 startup systemd -u $ACTUAL_USER --hp $USER_HOME | tail -n 1 | bash
print_success "PM2 configured"

# Configure Nginx
print_info "Configuring Nginx reverse proxy..."
cat > /etc/nginx/sites-available/ayitico <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/ayitico /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx
print_success "Nginx configured"

# Configure firewall
print_info "Configuring firewall..."
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
print_success "Firewall configured"

# Print summary
echo ""
echo "=================================="
echo -e "${GREEN}🎉 Deployment Complete!${NC}"
echo "=================================="
echo ""
echo "📋 Summary:"
echo "  • Application: Running on PM2"
echo "  • Database: PostgreSQL (ayitico)"
echo "  • Web Server: Nginx"
echo "  • Port: 80 (HTTP)"
echo ""
echo "🌐 Access your application:"
echo "  • Local: http://localhost"
echo "  • Network: http://$(hostname -I | awk '{print $1}')"
echo ""
echo "🔧 Useful Commands:"
echo "  • View logs: pm2 logs ayitico"
echo "  • Restart app: pm2 restart ayitico"
echo "  • Stop app: pm2 stop ayitico"
echo "  • App status: pm2 status"
echo "  • Database: npm run db:studio"
echo ""
echo "⚠️  Important Next Steps:"
echo "  1. Update Stripe keys in .env file"
echo "  2. Update NEXTAUTH_URL and NEXT_PUBLIC_APP_URL with your domain"
echo "  3. Create admin user (see documentation)"
echo "  4. Set up SSL certificate with: sudo certbot --nginx"
echo ""
echo "📝 Environment file location: $PROJECT_DIR/.env"
echo ""
print_success "Deployment script completed successfully!"
