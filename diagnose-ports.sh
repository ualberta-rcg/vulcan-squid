#!/bin/bash

# Port Diagnosis Script for Squid Proxy
# Run this on each node to check what's using ports 3128 and 3130

echo "🔍 Diagnosing port usage on node: $(hostname)"
echo "================================================"

echo "📊 Checking ports 3128 and 3130..."
netstat -tlnp | grep -E ':(3128|3130) ' || echo "No processes found on ports 3128/3130"

echo ""
echo "📊 Checking all listening ports..."
netstat -tlnp | grep LISTEN | head -20

echo ""
echo "📊 Checking for existing Squid processes..."
ps aux | grep squid | grep -v grep || echo "No Squid processes found"

echo ""
echo "📊 Checking for existing proxy services..."
ps aux | grep -i proxy | grep -v grep || echo "No proxy processes found"

echo ""
echo "📊 Checking Kubernetes services..."
kubectl get services -A | grep -E '(3128|3130|30000|30001|30002|30003)' || echo "No conflicting services found"

echo ""
echo "📊 Checking for any processes using port 3128..."
lsof -i :3128 2>/dev/null || echo "Port 3128 is free"

echo ""
echo "📊 Checking for any processes using port 3130..."
lsof -i :3130 2>/dev/null || echo "Port 3130 is free"
