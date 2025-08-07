# SocialSleuth Makefile
# Usage: make install, make uninstall, make user-install, make user-uninstall

.PHONY: install uninstall user-install user-uninstall clean test

# System-wide installation (requires root)
install:
	@echo "Installing SocialSleuth system-wide..."
	@sudo ./install.sh

# System-wide uninstallation (requires root)
uninstall:
	@echo "Uninstalling SocialSleuth system-wide..."
	@sudo ./uninstall.sh

# User installation (no root required)
user-install:
	@echo "Installing SocialSleuth for current user..."
	@./install.sh

# User uninstallation
user-uninstall:
	@echo "Uninstalling SocialSleuth for current user..."
	@./uninstall.sh

# Test installation
test:
	@echo "Testing SocialSleuth installation..."
	@bash -n SocialSleuth.sh && echo "✅ Syntax check passed"
	@command -v curl >/dev/null 2>&1 || (echo "❌ curl not found" && exit 1)
	@command -v jq >/dev/null 2>&1 || (echo "❌ jq not found" && exit 1)
	@echo "✅ Dependencies check passed"

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	@rm -f /tmp/socialsleuth_*
	@rm -rf /tmp/socialsleuth_stats_*
	@rm -rf /tmp/socialsleuth_results_*
	@echo "✅ Cleanup complete"

# Make scripts executable
executable:
	@chmod +x SocialSleuth.sh install.sh uninstall.sh

# Package for distribution
package:
	@echo "Creating distribution package..."
	@mkdir -p dist
	@tar -czf dist/socialsleuth-$(shell date +%Y%m%d).tar.gz \
		SocialSleuth.sh config.sh README.md LICENSE \
		install.sh uninstall.sh Makefile
	@echo "✅ Package created: dist/socialsleuth-$(shell date +%Y%m%d).tar.gz"

help:
	@echo "SocialSleuth Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  install      - Install system-wide (requires sudo)"
	@echo "  uninstall    - Uninstall system-wide (requires sudo)"
	@echo "  user-install - Install for current user only"
	@echo "  user-uninstall - Uninstall for current user"
	@echo "  test         - Test syntax and dependencies"
	@echo "  clean        - Clean temporary files"
	@echo "  executable   - Make scripts executable"
	@echo "  package      - Create distribution package"
	@echo "  help         - Show this help"
