#!/bin/bash

# Host Setup Script for Squid Proxy on HPC Cluster
# Run this on each node before deploying Squid

set -e

echo "🔧 Setting up Squid user and directories on host..."

# Create Squid user and group
if ! id -u squid >/dev/null 2>&1; then
    echo "Creating squid user..."
    useradd -r -s /bin/false -d /var/lib/squid -c "Squid proxy" squid
else
    echo "Squid user already exists"
fi

# Create necessary directories
echo "Creating Squid directories..."
mkdir -p /var/lib/squid/{cache,spool,logs}
mkdir -p /var/lib/squid/cache/{00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F}
mkdir -p /var/lib/squid/cache/{10,11,12,13,14,15,16,17,18,19,1A,1B,1C,1D,1E,1F}

# Set proper ownership and permissions
chown -R squid:squid /var/lib/squid
chmod -R 755 /var/lib/squid

# Set up log rotation
cat > /etc/logrotate.d/squid << 'EOF'
/var/lib/squid/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 squid squid
    postrotate
        /bin/kill -USR1 $(cat /var/run/squid.pid 2>/dev/null) 2>/dev/null || true
    endscript
}
EOF

echo "✅ Host setup complete!"
echo "Squid user: $(id squid)"
echo "Directories created:"
ls -la /var/lib/squid/
