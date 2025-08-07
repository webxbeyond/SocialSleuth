# SocialSleuth v0.0.1 - Enhanced Social Media Username Scanner

An advanced, feature-rich tool for discovering usernames across multiple social media platforms and data breach sources. This enhanced version includes significant improvements in functionality, performance, and usability.

## 🚀 What's New in v0.0.1

### Major Improvements
- **Parallel Processing**: Scan multiple platforms simultaneously for faster results
- **Enhanced Error Handling**: Robust error detection and recovery mechanisms
- **Multiple Output Formats**: Support for TXT, JSON, and CSV output formats
- **Configurable Platform Database**: Easy-to-modify platform definitions
- **Advanced Breach Detection**: Integration with multiple breach databases
- **Comprehensive Logging**: Detailed scan statistics and progress tracking
- **Command-Line Interface**: Full CLI with multiple options and switches
- **Input Validation**: Username validation with security checks
- **Timeout Management**: Configurable timeouts to prevent hanging requests
- **Platform Categories**: Organized scanning by platform types

### Technical Enhancements
- **Better HTTP Handling**: Improved curl usage with proper headers and error codes
- **Signal Handling**: Graceful interruption and cleanup
- **Memory Management**: Efficient temporary file handling
- **Code Organization**: Modular functions and clean architecture
- **Configuration System**: External configuration file support
- **Dependency Checking**: Automatic validation of required tools

## 📋 Prerequisites

### Required Dependencies
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install curl jq

# CentOS/RHEL/Fedora
sudo yum install curl jq
# or
sudo dnf install curl jq

# macOS (with Homebrew)
brew install curl jq

# Windows (with Chocolatey)
choco install curl jq
```

### Optional Dependencies
- `parallel` - For even faster parallel processing
- `tor` - For anonymized scanning (advanced usage)

## 🛠️ Installation

1. **Clone or Download**
   ```bash
   git clone <repository-url>
   cd SocialSleuth-main
   ```

2. **Make Executable**
   ```bash
   chmod +x SocialSleuth.sh
   ```

3. **Optional: Create Symlink for System-wide Access**
   ```bash
   sudo ln -s /path/to/SocialSleuth.sh /usr/local/bin/socialsleuth
   ```

## 🎯 Usage

### Basic Usage
```bash
# Simple scan
./SocialSleuth.sh username

# Interactive mode (prompts for username)
./SocialSleuth.sh
```

### Advanced Usage
```bash
# Verbose output with custom output directory
./SocialSleuth.sh -v -o /tmp/scans johndoe

# Scan specific platforms only
./SocialSleuth.sh -p Instagram,Twitter,GitHub johndoe

# JSON output format
./SocialSleuth.sh -f json johndoe

# Increased parallel jobs and timeout
./SocialSleuth.sh -j 20 -t 15 johndoe

# Scan social media platforms only
./SocialSleuth.sh -p "$(grep 'social' config.sh | cut -d'"' -f4)" johndoe
```

### Command-Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `-h, --help` | Show help message | - |
| `-v, --verbose` | Enable verbose output | false |
| `-o, --output DIR` | Specify output directory | results |
| `-j, --jobs NUM` | Number of parallel jobs | 10 |
| `-t, --timeout SEC` | Request timeout in seconds | 10 |
| `-f, --format FORMAT` | Output format (txt/json/csv) | txt |
| `-l, --list` | List all supported platforms | - |
| `-p, --platforms LIST` | Check specific platforms (comma-separated) | all |

## 📊 Output Formats

### Text Format (Default)
```
[+] Instagram:     Found! https://www.instagram.com/johndoe
[-] Facebook:      Not Found
[+] Twitter:       Found! https://www.twitter.com/johndoe
```

### JSON Format
```json
{
  "username": "johndoe",
  "scan_time": "2024-01-15T10:30:00Z",
  "results": [
    {
      "platform": "Instagram",
      "url": "https://www.instagram.com/johndoe",
      "status": "FOUND"
    }
  ]
}
```

### CSV Format
```csv
Platform,URL,Status
Instagram,https://www.instagram.com/johndoe,FOUND
Twitter,https://www.twitter.com/johndoe,FOUND
```

## 🔧 Configuration

### Platform Configuration
Edit `config.sh` to add or modify platforms:

```bash
["NewPlatform"]="https://newplatform.com/{username}|not_found_indicator"
```

### Custom Categories
Define platform groups for organized scanning:

```bash
declare -A PLATFORM_CATEGORIES=(
    ["social"]="Instagram Facebook Twitter LinkedIn"
    ["developer"]="GitHub GitLab Bitbucket"
)
```

## 🔍 Supported Platforms

### Social Media (25+ platforms)
- Instagram, Facebook, Twitter/X, LinkedIn, TikTok
- Snapchat, WhatsApp, VK, OK, Weibo

### Developer Platforms (10+ platforms)
- GitHub, GitLab, Bitbucket, Stack Overflow
- CodePen, Replit, Kaggle, SourceForge

### Content Platforms (15+ platforms)
- YouTube, Medium, DeviantART, Tumblr, Pinterest
- Blogger, WordPress, Substack, Wattpad

### Gaming Platforms (10+ platforms)
- Steam, Xbox, PlayStation, Twitch, Discord
- Roblox, Epic Games

### Professional Networks (8+ platforms)
- LinkedIn, AngelList, Behance, Dribbble
- Crunchbase, F6S

### Music Platforms (6+ platforms)
- Spotify, SoundCloud, Bandcamp, Last.fm
- Mixcloud, Apple Music

### And Many More...
- Total: 80+ platforms supported
- Regular updates with new platforms
- Easy configuration for custom additions

## 🛡️ Security Features

### Input Validation
- Username length validation (2-50 characters)
- Character set validation (alphanumeric, dots, hyphens, underscores)
- SQL injection prevention
- XSS protection

### Privacy Protection
- Configurable User-Agent strings
- Request timing randomization
- Optional Tor integration
- No data storage of sensitive information

### Rate Limiting
- Respectful request timing
- Configurable timeouts
- Automatic retry mechanisms
- Platform-specific delays

## 📈 Performance Optimizations

### Parallel Processing
- Configurable concurrent connections
- Intelligent job batching
- Resource usage optimization
- Memory-efficient operations

### Caching
- DNS resolution caching
- HTTP connection reuse
- Temporary file optimization
- Result caching mechanisms

### Error Handling
- Network timeout handling
- HTTP error code processing
- Graceful degradation
- Comprehensive error reporting

## 🔍 Advanced Features

### Breach Database Integration
- Hudson Rock API integration
- Have I Been Pwned support
- Custom breach database APIs
- Detailed compromise information

### Statistical Analysis
- Success rate calculation
- Platform availability metrics
- Response time analysis
- Confidence scoring

### Reporting
- Detailed scan summaries
- Export capabilities
- Historical comparisons
- Custom report templates

## 🚨 Troubleshooting

### Common Issues

1. **"Command not found: jq"**
   ```bash
   # Install jq
   sudo apt-get install jq  # Ubuntu/Debian
   sudo yum install jq      # CentOS/RHEL
   brew install jq          # macOS
   ```

2. **"Permission denied"**
   ```bash
   chmod +x SocialSleuth.sh
   ```

3. **"Timeout errors"**
   ```bash
   # Increase timeout
   ./SocialSleuth.sh -t 20 username
   ```

4. **"Too many parallel jobs"**
   ```bash
   # Reduce parallel jobs
   ./SocialSleuth.sh -j 5 username
   ```

### Debug Mode
```bash
# Enable verbose output for debugging
./SocialSleuth.sh -v username

# Check specific platform manually
curl -s "https://platform.com/username" | grep "not found"
```

## 📝 Contributing

### Adding New Platforms
1. Edit `config.sh`
2. Add platform configuration:
   ```bash
   ["NewPlatform"]="https://newplatform.com/{username}|error_indicator"
   ```
3. Test the platform
4. Submit a pull request

### Reporting Bugs
- Include the command used
- Provide error messages
- Specify your operating system
- Include relevant log files

### Feature Requests
- Describe the use case
- Explain the expected behavior
- Provide examples if applicable

## ⚖️ Legal Notice

### Ethical Usage
- This tool is for educational and legitimate research purposes only
- Respect platform terms of service
- Do not use for harassment or stalking
- Follow responsible disclosure practices

### Rate Limiting
- The tool includes built-in rate limiting
- Platforms may still block excessive requests
- Use responsibly to avoid IP bans
- Consider using proxies for large-scale scanning

### Privacy
- This tool does not store or transmit personal data
- Results are saved locally only
- No tracking or analytics included
- User privacy is respected

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

## 🤝 Acknowledgments

- Original UserFinder by Anis Afifi
- Enhanced as SocialSleuth
- Contributors and testers
- Open source community
- Platform APIs and documentation

## 📞 Support

For support, feature requests, or bug reports:
- Create an issue on the project repository
- Follow responsible disclosure for security issues
- Check existing issues before creating new ones

## 🔄 Version History

### v0.0.1 (Current)
- Complete rewrite with enhanced features
- Parallel processing implementation
- Multiple output formats
- Comprehensive error handling
- Advanced configuration system
- Rebranded as SocialSleuth

### v1.0.1 (Original UserFinder)
- Basic social media scanning
- Simple text output
- Limited error handling
- Sequential processing

---

**Note**: This tool is designed for legitimate security research and educational purposes. Always ensure you have proper authorization before scanning for usernames, and respect the terms of service of the platforms you're checking.
