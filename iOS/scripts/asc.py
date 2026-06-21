#!/usr/bin/env python3
"""Minimal App Store Connect API client (ES256 JWT, stdlib + cryptography).

Usage:
  python3 asc.py GET  /v1/apps
  python3 asc.py GET  '/v1/bundleIds?filter[identifier]=com.playground.pomodoro.ios'
  python3 asc.py POST /v1/apps '<json-body>'

Auth via env (with sane defaults baked in):
  ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH
"""
import json
import os
import sys
import time
import urllib.request
import urllib.error

from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.asymmetric import ec, utils

KEY_ID = os.environ.get("ASC_KEY_ID", "7MA4UKCB75")
ISSUER_ID = os.environ.get("ASC_ISSUER_ID", "6d677e1f-d1c8-4e3c-a5e5-67ab671d8942")
KEY_PATH = os.environ.get(
    "ASC_KEY_PATH",
    os.path.expanduser(f"~/.appstoreconnect/private_keys/AuthKey_{KEY_ID}.p8"),
)
BASE = "https://api.appstoreconnect.apple.com"


def _b64url(data: bytes) -> str:
    import base64
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def make_jwt() -> str:
    with open(KEY_PATH, "rb") as f:
        key = serialization.load_pem_private_key(f.read(), password=None)
    header = {"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}
    now = int(time.time())
    payload = {"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"}
    signing_input = f"{_b64url(json.dumps(header).encode())}.{_b64url(json.dumps(payload).encode())}".encode()
    der = key.sign(signing_input, ec.ECDSA(hashes.SHA256()))
    r, s = utils.decode_dss_signature(der)
    sig = r.to_bytes(32, "big") + s.to_bytes(32, "big")
    return f"{signing_input.decode()}.{_b64url(sig)}"


def call(method: str, path: str, body=None):
    url = path if path.startswith("http") else BASE + path
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {make_jwt()}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read().decode()
            return resp.status, (json.loads(raw) if raw else {})
    except urllib.error.HTTPError as e:
        raw = e.read().decode()
        try:
            return e.code, json.loads(raw)
        except Exception:
            return e.code, {"raw": raw}


def main():
    method = sys.argv[1].upper()
    path = sys.argv[2]
    body = json.loads(sys.argv[3]) if len(sys.argv) > 3 else None
    status, payload = call(method, path, body)
    print(f"HTTP {status}", file=sys.stderr)
    print(json.dumps(payload, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
