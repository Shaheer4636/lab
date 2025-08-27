#!/usr/bin/env bash
set -euo pipefail
PATH="$PATH:/usr/sbin:/sbin"

echo "== PATH =="; echo "$PATH"
echo "== which binaries =="
which apachectl apache2ctl httpd || true

echo "== common locations =="
for p in \
  /usr/sbin/apachectl /usr/sbin/apache2ctl /usr/sbin/httpd \
  /usr/local/apache2/bin/apachectl \
  /opt/bitnami/apache2/bin/apachectl \
  /data/bsro/mnt/software/apache/bin/apachectl \
  /data/bsro/mnt/software/apache/bin/httpd
do [ -x "$p" ] && echo "FOUND $p"; done

echo "== services =="
(systemctl status httpd 2>/dev/null | head -n 5) || true
(systemctl status apache2 2>/dev/null | head -n 5) || true
