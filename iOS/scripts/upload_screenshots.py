#!/usr/bin/env python3
"""Upload App Store screenshots for one localization + display type.

Usage:
  ASC_KEY_ID=V66W3GC2GU PYTHONPATH=scripts python3 scripts/upload_screenshots.py \
      <appStoreVersionLocalizationId> <displayType> <file1.png> <file2.png> ...
"""
import hashlib
import os
import sys
import urllib.request

import asc


def reserve(set_id, name, size):
    body = {
        "data": {
            "type": "appScreenshots",
            "attributes": {"fileName": name, "fileSize": size},
            "relationships": {
                "appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": set_id}}
            },
        }
    }
    return asc.call("POST", "/v1/appScreenshots", body)


def put_bytes(op, data):
    url = op["url"]
    chunk = data[op["offset"]: op["offset"] + op["length"]]
    req = urllib.request.Request(url, data=chunk, method=op["method"])
    for h in op.get("requestHeaders", []):
        req.add_header(h["name"], h["value"])
    with urllib.request.urlopen(req) as resp:
        return resp.status


def main():
    loc_id, display_type = sys.argv[1], sys.argv[2]
    files = sys.argv[3:]

    # find or create the screenshot set for this display type
    st, payload = asc.call("GET", f"/v1/appStoreVersionLocalizations/{loc_id}/appScreenshotSets")
    set_id = None
    for s in payload.get("data", []):
        if s["attributes"]["screenshotDisplayType"] == display_type:
            set_id = s["id"]
            break
    if not set_id:
        st, payload = asc.call("POST", "/v1/appScreenshotSets", {
            "data": {
                "type": "appScreenshotSets",
                "attributes": {"screenshotDisplayType": display_type},
                "relationships": {
                    "appStoreVersionLocalization": {
                        "data": {"type": "appStoreVersionLocalizations", "id": loc_id}
                    }
                },
            }
        })
        if st not in (200, 201):
            print("set create failed", st, payload)
            sys.exit(1)
        set_id = payload["data"]["id"]
    print("set:", set_id, display_type)

    for f in files:
        data = open(f, "rb").read()
        name = os.path.basename(f)
        st, payload = reserve(set_id, name, len(data))
        if st not in (200, 201):
            print("reserve failed", name, st, payload)
            sys.exit(1)
        sid = payload["data"]["id"]
        ops = payload["data"]["attributes"]["uploadOperations"]
        for op in ops:
            put_bytes(op, data)
        md5 = hashlib.md5(data).hexdigest()
        st, payload = asc.call("PATCH", f"/v1/appScreenshots/{sid}", {
            "data": {"type": "appScreenshots", "id": sid,
                     "attributes": {"uploaded": True, "sourceFileChecksum": md5}}
        })
        print(f"  {name}: commit HTTP {st} ({'ok' if st == 200 else payload})")


if __name__ == "__main__":
    main()
