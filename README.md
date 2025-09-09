# log-archive-tool https://roadmap.sh/projects/log-archive-tool

### How it works (1-liner)
#### Creates a timestamped .tar.gz of the target directory (skips unreadables), logs output, and emails both files via Gmail SMTP using your Mutt config.

#### Requirements
- sudo apt-get update
- sudo apt-get install -y neomutt ca-certificates dos2unix tar git
- Gmail App Password (16 chars, no spaces) with 2-Step Verification enabled.

# Get Files & Prep
### Place files anywhere, e.g.:
- mkdir -p ~/log-archive-tool
- cd ~/log-archive-tool

# If pulled from Windows/WSL:
- dos2unix log-archive.sh

### Configure Mutt (secure, per-user)

~/.config/mutt/mutt.gmail.rc (minimal)

set from      = "YOUR_GMAIL@gmail.com"\
set realname  = "Your Name"\
set smtp_url  = "smtp://YOUR_GMAIL@gmail.com@smtp.gmail.com:587/"\
set smtp_pass = "YOUR16CHARAPPPASSWORD"\
set ssl_starttls = yes\
set ssl_force_tls = yes\
set smtp_authenticators = "login:plain"

### Run
- mkdir -p ~/.config/mutt
- cp ./mutt.gmail.rc ~/.config/mutt/mutt.gmail.rc
- dos2unix ~/.config/mutt/mutt.gmail.rc
- chmod 600 ~/.config/mutt/mutt.gmail.rc

# Smoke Test
echo "smtp ok?" | neomutt -F "$HOME/.config/mutt/mutt.gmail.rc" -d 5 -s "mutt smtp test" -- YOUR_GMAIL@gmail.com

# Run
chmod +x ./log-archive.sh

# Run Archive logs (unreadables are tolerated):
#### ./log-archive.sh /var/log

## You’ll receive:
new_archive_YYYY-MM-DD_HH-MM-SS.tar.gz\
session_YYYY-MM-DD_HH-MM-SS.txt\

# Keep Secrets Out of Git

In your repo directory:\

- printf "mutt.gmail.rc\nsession_*.txt\n*.tar.gz\n.neomuttdebug*\n" >> .gitignore
- git rm --cached mutt.gmail.rc 2>/dev/null || true
- git add .gitignore && git commit -m "Ignore Mutt secret + artifacts"

## Troubleshooting (quick)

- SASL authentication failed → Wrong app password / spaces / CRLF; retype 16 chars, dos2unix the rc file.
- (null): unable to attach file → Attachments didn’t exist; let the script create them.
- unbound variable → Script uses set -u; keep variable names consistent.
- Workspace Gmail → App Passwords may be disabled by admin; use personal Gmail or an SMTP relay.
