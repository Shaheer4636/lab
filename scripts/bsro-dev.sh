#!/usr/bin/env bash
set -euo pipefail

PATH="$PATH:/usr/sbin:/sbin"

if command -v apachectl >/dev/null 2>&1; then
  sudo apachectl -t
elif command -v apache2ctl >/dev/null 2>&1; then
  sudo apache2ctl -t
elif command -v httpd >/dev/null 2>&1; then
  sudo httpd -t
else
  echo "ERROR: no apache control binary found (apachectl/apache2ctl/httpd)"
  exit 1
fi
