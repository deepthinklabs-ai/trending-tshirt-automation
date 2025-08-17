#!/bin/bash

# Setup Environment Script for Trending T-Shirt Automation
# This script helps set up the development environment

set -e  # Exit on any error

echo "🚀 Setting up Trending T-Shirt Automation Environment"
echo "===================================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check Node.js
    if command_exists node; then
        NODE_VERSION=$(node --version)
        print_success "Node.js found: $NODE_VERSION"
    else
        print_error "Node.js not found. Please install Node.js 16+ from https://nodejs.org"
        exit 1
    fi
    
    # Check npm
    if command_exists npm; then
        NPM_VERSION=$(npm --version)
        print_success "npm found: $NPM_VERSION"
    else
        print_error "npm not found. Please install npm"
        exit 1
    fi
    
    # Check Docker (optional)
    if command_exists docker; then
        DOCKER_VERSION=$(docker --version)
        print_success "Docker found: $DOCKER_VERSION"
        DOCKER_AVAILABLE=true
    else
        print_warning "Docker not found. Docker setup will be skipped."
        DOCKER_AVAILABLE=false
    fi
    
    # Check curl
    if command_exists curl; then
        print_success "curl found"
    else
        print_error "curl not found. Please install curl"
        exit 1
    fi
    
    echo
}

# Create project structure
setup_project_structure() {
    print_step "Setting up project structure..."
    
    # Create directories if they don't exist
    directories=(
        "logs"
        "backups"
        "temp"
        "output"
        "config"
    )
    
    for dir in "${directories[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_success "Created directory: $dir"
        else
            print_success "Directory exists: $dir"
        fi
    done
    
    echo
}

# Install Node.js dependencies
install_dependencies() {
    print_step "Installing Node.js dependencies..."
    
    if [ -f "package.json" ]; then
        npm install
        print_success "Dependencies installed"
    else
        print_warning "No package.json found, skipping npm install"
    fi
    
    echo
}

# Setup configuration files
setup_configuration() {
    print_step "Setting up configuration files..."
    
    # Create environment template if it doesn't exist
    if [ ! -f ".env" ]; then
        cat > .env << 'EOF'
# Trending T-Shirt Automation Configuration
# Copy this file and fill in your actual values
# DO NOT commit this file to version control!

# Reddit API Configuration
REDDIT_CLIENT_ID=your_reddit_client_id_here
REDDIT_CLIENT_SECRET=your_reddit_client_secret_here
REDDIT_USERNAME=your_reddit_username

# OpenAI API Configuration
OPENAI_API_KEY=your_openai_api_key_here

# n8n Configuration (if using Docker)
N8N_USER=admin
N8N_PASSWORD=change_this_password

# Database Configuration (if using Docker)
POSTGRES_PASSWORD=your_postgres_password

# Optional: Webhook Domain
WEBHOOK_DOMAIN=your-domain.com
EOF
        print_success "Created .env template"
        print_warning "Please edit .env file with your actual API credentials"
    else
        print_success ".env file already exists"
    fi
    
    # Create local config file
    if [ ! -f "config/local.json" ]; then
        mkdir -p config
        cat > config/local.json << 'EOF'
{
  "workflow": {
    "postsPerRun": 10,
    "runsPerDay": 1,
    "approvalRate": 0.4
  },
  "models": {
    "compliance": "gpt-4o",
    "design": "gpt-4o-mini"
  },
  "logging": {
    "level": "info",
    "file": "logs/automation.log"
  }
}
EOF
        print_success "Created local configuration file"
    else
        print_success "Local configuration file already exists"
    fi
    
    echo
}

# Validate workflow
validate_workflow() {
    print_step "Validating workflow..."
    
    if [ -f "scripts/validate-workflow.js" ]; then
        if node scripts/validate-workflow.js; then
            print_success "Workflow validation passed"
        else
            print_error "Workflow validation failed"
            exit 1
        fi
    else
        print_warning "Validation script not found, skipping validation"
    fi
    
    echo
}

# Setup Docker environment
setup_docker() {
    if [ "$DOCKER_AVAILABLE" = true ]; then
        print_step "Setting up Docker environment..."
        
        # Copy Docker environment template
        if [ ! -f "docker/.env" ]; then
            if [ -f "docker/.env.example" ]; then
                cp docker/.env.example docker/.env
                print_success "Created Docker .env file from template"
                print_warning "Please edit docker/.env with your credentials"
            else
                print_warning "Docker .env.example not found"
            fi
        else
            print_success "Docker .env file already exists"
        fi
        
        # Check Docker Compose
        if command_exists docker-compose; then
            print_success "Docker Compose found"
        elif docker compose version >/dev/null 2>&1; then
            print_success "Docker Compose (v2) found"
        else
            print_warning "Docker Compose not found. Please install Docker Compose"
        fi
    else
        print_warning "Docker not available, skipping Docker setup"
    fi
    
    echo
}

# Create useful scripts
setup_scripts() {
    print_step "Creating utility scripts..."
    
    # Create start script
    cat > start.sh << 'EOF'
#!/bin/bash
# Quick start script for the automation

echo "🚀 Starting Trending T-Shirt Automation"

# Check if using Docker
if [ -f "docker/.env" ] && command -v docker-compose >/dev/null 2>&1; then
    echo "Starting with Docker..."
    cd docker && docker-compose up -d
    echo "✅ Started! Access n8n at http://localhost:5678"
else
    echo "Docker not available. Please start n8n manually and import the workflow."
    echo "Workflow file: n8n-workflows/trending-tshirt-automation.json"
fi
EOF
    chmod +x start.sh
    print_success "Created start.sh script"
    
    # Create backup script
    cat > backup.sh << 'EOF'
#!/bin/bash
# Backup script for automation data

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups"

mkdir -p $BACKUP_DIR

echo "📦 Creating backup..."

# Backup configuration
tar -czf "$BACKUP_DIR/config-$DATE.tar.gz" config/ .env 2>/dev/null || true

# Backup logs
if [ -d "logs" ]; then
    tar -czf "$BACKUP_DIR/logs-$DATE.tar.gz" logs/
fi

# Backup Docker data if available
if command -v docker >/dev/null 2>&1; then
    docker run --rm -v trending-tshirt-automation_n8n_data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar czf /backup/n8n-data-$DATE.tar.gz -C /data . 2>/dev/null || true
fi

echo "✅ Backup completed: $BACKUP_DIR/"
ls -la $BACKUP_DIR/*$DATE*
EOF
    chmod +x backup.sh
    print_success "Created backup.sh script"
    
    # Create cost calculation script
    cat > calculate-costs.sh << 'EOF'
#!/bin/bash
# Cost calculation script

if [ -f "tools/cost-calculator.js" ]; then
    echo "💰 Calculating costs..."
    node tools/cost-calculator.js calculate
else
    echo "❌ Cost calculator not found"
fi
EOF
    chmod +x calculate-costs.sh
    print_success "Created calculate-costs.sh script"
    
    echo
}

# Generate API setup instructions
generate_api_instructions() {
    print_step "Generating API setup instructions..."
    
    cat > API_SETUP_INSTRUCTIONS.md << 'EOF'
# API Setup Instructions

## Reddit API Setup

1. **Create Reddit Account**
   - Go to https://www.reddit.com
   - Create account or log in

2. **Create Reddit App**
   - Visit https://www.reddit.com/prefs/apps
   - Click "Create App" or "Create Another App"
   - Fill out form:
     - Name: "Trending T-Shirt Automation"
     - App type: "web app"
     - Description: "Automation for trending content analysis"
     - About URL: (leave blank)
     - Redirect URI: `http://localhost:5678/rest/oauth2-credential/callback`
   - Click "Create app"

3. **Get Credentials**
   - Client ID: Found under app name (random string)
   - Client Secret: "secret" field
   - Save these in your .env file

## OpenAI API Setup

1. **Create OpenAI Account**
   - Go to https://platform.openai.com
   - Sign up or log in

2. **Get API Key**
   - Visit https://platform.openai.com/api-keys
   - Click "Create new secret key"
   - Name it "Trending T-Shirt Automation"
   - Copy the key (starts with sk-)
   - Save in your .env file

3. **Add Billing Information**
   - Go to https://platform.openai.com/account/billing
   - Add payment method
   - Set usage limits if desired

## n8n Setup

1. **Import Workflow**
   - Open n8n interface
   - Go to Workflows → Import from JSON
   - Copy content from `n8n-workflows/trending-tshirt-automation.json`
   - Paste and save

2. **Configure Credentials**
   - Reddit: Add OAuth2 credentials with your Reddit app details
   - OpenAI: Add API key credentials
   - Update User-Agent in HTTP Request node

3. **Test Workflow**
   - Click "Execute workflow"
   - Check execution logs
   - Verify output format

For detailed setup instructions, see docs/SETUP.md
EOF
    
    print_success "Created API_SETUP_INSTRUCTIONS.md"
    echo
}

# Main setup function
main() {
    check_prerequisites
    setup_project_structure
    install_dependencies
    setup_configuration
    validate_workflow
    setup_docker
    setup_scripts
    generate_api_instructions
    
    echo "🎉 Setup Complete!"
    echo "==============="
    echo
    echo "Next steps:"
    echo "1. Edit .env file with your API credentials"
    echo "2. Follow API_SETUP_INSTRUCTIONS.md for API setup"
    echo "3. Run ./start.sh to start the automation"
    echo "4. Import workflow into n8n and configure credentials"
    echo
    echo "Useful commands:"
    echo "  ./start.sh              - Start the automation"
    echo "  ./backup.sh             - Create backup"
    echo "  ./calculate-costs.sh    - Calculate API costs"
    echo "  npm run validate        - Validate workflow"
    echo
    echo "Documentation:"
    echo "  README.md               - Project overview"
    echo "  docs/SETUP.md           - Detailed setup guide"
    echo "  docs/TROUBLESHOOTING.md - Common issues and solutions"
    echo
}

# Run setup
main "$@"