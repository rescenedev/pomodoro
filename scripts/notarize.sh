#!/bin/bash
# Notarizes and staples dist/Pomodoro.dmg.
#
# One-time setup (stores an App Store Connect API key in the keychain):
#   xcrun notarytool store-credentials pomodoro-notary \
#     --key ~/.appstoreconnect/private_keys/AuthKey_XXXXXXXXXX.p8 \
#     --key-id XXXXXXXXXX \
#     --issuer <your-issuer-uuid>
#
# Then just run: scripts/notarize.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DMG="$ROOT/dist/Pomodoro.dmg"
PROFILE="${NOTARY_PROFILE:-pomodoro-notary}"

[ -f "$DMG" ] || { echo "Missing $DMG — run scripts/package-dmg.sh first."; exit 1; }

echo "==> Submitting for notarization (profile: $PROFILE)…"
xcrun notarytool submit "$DMG" --keychain-profile "$PROFILE" --wait

echo "==> Stapling ticket to DMG…"
xcrun stapler staple "$DMG"
xcrun stapler validate "$DMG"

echo "==> Notarized & stapled: $DMG"
