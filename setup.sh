#!/bin/bash

# SocialSleuth v0.0.1 Installation and Setup Script
# This script helps you set up and test the enhanced SocialSleuth

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    printf "${color}[INFO]${NC} %s\n" "$message"
}

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            echo "ubuntu"
        elif command_exists yum; then
            echo "centos"
        elif command_exists dnf; then
            echo "fedora"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Function to install dependencies
install_dependencies() {
    local os=$(detect_os)
    print_status $BLUE "Detected OS: $os"
    
    case $os in
        ubuntu)
            print_status $BLUE "Installing dependencies using apt-get..."
            sudo apt-get update
            sudo apt-get install -y curl jq
            ;;
        centos)
            print_status $BLUE "Installing dependencies using yum..."
            sudo yum install -y curl jq
            ;;
        fedora)
            print_status $BLUE "Installing dependencies using dnf..."
            sudo dnf install -y curl jq
            ;;
        macos)
            if command_exists brew; then
                print_status $BLUE "Installing dependencies using Homebrew..."
                brew install curl jq
            else
                print_error "Homebrew not found. Please install Homebrew first:"
                echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                exit 1
            fi
            ;;
        windows)
            if command_exists choco; then
                print_status $BLUE "Installing dependencies using Chocolatey..."
                choco install curl jq -y
            else
                print_warning "Chocolatey not found. Please install dependencies manually:"
                echo "  - Download curl from https://curl.se/windows/"
                echo "  - Download jq from https://stedolan.github.io/jq/download/"
            fi
            ;;
        *)
            print_warning "Unknown OS. Please install curl and jq manually."
            ;;
    esac
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    print_status $BLUE "Checking dependencies..."
    
    if ! command_exists curl; then
        missing_deps+=("curl")
    else
        print_success "curl is installed"
    fi
    
    if ! command_exists jq; then
        missing_deps+=("jq")
    else
        print_success "jq is installed"
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        return 1
    else
        print_success "All dependencies are installed"
        return 0
    fi
}

# Function to setup SocialSleuth
setup_socialsleuth() {
    print_status $BLUE "Setting up SocialSleuth..."
    
    # Make script executable
    if [[ -f "SocialSleuth.sh" ]]; then
        chmod +x SocialSleuth.sh
        print_success "Made SocialSleuth.sh executable"
    else
        print_error "SocialSleuth.sh not found in current directory"
        exit 1
    fi
    
    # Create results directory
    if [[ ! -d "results" ]]; then
        mkdir -p results
        print_success "Created results directory"
    fi
    
    # Check config file
    if [[ -f "config.sh" ]]; then
        print_success "Configuration file found"
    else
        print_warning "Configuration file not found - using built-in defaults"
    fi
}

# Function to run tests
run_tests() {
    print_status $BLUE "Running basic tests..."
    
    # Test help command
    if ./SocialSleuth.sh --help >/dev/null 2>&1; then
        print_success "Help command works"
    else
        print_error "Help command failed"
        return 1
    fi
    
    # Test list platforms command
    if ./SocialSleuth.sh --list >/dev/null 2>&1; then
        print_success "List platforms command works"
    else
        print_error "List platforms command failed"
        return 1
    fi
    
    # Test with a fake username (should not find anything)
    print_status $BLUE "Testing with fake username 'test12345nonexistent'..."
    if ./SocialSleuth.sh -v test12345nonexistent >/dev/null 2>&1; then
        print_success "Basic scan test completed"
    else
        print_warning "Basic scan test had issues (this might be normal)"
    fi
}

# Function to create system-wide alias
create_alias() {
    local script_path=$(realpath SocialSleuth.sh)
    local shell_rc=""
    
    # Detect shell and set appropriate rc file
    if [[ "$SHELL" == *"bash"* ]]; then
        shell_rc="$HOME/.bashrc"
    elif [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.profile"
    fi
    
    # Add alias to shell rc file
    if ! grep -q "alias socialsleuth=" "$shell_rc" 2>/dev/null; then
        echo "alias socialsleuth='$script_path'" >> "$shell_rc"
        print_success "Added 'socialsleuth' alias to $shell_rc"
        print_status $YELLOW "Run 'source $shell_rc' or restart your terminal to use the alias"
    else
        print_status $YELLOW "Alias already exists in $shell_rc"
    fi
}

# Function to show usage examples
show_examples() {
    print_status $WHITE "Usage Examples:"
    echo ""
    echo "  Basic scan:"
    echo "    ./SocialSleuth.sh johndoe"
    echo ""
    echo "  Verbose scan with JSON output:"
    echo "    ./SocialSleuth.sh -v -f json johndoe"
    echo ""
    echo "  Scan specific platforms:"
    echo "    ./SocialSleuth.sh -p Instagram,Twitter,GitHub johndoe"
    echo ""
    echo "  List all supported platforms:"
    echo "    ./SocialSleuth.sh --list"
    echo ""
    echo "  Get help:"
    echo "    ./SocialSleuth.sh --help"
    echo ""
}

# Main installation function
main() {
    print_status $WHITE "SocialSleuth v0.0.1 Setup Script"
    echo "=================================="
    echo ""
    
    # Check if we're in the right directory
    if [[ ! -f "SocialSleuth.sh" ]]; then
        print_error "SocialSleuth.sh not found in current directory"
        print_status $YELLOW "Please run this script from the SocialSleuth directory"
        exit 1
    fi
    
    # Install dependencies if needed
    if ! check_dependencies; then
        read -p "Would you like to install missing dependencies? (y/N): " install_deps
        if [[ "$install_deps" =~ ^[Yy]$ ]]; then
            install_dependencies
            if ! check_dependencies; then
                print_error "Failed to install dependencies"
                exit 1
            fi
        else
            print_error "Dependencies are required for UserFinder to work"
            exit 1
        fi
    fi
    
    # Setup SocialSleuth
    setup_socialsleuth
    
    # Run tests
    read -p "Would you like to run basic tests? (Y/n): " run_test
    if [[ ! "$run_test" =~ ^[Nn]$ ]]; then
        run_tests
    fi
    
    # Create system-wide alias
    read -p "Would you like to create a system-wide 'socialsleuth' alias? (Y/n): " create_alias_choice
    if [[ ! "$create_alias_choice" =~ ^[Nn]$ ]]; then
        create_alias
    fi
    
    echo ""
    print_success "SocialSleuth v0.0.1 setup completed successfully!"
    echo ""
    show_examples
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
