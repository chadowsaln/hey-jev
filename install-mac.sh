#!/bin/bash
# Hey Jev — one-shot installer for macOS (free OpenRouter patch)
# Paste this whole script into Terminal on your Mac and press Enter.
set -euo pipefail

REPO="https://github.com/chadowsaln/hey-jev.git"
DIR="$HOME/hey-jev"

echo "==> Checking macOS..."
[ "$(uname)" = "Darwin" ] || { echo "ERROR: run this on your Mac, not Linux."; exit 1; }

echo "==> Checking git..."
command -v git >/dev/null || {
  echo "git not found — installing Xcode Command Line Tools (a popup will appear)..."
  xcode-select --install || true
  echo "Accept the popup, then re-run this script."; exit 1
}

echo "==> Checking python3..."
command -v python3 >/dev/null || {
  echo "python3 not found — installing Xcode Command Line Tools..."
  xcode-select --install || true
  echo "Accept the popup, then re-run this script."; exit 1
}
python3 --version

echo "==> Cloning patched repo (free OpenRouter version)..."
if [ -d "$DIR/.git" ]; then
  git -C "$DIR" pull --ff-only
else
  git clone "$REPO" "$DIR"
fi
cd "$DIR"

echo "==> Creating virtualenv..."
[ -d .venv ] || python3 -m venv .venv
. .venv/bin/activate

echo "==> Installing dependencies (first run takes a few minutes)..."
pip install --upgrade pip
pip install -r requirements.txt
pip install py2app

echo "==> Building app..."
rm -rf build dist
python setup.py py2app -A

APP="dist/Hey Jev - Fish Audio.app"
[ -d "$APP" ] || { echo "ERROR: build failed — copy the output above and send it to me."; exit 1; }

echo "==> Opening app..."
open "$APP"

cat <<'MSG'

==================================================
 Done! The app is open.

 FIRST RUN:
 1) Grant Microphone + Accessibility when asked
    (System Settings > Privacy & Security if missing)
 2) Click the gear / settings in the app and paste:
    - OpenRouter key  -> https://openrouter.ai/keys
    - Fish Audio key   -> https://fish.audio  (free tier)
    (TypeSafe is NOT needed anymore)
 3) Mic icon → say "open spotify" to test.

 TEST WITHOUT MIC (run in Terminal):
   cd ~/hey-jev && .venv/bin/python siri.py --text "open spotify"
==================================================
MSG
