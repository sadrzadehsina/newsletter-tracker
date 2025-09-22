#!/bin/bash

# Newsletter Tracker Global Installation Script
# This script installs the newsletter command globally on your Mac

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}📰 Newsletter Tracker Global Setup${NC}"
    echo -e "${BLUE}=================================${NC}"
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

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Detect the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

print_header
echo

print_info "Setting up global 'newsletter' command..."
echo

# Determine the best installation location
if [ -d "$HOME/.local/bin" ]; then
    BIN_DIR="$HOME/.local/bin"
elif [ -d "$HOME/bin" ]; then
    BIN_DIR="$HOME/bin"
else
    # Create ~/.local/bin if it doesn't exist
    BIN_DIR="$HOME/.local/bin"
    print_info "Creating $BIN_DIR directory..."
    mkdir -p "$BIN_DIR"
fi

print_info "Installing to $BIN_DIR (no sudo required)"

# Check if the bin directory is in PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    print_warning "$BIN_DIR is not in your PATH"
    echo "Adding to your shell configuration..."
    
    # Detect shell and add to appropriate config file
    SHELL_CONFIG=""
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
    fi
    
    if [ -n "$SHELL_CONFIG" ]; then
        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_CONFIG"
        print_success "Added $BIN_DIR to PATH in $SHELL_CONFIG"
        print_warning "Please restart your terminal or run: source $SHELL_CONFIG"
    fi
fi

# Create the global newsletter command
GLOBAL_SCRIPT="$BIN_DIR/newsletter"

print_info "Creating global script at $GLOBAL_SCRIPT"

# Create the global wrapper script
cat > /tmp/newsletter << 'EOF'
#!/bin/bash

# Global Newsletter Tracker Command
# This script provides access to newsletter tracker functionality from anywhere

# Try to find the newsletter tracker scripts
POSSIBLE_LOCATIONS=(
    "$HOME/.newsletter-tracker"
    "$HOME/Git/newsletter-tracker"
    "$HOME/Documents/newsletter-tracker"
    "$HOME/Downloads/newsletter-tracker"
)

NEWSLETTER_SCRIPT=""

# First, check if we're in a newsletter-tracker repository
if git rev-parse --is-inside-work-tree &>/dev/null; then
    REPO_ROOT=$(git rev-parse --show-toplevel)
    if [ -f "$REPO_ROOT/scripts/quick-actions.sh" ]; then
        NEWSLETTER_SCRIPT="$REPO_ROOT/scripts/quick-actions.sh"
    fi
fi

# If not found, check common locations
if [ -z "$NEWSLETTER_SCRIPT" ]; then
    for location in "${POSSIBLE_LOCATIONS[@]}"; do
        if [ -f "$location/scripts/quick-actions.sh" ]; then
            NEWSLETTER_SCRIPT="$location/scripts/quick-actions.sh"
            break
        fi
    done
fi

# If still not found, use the default installation location
if [ -z "$NEWSLETTER_SCRIPT" ]; then
    NEWSLETTER_SCRIPT="$HOME/.newsletter-tracker/scripts/quick-actions.sh"
fi

# Check if the script exists
if [ ! -f "$NEWSLETTER_SCRIPT" ]; then
    echo "❌ Newsletter tracker script not found!"
    echo "Expected location: $NEWSLETTER_SCRIPT"
    echo ""
    echo "📥 To install, run:"
    echo "  git clone https://github.com/sadrzadehsina/newsletter-tracker.git ~/.newsletter-tracker"
    echo "  ~/.newsletter-tracker/scripts/install-global.sh"
    exit 1
fi

# Execute the newsletter tracker script
exec "$NEWSLETTER_SCRIPT" "$@"
EOF

# Install the global script
if cp /tmp/newsletter "$GLOBAL_SCRIPT" && chmod +x "$GLOBAL_SCRIPT"; then
    print_success "Global 'newsletter' command installed successfully!"
else
    print_error "Failed to install global command."
    exit 1
fi

# Clean up temporary file
rm -f /tmp/newsletter

# Create a local copy in ~/.newsletter-tracker for global access
GLOBAL_DIR="$HOME/.newsletter-tracker"
if [ ! -d "$GLOBAL_DIR" ]; then
    print_info "Creating global newsletter tracker directory at $GLOBAL_DIR"
    mkdir -p "$GLOBAL_DIR"
fi

# Copy essential files to global directory
print_info "Copying newsletter tracker files to global directory..."
cp -r "$REPO_ROOT/scripts" "$GLOBAL_DIR/"
cp -r "$REPO_ROOT/templates" "$GLOBAL_DIR/"

# Make scripts executable
chmod +x "$GLOBAL_DIR/scripts"/*.sh
chmod +x "$GLOBAL_DIR/scripts"/*.py

print_success "Setup complete!"
echo
echo "🎉 You can now use the 'newsletter' command from anywhere!"
echo
echo "📚 Try these commands:"
echo "  newsletter           # Open the main menu"
echo "  newsletter --help    # Show help (coming soon)"
echo
echo "🔧 The command will:"
echo "  - Auto-detect newsletter-tracker repos in current directory"
echo "  - Fall back to your default repository"
echo "  - Work from any location on your Mac"
echo
echo "📱 Quick test:"
echo "  cd ~ && newsletter"
echo
print_success "Happy newsletter tracking! 📰"