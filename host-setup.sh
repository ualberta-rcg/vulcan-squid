#!/bin/bash

# Host Setup Script for Squid Proxy on HPC Cluster
# Run this on each node before deploying Squid

set -e

echo "🔧 Setting up Squid user and directories on host..."

# Create Squid user and group with specific UID/GID to match container
if ! id -u squid >/dev/null 2>&1; then
    echo "Creating squid user with UID/GID 3128:3128..."
    useradd -r -s /bin/false -d /var/lib/squid -c "Squid proxy" -u 3128 -g 3128 squid
else
    echo "Squid user already exists"
    # Check if UID/GID matches container requirements
    CURRENT_UID=$(id -u squid)
    CURRENT_GID=$(id -g squid)
    if [ "$CURRENT_UID" != "3128" ] || [ "$CURRENT_GID" != "3128" ]; then
        echo "⚠️  Warning: Squid user UID/GID ($CURRENT_UID:$CURRENT_GID) doesn't match container (3128:3128)"
        echo "You may need to recreate the user or adjust container security context"
    fi
fi

# Create necessary directories
echo "Creating Squid directories..."
mkdir -p /var/lib/squid/{cache,spool,logs}
mkdir -p /var/lib/squid/cache/{00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F}
mkdir -p /var/lib/squid/cache/{10,11,12,13,14,15,16,17,18,19,1A,1B,1C,1D,1E,1F}

# Set proper ownership and permissions
chown -R 3128:3128 /var/lib/squid
chmod -R 755 /var/lib/squid

echo "✅ Host setup complete!"
echo "Squid user: $(id squid)"
echo "Directories created:"
ls -la /var/lib/squid/
