#!/bin/bash

# SocialSleuth v0.0.1 - Enhanced Social Media Username Scanner
# Developer: Anis Afifi
# Description: Advanced tool for finding usernames across multiple social networks and data breach sources

# Configuration
VERSION="0.0.1"
OUTPUT_DIR="results"
VERBOSE=false
PARALLEL_JOBS=10
TIMEOUT=10
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

# Load external configuration if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_LOADED=false

# Try loading config from multiple locations (Linux-friendly)
CONFIG_PATHS=(
    "$SCRIPT_DIR/config.sh"                    # Local to script
    "$HOME/.config/socialsleuth/config.sh"    # User config
    "/etc/socialsleuth/config.sh"             # System config
)

for config_path in "${CONFIG_PATHS[@]}"; do
    if [[ -f "$config_path" ]]; then
        source "$config_path"
        # Use external config if available, otherwise fall back to internal config
        if [[ ${#PLATFORM_CONFIG[@]} -gt 0 ]]; then
            declare -A PLATFORMS=()
            for platform in "${!PLATFORM_CONFIG[@]}"; do
                PLATFORMS["$platform"]="${PLATFORM_CONFIG[$platform]}"
            done
            # Update defaults from config if available
            [[ -n "$DEFAULT_TIMEOUT" ]] && TIMEOUT="$DEFAULT_TIMEOUT"
            [[ -n "$DEFAULT_PARALLEL_JOBS" ]] && PARALLEL_JOBS="$DEFAULT_PARALLEL_JOBS"
            [[ -n "$DEFAULT_USER_AGENT" ]] && USER_AGENT="$DEFAULT_USER_AGENT"
            [[ -n "$DEFAULT_OUTPUT_DIR" ]] && OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
            CONFIG_LOADED=true
            break
        fi
    fi
done

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Platform configurations (fallback if config.sh not available)
if [[ "$CONFIG_LOADED" != true ]]; then
    declare -A PLATFORMS=(
        ["Instagram"]="https://www.instagram.com/{username}|The link you followed may be broken"
        ["Facebook"]="https://www.facebook.com/{username}|not found"
        ["Twitter"]="https://www.twitter.com/{username}|page doesn't exist"
        ["YouTube"]="https://www.youtube.com/{username}|Not Found"
        ["GitHub"]="https://www.github.com/{username}|404 Not Found"
        ["Reddit"]="https://www.reddit.com/user/{username}|404"
        ["LinkedIn"]="https://www.linkedin.com/in/{username}|404"
        ["TikTok"]="https://www.tiktok.com/@{username}|couldn't find this account"
        ["Pinterest"]="https://www.pinterest.com/{username}|?show_error"
        ["Tumblr"]="https://{username}.tumblr.com|404"
        ["Medium"]="https://medium.com/@{username}|404"
        ["DeviantART"]="https://{username}.deviantart.com|404"
        ["Steam"]="https://steamcommunity.com/id/{username}|The specified profile could not be found"
        ["Spotify"]="https://open.spotify.com/user/{username}|404"
        ["SoundCloud"]="https://soundcloud.com/{username}|404 Not Found"
        ["Twitch"]="https://www.twitch.tv/{username}|Sorry. Unless you've got a time machine"
        ["Discord"]="https://discord.com/users/{username}|404"
        ["Snapchat"]="https://www.snapchat.com/add/{username}|Sorry! Couldn't find"
        ["OnlyFans"]="https://onlyfans.com/{username}|404"
        ["Patreon"]="https://www.patreon.com/{username}|404"
    )
fi

# Statistics tracking
declare -A STATS=(
    ["checked"]=0
    ["found"]=0
    ["not_found"]=0
    ["errors"]=0
)

# Signal handlers
trap 'cleanup; exit 1' SIGINT SIGTERM

# Function to display banner
banner() {
    clear
    printf "${WHITE}"
    cat << "EOF"
  _____            _       _  _____  _            _   _     
 / ____|          (_)     | |/ ____|| |          | | | |    
| (___   ___   ___ _  __ _| | (___  | | ___ _   _| |_| |__  
 \___ \ / _ \ / __| |/ _` | |\___ \ | |/ _ \ | | | __| '_ \ 
 ____) | (_) | (__| | (_| | |____) || |  __/ |_| | |_| | | |
|_____/ \___/ \___|_|\__,_|_|_____/ |_|\___|\__,_|\__|_| |_|
EOF
    printf "${NC}\n"
    printf "${YELLOW}             .:.:;..${NC}${WHITE} SocialSleuth v${VERSION} - Enhanced Edition ${NC}${YELLOW}..;:.:.${NC}\n"
    printf "${CYAN}                      Advanced Social Media Username Scanner${NC}\n\n"
}

# Function to display help
show_help() {
    printf "${WHITE}Usage:${NC} $0 [OPTIONS] <username>\n\n"
    printf "${WHITE}OPTIONS:${NC}\n"
    printf "  -h, --help          Show this help message\n"
    printf "  -v, --verbose       Show all not found platforms (default: shows first 10)\n"
    printf "  -o, --output DIR    Specify output directory (default: results)\n"
    printf "  -j, --jobs NUM      Number of parallel jobs (default: 10)\n"
    printf "  -t, --timeout SEC   Request timeout in seconds (default: 10)\n"
    printf "  -f, --format FORMAT Output format: txt, json, csv (default: txt)\n"
    printf "  -l, --list          List all supported platforms\n"
    printf "  -p, --platforms LIST Check only specific platforms (comma-separated)\n\n"
    printf "${WHITE}Examples:${NC}\n"
    printf "  $0 johndoe\n"
    printf "  $0 -v -o /tmp/scans johndoe\n"
    printf "  $0 -p Instagram,Twitter,GitHub johndoe\n"
    printf "  $0 -f json johndoe\n"
}

# Function to list supported platforms
list_platforms() {
    printf "${WHITE}Supported Platforms:${NC}\n"
    for platform in "${!PLATFORMS[@]}"; do
        printf "  ${GREEN}•${NC} $platform\n"
    done | sort
    printf "\nTotal: ${#PLATFORMS[@]} platforms\n"
}

# Function to validate dependencies
check_dependencies() {
    local missing_deps=()
    
    for cmd in curl jq; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        printf "${RED}Error: Missing dependencies: ${missing_deps[*]}${NC}\n"
        printf "${YELLOW}Please install them and try again.${NC}\n"
        exit 1
    fi
}

# Function to create output directory
setup_output() {
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        mkdir -p "$OUTPUT_DIR" || {
            printf "${RED}Error: Cannot create output directory $OUTPUT_DIR${NC}\n"
            exit 1
        }
    fi
}

# Function to validate username
validate_username() {
    local username="$1"
    
    if [[ -z "$username" ]]; then
        printf "${RED}Error: Username cannot be empty${NC}\n"
        return 1
    fi
    
    if [[ ${#username} -lt 2 || ${#username} -gt 50 ]]; then
        printf "${RED}Error: Username must be between 2 and 50 characters${NC}\n"
        return 1
    fi
    
    if [[ ! "$username" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        printf "${RED}Error: Username contains invalid characters${NC}\n"
        return 1
    fi
    
    return 0
}

# Function to check info-stealer databases
check_breaches() {
    local username="$1"
    local output_file="$2"
    
    printf "${BLUE}[>]${NC} Checking username ${WHITE}$username${NC} in breach databases...\n"
    
    local response
    response=$(curl -s --connect-timeout "$TIMEOUT" --max-time "$((TIMEOUT * 2))" \
        -H "User-Agent: $USER_AGENT" \
        "https://cavalier.hudsonrock.com/api/json/v2/osint-tools/search-by-username?username=$username" 2>/dev/null)
    
    if [[ $? -ne 0 || -z "$response" ]]; then
        printf "${YELLOW}[!]${NC} Could not connect to breach database\n"
        return 1
    fi
    
    local stealer_count
    stealer_count=$(echo "$response" | jq -r '.stealers | length' 2>/dev/null)
    
    if [[ "$stealer_count" == "0" || "$stealer_count" == "null" ]]; then
        printf "${GREEN}[+]${NC} No breaches found\n"
        return 0
    fi
    
    printf "${RED}[!]${NC} Found in ${stealer_count} breach(es):\n"
    echo "$response" | jq -c '.stealers[]' 2>/dev/null | while IFS= read -r line; do
        local date_compromised operating_system computer_name antiviruses ip
        date_compromised=$(echo "$line" | jq -r '.date_compromised // "Unknown"')
        operating_system=$(echo "$line" | jq -r '.operating_system // "Unknown"')
        computer_name=$(echo "$line" | jq -r '.computer_name // "Unknown"')
        antiviruses=$(echo "$line" | jq -r '.antiviruses // "Unknown"')
        ip=$(echo "$line" | jq -r '.ip // "Unknown"')
        
        printf "    ${WHITE}Date:${NC} $date_compromised\n"
        printf "    ${WHITE}OS:${NC} $operating_system\n"
        printf "    ${WHITE}Computer:${NC} $computer_name\n"
        printf "    ${WHITE}Antivirus:${NC} $antiviruses\n"
        printf "    ${WHITE}IP:${NC} $ip\n"
        printf "\n"
        
        # Save to file
        echo "BREACH_DATA,$date_compromised,$operating_system,$computer_name,$antiviruses,$ip" >> "$output_file"
    done
}

# Function to check a single platform
check_platform() {
    local platform="$1"
    local username="$2"
    local output_file="$3"
    local stats_dir="$4"
    local results_dir="$5"
    
    # Show real-time progress
    printf "${CYAN}[>]${NC} Checking %-15s ${CYAN}...${NC}\r" "$platform"
    
    local config="${PLATFORMS[$platform]}"
    local url=$(echo "$config" | cut -d'|' -f1 | sed "s/{username}/$username/g")
    local not_found_indicator=$(echo "$config" | cut -d'|' -f2)
    
    # Use temporary files for thread-safe statistics tracking
    echo "1" >> "$stats_dir/checked"
    
    local response_code http_content temp_file
    temp_file="/tmp/socialsleuth_${platform}_$$.tmp"
    response_code=$(curl -s -o "$temp_file" -w "%{http_code}" \
        --connect-timeout "$TIMEOUT" --max-time "$TIMEOUT" \
        -H "User-Agent: $USER_AGENT" \
        -H "Accept-Language: en" \
        -L "$url" 2>/dev/null)
    
    # Read content safely, filtering out null bytes
    http_content=$(tr -d '\0' < "$temp_file" 2>/dev/null)
    rm -f "$temp_file"
    
    if [[ $? -ne 0 ]] || [[ -z "$response_code" ]]; then
        echo "ERROR|$platform|Error connecting" >> "$results_dir/errors.tmp"
        echo "1" >> "$stats_dir/errors"
        # Clear the progress line
        printf "%-50s\r" " "
        return 1
    fi
    
    # Check if profile exists
    if [[ "$response_code" == "200" ]] && [[ ! "$http_content" =~ $not_found_indicator ]]; then
        echo "FOUND|$platform|$url" >> "$results_dir/found.tmp"
        echo "$platform,$url,FOUND" >> "$output_file"
        echo "1" >> "$stats_dir/found"
        # Clear the progress line
        printf "%-50s\r" " "
        return 0
    else
        echo "NOT_FOUND|$platform|$url" >> "$results_dir/not_found.tmp"
        echo "1" >> "$stats_dir/not_found"
        # Clear the progress line
        printf "%-50s\r" " "
        return 1
    fi
}

# Function to scan all platforms
scan_platforms() {
    local username="$1"
    local output_file="$2"
    local specific_platforms="$3"
    
    printf "${BLUE}[>]${NC} Scanning social media platforms for ${WHITE}$username${NC}...\n\n"
    
    # Create temporary directory for thread-safe statistics
    local stats_dir="/tmp/socialsleuth_stats_$$"
    local results_dir="/tmp/socialsleuth_results_$$"
    mkdir -p "$stats_dir" "$results_dir"
    
    # Initialize statistics files
    touch "$stats_dir/checked" "$stats_dir/found" "$stats_dir/not_found" "$stats_dir/errors"
    touch "$results_dir/found.tmp" "$results_dir/not_found.tmp" "$results_dir/errors.tmp"
    
    local platforms_to_check=()
    if [[ -n "$specific_platforms" ]]; then
        IFS=',' read -ra platforms_to_check <<< "$specific_platforms"
    else
        platforms_to_check=("${!PLATFORMS[@]}")
    fi
    
    # Sort platforms for consistent output
    readarray -t sorted_platforms < <(printf '%s\n' "${platforms_to_check[@]}" | sort)
    
    # Process platforms in parallel batches
    local count=0
    for platform in "${sorted_platforms[@]}"; do
        if [[ -n "${PLATFORMS[$platform]}" ]]; then
            check_platform "$platform" "$username" "$output_file" "$stats_dir" "$results_dir" &
            ((count++))
            
            # Limit parallel jobs
            if ((count % PARALLEL_JOBS == 0)); then
                wait
            fi
        else
            printf "${RED}[!]${NC} Unknown platform: $platform\n"
        fi
    done
    
    wait # Wait for remaining jobs
    
    # Clear any remaining progress indicators
    printf "%-50s\n" " "
    
    # Display results in order: Found first, then Not Found
    printf "${WHITE}=== FOUND PROFILES ===${NC}\n"
    if [[ -f "$results_dir/found.tmp" && -s "$results_dir/found.tmp" ]]; then
        while IFS='|' read -r status platform url; do
            printf "${GREEN}[+]${NC} %-15s ${GREEN}Found!${NC} $url\n" "$platform:"
        done < <(sort -t'|' -k2 < "$results_dir/found.tmp")
    else
        printf "${YELLOW}No profiles found${NC}\n"
    fi
    
    # Always display not found platforms (unless specifically disabled)
    printf "\n${WHITE}=== NOT FOUND ===${NC}\n"
    if [[ -f "$results_dir/not_found.tmp" && -s "$results_dir/not_found.tmp" ]]; then
        if [[ "$VERBOSE" == true ]]; then
            # In verbose mode, show all not found platforms
            while IFS='|' read -r status platform url; do
                printf "${YELLOW}[-]${NC} %-15s ${YELLOW}Not Found${NC}\n" "$platform:"
            done < <(sort -t'|' -k2 < "$results_dir/not_found.tmp")
        else
            # In normal mode, show count and first few examples
            local not_found_count=$(wc -l < "$results_dir/not_found.tmp")
            printf "${YELLOW}$not_found_count platforms not found${NC}"
            if [[ $not_found_count -le 10 ]]; then
                printf " ${YELLOW}(all listed below)${NC}:\n"
                while IFS='|' read -r status platform url; do
                    printf "${YELLOW}[-]${NC} %-15s ${YELLOW}Not Found${NC}\n" "$platform:"
                done < <(sort -t'|' -k2 < "$results_dir/not_found.tmp")
            else
                printf " ${YELLOW}(showing first 10, use -v for all)${NC}:\n"
                while IFS='|' read -r status platform url; do
                    printf "${YELLOW}[-]${NC} %-15s ${YELLOW}Not Found${NC}\n" "$platform:"
                done < <(sort -t'|' -k2 < "$results_dir/not_found.tmp" | head -10)
            fi
        fi
    else
        printf "${GREEN}All checked platforms found!${NC}\n"
    fi
    
    # Display errors
    if [[ -f "$results_dir/errors.tmp" && -s "$results_dir/errors.tmp" ]]; then
        printf "\n${WHITE}=== ERRORS ===${NC}\n"
        while IFS='|' read -r status platform message; do
            printf "${RED}[!]${NC} %-15s ${RED}$message${NC}\n" "$platform:"
        done < <(sort -t'|' -k2 < "$results_dir/errors.tmp")
    fi
    
    # Collect statistics from temporary files safely
    STATS["checked"]=$([ -f "$stats_dir/checked" ] && wc -l < "$stats_dir/checked" || echo "0")
    STATS["found"]=$([ -f "$stats_dir/found" ] && wc -l < "$stats_dir/found" || echo "0")
    STATS["not_found"]=$([ -f "$stats_dir/not_found" ] && wc -l < "$stats_dir/not_found" || echo "0")
    STATS["errors"]=$([ -f "$stats_dir/errors" ] && wc -l < "$stats_dir/errors" || echo "0")
    
    # Clean up temporary directories
    rm -rf "$stats_dir" "$results_dir"
}

# Function to generate summary report
generate_summary() {
    local username="$1"
    local output_file="$2"
    
    printf "\n${WHITE}=== SCAN SUMMARY ===${NC}\n"
    printf "${WHITE}Username:${NC} $username\n"
    printf "${WHITE}Scan Time:${NC} $(date)\n"
    printf "${WHITE}Platforms Checked:${NC} ${STATS[checked]}\n"
    printf "${GREEN}Found:${NC} ${STATS[found]}\n"
    printf "${YELLOW}Not Found:${NC} ${STATS[not_found]}\n"
    printf "${RED}Errors:${NC} ${STATS[errors]}\n"
    
    if [[ -f "$output_file" ]]; then
        local found_count
        found_count=$(grep -c "FOUND" "$output_file" 2>/dev/null || echo "0")
        printf "${WHITE}Results saved to:${NC} $output_file\n"
        
        # Calculate success rate safely (avoid division by zero)
        if [[ ${STATS[checked]} -gt 0 ]]; then
            printf "${WHITE}Success Rate:${NC} $(( found_count * 100 / STATS[checked] ))%%\n"
        else
            printf "${WHITE}Success Rate:${NC} N/A (no platforms checked)\n"
        fi
    fi
}

# Function to convert output format
convert_output() {
    local input_file="$1"
    local output_format="$2"
    local username="$3"
    
    case "$output_format" in
        "json")
            local json_file="${input_file%.txt}.json"
            {
                printf '{\n  "username": "%s",\n  "scan_time": "%s",\n  "results": [\n' "$username" "$(date -Iseconds)"
                
                local first=true
                while IFS=',' read -r platform url status; do
                    if [[ "$status" == "FOUND" ]]; then
                        if [[ "$first" == true ]]; then
                            first=false
                        else
                            printf ',\n'
                        fi
                        printf '    {"platform": "%s", "url": "%s", "status": "%s"}' "$platform" "$url" "$status"
                    fi
                done < "$input_file"
                
                printf '\n  ]\n}\n'
            } > "$json_file"
            printf "${GREEN}[+]${NC} JSON report saved to: $json_file\n"
            ;;
        "csv")
            local csv_file="${input_file%.txt}.csv"
            {
                printf "Platform,URL,Status\n"
                cat "$input_file"
            } > "$csv_file"
            printf "${GREEN}[+]${NC} CSV report saved to: $csv_file\n"
            ;;
    esac
}

# Function to cleanup temporary files
cleanup() {
    rm -f /tmp/socialsleuth_*.tmp
    rm -rf /tmp/socialsleuth_stats_*
    rm -rf /tmp/socialsleuth_results_*
    printf "\n${YELLOW}[!]${NC} Scan interrupted. Partial results may be available.\n"
}

# Main function
main() {
    local username=""
    local output_format="txt"
    local specific_platforms=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -j|--jobs)
                PARALLEL_JOBS="$2"
                shift 2
                ;;
            -t|--timeout)
                TIMEOUT="$2"
                shift 2
                ;;
            -f|--format)
                output_format="$2"
                shift 2
                ;;
            -l|--list)
                list_platforms
                exit 0
                ;;
            -p|--platforms)
                specific_platforms="$2"
                shift 2
                ;;
            -*)
                printf "${RED}Error: Unknown option $1${NC}\n"
                show_help
                exit 1
                ;;
            *)
                username="$1"
                shift
                ;;
        esac
    done
    
    # Display banner
    banner
    
    # Check dependencies
    check_dependencies
    
    # Get username if not provided
    if [[ -z "$username" ]]; then
        printf "${BLUE}[>]${NC} Enter username to search: "
        read -r username
    fi
    
    # Validate username
    if ! validate_username "$username"; then
        exit 1
    fi

GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# TLDs you want to check
tlds=(".com" ".net" ".org" ".io" ".co")

# Domain/username input
username="$1"

if [[ -z "$username" ]]; then
  echo "Usage: $0 <domain_without_tld>"
  exit 1
fi

printf "${BLUE}[>]${NC} Checking domain availability for: ${WHITE}$username${NC} (via RDAP)\n"

for tld in "${tlds[@]}"; do
    domain="$username$tld"
    printf "  ${WHITE}$domain${NC}: "

    # RDAP query (standardized JSON API)
    response=$(curl -s "https://rdap.org/domain/$domain")

    # RDAP returns HTTP 404 if not found = AVAILABLE
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "https://rdap.org/domain/$domain")

    if [[ "$http_code" -eq 404 ]]; then
        printf "${GREEN}AVAILABLE${NC}\n"
    else
        printf "${RED}TAKEN${NC}\n"
    fi
done

    # Setup output directory
    setup_output
    
    # Create output file
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local output_file="$OUTPUT_DIR/${username}_${timestamp}.txt"
    
    # Remove existing output file if it exists
    if [[ -f "$output_file" ]]; then
        rm -f "$output_file"
    fi
    
    # Start scanning
    printf "${GREEN}[+]${NC} Starting scan for username: ${WHITE}$username${NC}\n"
    printf "${GREEN}[+]${NC} Output will be saved to: ${WHITE}$output_file${NC}\n\n"
    
    # Check breach databases
    check_breaches "$username" "$output_file"
    
    # Scan social media platforms
    scan_platforms "$username" "$output_file" "$specific_platforms"
    
    # Generate summary
    generate_summary "$username" "$output_file"
    
    # Convert output format if requested
    if [[ "$output_format" != "txt" ]]; then
        convert_output "$output_file" "$output_format" "$username"
    fi
    
    printf "\n${GREEN}[+]${NC} Scan completed!\n"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
