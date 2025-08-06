#!/bin/bash
set -e

# Variables
NEW_VERSION=17
OLD_VERSION=16

echo "=== Updating APT and installing PostgreSQL $NEW_VERSION.x ==="

# Update system
sudo apt update -y
sudo apt install -y wget gnupg2 lsb-release

# Add PostgreSQL repo
wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | \
  sudo tee /etc/apt/sources.list.d/pgdg.list

# Install new version
sudo apt update -y
sudo apt install -y postgresql-$NEW_VERSION

echo "=== Stopping old PostgreSQL $OLD_VERSION cluster ==="
sudo systemctl stop postgresql@$OLD_VERSION-main || true

echo "=== Upgrading data from $OLD_VERSION to $NEW_VERSION ==="
sudo pg_upgradecluster $OLD_VERSION main

echo "=== Starting PostgreSQL $NEW_VERSION cluster ==="
sudo systemctl start postgresql@$NEW_VERSION-main

echo "=== Disabling old $OLD_VERSION cluster ==="
sudo pg_dropcluster $OLD_VERSION main --stop

echo "=== Checking installed version ==="
psql --version

echo "=== PostgreSQL upgrade to $NEW_VERSION.x complete! ==="
