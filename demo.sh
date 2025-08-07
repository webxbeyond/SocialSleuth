#!/bin/bash

# SocialSleuth v0.0.1 Example Script
# This script demonstrates various features of the enhanced SocialSleuth

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${WHITE}SocialSleuth v0.0.1 - Feature Demonstration${NC}"
echo "========================================"
echo ""

# Check if SocialSleuth script exists
if [[ ! -f "SocialSleuth.sh" ]]; then
    echo -e "${RED}Error: SocialSleuth.sh not found in current directory${NC}"
    exit 1
fi

# Make sure script is executable
chmod +x SocialSleuth.sh

echo -e "${BLUE}1. Basic Help and Information${NC}"
echo "------------------------------"
echo "Showing help information:"
./SocialSleuth.sh --help
echo ""

echo -e "${BLUE}2. Listing Supported Platforms${NC}"
echo "--------------------------------"
echo "Showing all supported platforms:"
./SocialSleuth.sh --list
echo ""

echo -e "${BLUE}3. Basic Username Scan${NC}"
echo "------------------------"
echo "Scanning for a test username (this is just a demo):"
echo "Command: ./SocialSleuth.sh testuser12345"
echo ""
read -p "Press Enter to continue with demo scan..."
./SocialSleuth.sh testuser12345
echo ""

echo -e "${BLUE}4. Verbose Scan with Specific Platforms${NC}"
echo "----------------------------------------"
echo "Scanning specific platforms with verbose output:"
echo "Command: ./SocialSleuth.sh -v -p GitHub,Twitter,Instagram testuser12345"
echo ""
read -p "Press Enter to continue..."
./SocialSleuth.sh -v -p GitHub,Twitter,Instagram testuser12345
echo ""

echo -e "${BLUE}5. JSON Output Format${NC}"
echo "----------------------"
echo "Generating JSON output:"
echo "Command: ./SocialSleuth.sh -f json -p GitHub,Twitter testuser12345"
echo ""
read -p "Press Enter to continue..."
./SocialSleuth.sh -f json -p GitHub,Twitter testuser12345
echo ""

echo -e "${BLUE}6. Performance Tuning${NC}"
echo "-----------------------"
echo "Using custom parallel jobs and timeout:"
echo "Command: ./SocialSleuth.sh -j 5 -t 5 -p GitHub,Twitter,Instagram testuser12345"
echo ""
read -p "Press Enter to continue..."
./SocialSleuth.sh -j 5 -t 5 -p GitHub,Twitter,Instagram testuser12345
echo ""

echo -e "${BLUE}7. Custom Output Directory${NC}"
echo "----------------------------"
echo "Saving results to custom directory:"
echo "Command: ./SocialSleuth.sh -o /tmp/demo_results -p GitHub testuser12345"
echo ""
read -p "Press Enter to continue..."
./SocialSleuth.sh -o /tmp/demo_results -p GitHub testuser12345
echo ""

echo -e "${GREEN}Demo completed!${NC}"
echo ""
echo -e "${YELLOW}Key Improvements in v0.0.1:${NC}"
echo "• Parallel processing for faster scans"
echo "• Multiple output formats (TXT, JSON, CSV)"
echo "• Enhanced error handling and validation"
echo "• Configurable timeouts and parallel jobs"
echo "• Comprehensive platform database"
echo "• Advanced breach database integration"
echo "• Professional command-line interface"
echo "• Detailed scanning statistics"
echo "• Organized platform categories"
echo "• Improved security and privacy features"
echo "• Rebranded as SocialSleuth"
echo ""
echo -e "${YELLOW}Files created during demo:${NC}"
if [[ -d "results" ]]; then
    echo "Results directory:"
    ls -la results/ 2>/dev/null || echo "  (empty)"
fi
if [[ -d "/tmp/demo_results" ]]; then
    echo ""
    echo "Demo results directory:"
    ls -la /tmp/demo_results/ 2>/dev/null || echo "  (empty)"
fi
echo ""
echo -e "${WHITE}For more information, see README_v2.md${NC}"
