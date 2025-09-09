#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
MUTT_RC="$SCRIPT_DIR/mutt.gmail.rc"          # or: "$HOME/.config/mutt/mutt.gmail.rc"
MUTT_BIN="$(command -v neomutt || command -v mutt)"

[[ -f "$MUTT_RC" ]] || { echo "Missing Mutt config: $MUTT_RC" >&2; exit 1; }
[[ -n "${MUTT_BIN:-}" ]] || { echo "mutt/neomutt not installed" >&2; exit 1; }

if [[ ! -f "$MUTT_RC" ]]; then
  echo "Missing Mutt config: $MUTT_RC" >&2
  exit 1
fi

MUTT_BIN="$(command -v neomutt || command -v mutt || true)"
if [[ -z "${MUTT_BIN:-}" ]]; then
  echo "mutt/neomutt not installed" >&2
  exit 1
fi

# Here we are checking if the directory name
# is provided in the argument or not.
# -z will check for the null string 
# and $1 will check if the positional argument
# is passed or not
if [ -z "${1:-}" ]; then
  
  # If the name of the folder was not specified 
  # in the argument 
  # Then the following message will be displayed 
  # to the screen 
  echo "Warning : Please provide the folder name as an argument"

  exit 1
fi

# We need to verify whether the directory name 
# entered by user really exists or not 
# -d flag will be true if the directory name 
# exists
dir="$1"
if [ ! -d "$dir" ]; then
  echo "WARNING: Directory doesn't exist: $dir" | mail -s "Archive WARNING" -- jcschill12@gmail.com
  exit 1
fi
    # if directory control will enter
    # creating a variable  filename to hold the 
    # new file name i.e. new_archive current date 
    # it will end with the extension ".tar.bz2".

stamp="$(date '+%Y-%m-%d_%H-%M-%S')"
session="session_${stamp}.txt"
filename="new_archive_${stamp}.tar.gz"

# Make session log
: > "$session"

# Option A: exclude known root-only paths and keep going on unreadables
# -C switches to / so tar paths are relative (no leading '/' warning)
# gzip compression to keep size down
if ! tar -C / --ignore-failed-read -czf "$filename" "${dir#/}" 2>>"$session"; then
  echo "Archive failed for $DIR. See session log." \
    | "$MUTT_BIN" -F "$MUTT_RC" -s "Archive FAILED" -a "$session" -- "jcschill12@gmail.com"
  exit 1
fi

# Send email with attachments
echo "Archive successfully created for $dir at $stamp." \
| "$MUTT_BIN" -F "$MUTT_RC" -s "Archive Successful" -a "$filename" -a "$session" -- "jcschill12@gmail.com"

echo "Done. Sent email with $filename and $session"