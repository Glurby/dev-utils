# Fresh macOS Migration Guide

This guide walks you through migrating your complete development environment to a fresh macOS user profile.

## Prerequisites

- Fresh macOS user account
- Internet connection
- Admin privileges

## Step 1: Create Assessment on Source Machine

On your current machine, run the assessment:

```bash
assess-system
```

This creates a timestamped directory with your complete system state.

## Step 2: Transfer Assessment to New Machine

Copy the assessment directory to your new machine via:
- External drive
- Cloud storage (Dropbox, iCloud, etc.)
- Network transfer

## Step 3: Deploy on Fresh Machine

On the new machine:

1. **Download the deployment script:**
   ```bash
   curl -O https://raw.githubusercontent.com/your-repo/deploy-system.sh
   chmod +x deploy-system.sh
   ```

2. **Run deployment:**
   ```bash
   ./deploy-system.sh /path/to/assessment-directory
   ```

## What Gets Installed

### Phase 1: System Prerequisites
- Xcode Command Line Tools
- Homebrew package manager
- Essential tools (jq, curl, git)

### Phase 2: Applications
- All Homebrew formulas and casks
- macOS applications
- Command-line tools

### Phase 3: Development Environment
- Node.js and NPM global packages
- Python and pip packages
- Language-specific tools

### Phase 4: Configuration
- Dotfiles (.zshrc, .gitconfig, etc.)
- Directory structure
- Environment variables
- Shell configurations

### Phase 5: Repositories
- Git repository cloning (interactive)
- Preserves remote URLs and branch info

## Post-Migration Steps

1. **Restart terminal** to load new configurations
2. **Set up SSH keys** for Git authentication
3. **Configure application settings** as needed
4. **Verify installations** work correctly

## Manual Steps Required

Some items require manual setup:
- App Store applications (consider using `mas` tool)
- Application-specific licenses/logins
- System preferences
- SSH key generation/transfer
- Cloud service logins

## Troubleshooting

- **Homebrew PATH issues**: Restart terminal or run `source ~/.zshrc`
- **Permission errors**: Ensure admin privileges
- **Network failures**: Check internet connection, retry failed packages
- **Missing dependencies**: Run Homebrew doctor: `brew doctor`