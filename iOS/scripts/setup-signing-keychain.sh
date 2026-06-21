#!/bin/bash
# Creates a dedicated signing keychain (password chosen by YOU) and imports the
# Apple Distribution identity into it, configured so codesign can use it without
# any GUI prompt. This sidesteps the unknown-password "build" keychain.
#
# Usage:  bash setup-signing-keychain.sh '<your-chosen-keychain-password>'
set -euo pipefail

KC_PASS="${1:?usage: setup-signing-keychain.sh <new-keychain-password>}"
SIGN="/Users/zihado/work/playground/watch/hiragana/build/signing"
KC="$HOME/Library/Keychains/pomodoro-signing.keychain-db"
LOGIN="$HOME/Library/Keychains/login.keychain-db"
OPENSSL=/usr/bin/openssl
P12=/tmp/pomodoro-dist.p12
IDENTITY="Apple Distribution: Seongil Park (589U6DQJN8)"

echo "1/6 packaging identity into a p12…"
"$OPENSSL" pkcs12 -export \
  -inkey "$SIGN/dist.key" \
  -in "$SIGN/dist.pem" \
  -out "$P12" \
  -passout pass:"$KC_PASS" \
  -name "$IDENTITY"

echo "2/6 creating keychain (your password)…"
security delete-keychain "$KC" 2>/dev/null || true
security create-keychain -p "$KC_PASS" "$KC"
security set-keychain-settings "$KC"            # no auto-lock timeout
security unlock-keychain -p "$KC_PASS" "$KC"

echo "3/6 importing identity…"
security import "$P12" -k "$KC" -P "$KC_PASS" -A -T /usr/bin/codesign -T /usr/bin/security

echo "4/6 authorizing codesign (partition list)…"
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KC_PASS" "$KC" >/dev/null

echo "5/6 updating keychain search list (drops the unknown 'build' keychain)…"
security list-keychains -d user -s "$KC" "$LOGIN"

echo "6/6 cleanup…"
rm -f "$P12"

echo
echo "Done. Signing identities visible to codesign:"
security find-identity -v -p codesigning "$KC"
