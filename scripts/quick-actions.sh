#!/bin/bash

# Newsletter Tracker Quick Actions Script
# This script provides command-line shortcuts for common operations

set -e

# Auto-detect repository from current directory or use default
if git rev-parse --is-inside-work-tree &>/dev/null; then
    REPO_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")
    if [[ $REPO_URL =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
        REPO_OWNER="${BASH_REMATCH[1]}"
        REPO_NAME="${BASH_REMATCH[2]}"
    else
        REPO_OWNER="sadrzadehsina"
        REPO_NAME="newsletter-tracker"
    fi
else
    REPO_OWNER="sadrzadehsina"
    REPO_NAME="newsletter-tracker"
fi

BASE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${BLUE}📰 Newsletter Tracker${NC}"
    echo -e "${BLUE}===================${NC}"
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

# Check if gh CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed. Please install it first:"
        echo "  brew install gh"
        echo "  or visit: https://cli.github.com/"
        exit 1
    fi
}

# Main menu
show_menu() {
    print_header
    echo
    echo "Select an action:"
    echo "1. 📝 Add new article"
    echo "2. 📚 View reading queue"
    echo "3. 🔍 Search articles"
    echo "4. 📊 View dashboard"
    echo "5. ⭐ View high priority articles"
    echo "6. 📈 Generate analytics"
    echo "7. 🏷️  View by category"
    echo "8. 📱 Quick browser actions"
    echo "9. ❓ Help"
    echo "0. 🚪 Exit"
    echo
}

# Add new article
add_article() {
    print_header
    echo -e "${BLUE}📝 Adding New Article${NC}"
    echo
    
    # Open the new issue creation page
    open "${BASE_URL}/issues/new/choose"
    print_success "Opened article creation form in browser"
}

# View reading queue
view_queue() {
    check_gh_cli
    print_header
    echo -e "${BLUE}📚 Current Reading Queue${NC}"
    echo
    
    gh issue list --repo "${REPO_OWNER}/${REPO_NAME}" --label "to-read" --state open
}

# Search articles
search_articles() {
    check_gh_cli
    print_header
    echo -e "${BLUE}🔍 Search Articles${NC}"
    echo
    
    read -p "Enter search term: " search_term
    if [ -n "$search_term" ]; then
        gh issue list --repo "${REPO_OWNER}/${REPO_NAME}" --search "$search_term"
    else
        print_warning "No search term provided"
    fi
}

# View dashboard
view_dashboard() {
    print_header
    echo -e "${BLUE}📊 Opening Dashboard${NC}"
    echo
    
    open "${BASE_URL}"
    print_success "Opened dashboard in browser"
}

# View high priority
view_high_priority() {
    check_gh_cli
    print_header
    echo -e "${BLUE}⭐ High Priority Articles${NC}"
    echo
    
    gh issue list --repo "${REPO_OWNER}/${REPO_NAME}" --label "high-priority" --state open
}

# Generate analytics
generate_analytics() {
    print_header
    echo -e "${BLUE}📈 Generating Analytics${NC}"
    echo
    
    # Find the analytics script - check multiple possible locations
    SCRIPT_LOCATIONS=(
        "$(dirname "$0")/analytics.py"
        "$HOME/.newsletter-tracker/analytics.py"
        "$(pwd)/scripts/analytics.py"
        "$(git rev-parse --show-toplevel 2>/dev/null)/scripts/analytics.py"
    )
    
    ANALYTICS_SCRIPT=""
    for location in "${SCRIPT_LOCATIONS[@]}"; do
        if [ -f "$location" ]; then
            ANALYTICS_SCRIPT="$location"
            break
        fi
    done
    
    if [ -n "$ANALYTICS_SCRIPT" ]; then
        python3 "$ANALYTICS_SCRIPT" --owner "$REPO_OWNER" --repo "$REPO_NAME"
    else
        print_warning "Analytics script not found. Opening GitHub insights instead..."
        open "${BASE_URL}/pulse"
    fi
}

# View by category
view_by_category() {
    print_header
    echo -e "${BLUE}🏷️  Select Category${NC}"
    echo
    echo "1. 🔧 Technology"
    echo "2. 💼 Business" 
    echo "3. 📚 Personal Development"
    echo "4. 🤖 AI/Machine Learning"
    echo "5. 🚀 Startups"
    echo "6. 💰 Finance"
    echo
    
    read -p "Select category (1-6): " category_choice
    
    case $category_choice in
        1) label="tech" ;;
        2) label="business" ;;
        3) label="personal" ;;
        4) label="ai" ;;
        5) label="startups" ;;
        6) label="finance" ;;
        *) print_error "Invalid selection"; return ;;
    esac
    
    if command -v gh &> /dev/null; then
        gh issue list --repo "${REPO_OWNER}/${REPO_NAME}" --label "$label"
    else
        open "${BASE_URL}/issues?q=is%3Aissue+label%3A${label}"
    fi
}

# Quick browser actions
browser_actions() {
    print_header
    echo -e "${BLUE}📱 Quick Browser Actions${NC}"
    echo
    echo "1. 📝 Add article"
    echo "2. 📚 Reading queue"
    echo "3. 🔍 Search all"
    echo "4. 📊 Dashboard"
    echo "5. ⚙️  Repository settings"
    echo
    
    read -p "Select action (1-5): " browser_choice
    
    case $browser_choice in
        1) open "${BASE_URL}/issues/new/choose" ;;
        2) open "${BASE_URL}/issues?q=is%3Aissue+is%3Aopen+label%3A%22to-read%22" ;;
        3) open "${BASE_URL}/search?q=&type=issues" ;;
        4) open "${BASE_URL}" ;;
        5) open "${BASE_URL}/settings" ;;
        *) print_error "Invalid selection" ;;
    esac
    
    print_success "Opened in browser"
}

# Show help
show_help() {
    print_header
    echo -e "${BLUE}❓ Help & Tips${NC}"
    echo
    echo "🔧 Setup:"
    echo "  - Install GitHub CLI: brew install gh"
    echo "  - Authenticate: gh auth login"
    echo "  - Global access: This script can be run from anywhere"
    echo
    echo "📝 Article Management:"
    echo "  - Use issue templates for consistency"
    echo "  - Add labels for better organization"
    echo "  - Comment while reading for notes"
    echo "  - Close issues when done reading"
    echo
    echo "🔍 Search Tips:"
    echo "  - Use GitHub search syntax"
    echo "  - Filter by labels: 'label:tech'"
    echo "  - Search in content: 'in:body productivity'"
    echo "  - Date ranges: 'created:>2024-01-01'"
    echo
    echo "📱 Mobile Usage:"
    echo "  - Install GitHub mobile app"
    echo "  - Bookmark quick access URLs"
    echo "  - Use Siri shortcuts (iOS)"
    echo
    echo "🤖 Automation:"
    echo "  - Weekly summaries run automatically"
    echo "  - Auto-labeling based on content"
    echo "  - Progress tracking on completion"
    echo
    echo "🌐 Global Usage:"
    echo "  - Run 'newsletter' from any directory"
    echo "  - Auto-detects newsletter-tracker repos"
    echo "  - Falls back to default repo if not in git directory"
    echo
    echo "📚 Repository: ${BASE_URL}"
}

# Main script logic
main() {
    while true; do
        show_menu
        read -p "Enter your choice (0-9): " choice
        echo
        
        case $choice in
            1) add_article ;;
            2) view_queue ;;
            3) search_articles ;;
            4) view_dashboard ;;
            5) view_high_priority ;;
            6) generate_analytics ;;
            7) view_by_category ;;
            8) browser_actions ;;
            9) show_help ;;
            0) 
                print_success "Happy reading! 📚"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please select 0-9."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
        clear
    done
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi