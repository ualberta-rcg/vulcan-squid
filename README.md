# Vulcan Squid Proxy

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A production-ready Kubernetes DaemonSet deployment for Squid proxy on HPC clusters. This configuration provides high-performance caching with peer coordination for research computing workloads, optimized for CVMFS and scientific data repositories.

## Overview

Vulcan Squid is a Kubernetes-native Squid proxy deployment designed for high-performance computing environments. It runs as a DaemonSet with host networking, providing stable IP addresses and coordinated caching across compute nodes.

### Key Features

- **DaemonSet Architecture**: One Squid instance per node with stable IP addresses
- **Peer Cache Clustering**: Automatic peer discovery and cache coordination across nodes
- **High-Performance Caching**: 100GB disk cache + 24GB RAM cache per node
- **Research-Optimized**: Pre-configured refresh patterns for CVMFS and scientific data
- **Network Security**: Domain whitelisting and comprehensive ACL rules
- **Production-Ready**: Health checks, resource limits, and security hardening
- **Zero-Downtime Updates**: Rolling update strategy with pod lifecycle management

## Architecture

### Components

- **DaemonSet** (`squid.yaml`): Main deployment with host networking
- **Namespace** (`squid-namespace.yaml`): Isolated namespace with security policies
- **ConfigMaps**:
  - `entrypoint`: Core Squid configuration and ACLs
  - `cache-config`: High-performance caching settings
  - `squid-whitelist`: Domain whitelisting for research environments
- **Host Setup** (`host-setup.sh`): User and directory preparation script

### Network Configuration

- **Host Networking**: Pods bind directly to host ports for stable IPs
- **Peering**: 5-node peer cluster (172.26.92.2-6) with cache sibling relationships
- **Proxy Port**: 3128 (standard Squid port)

### Cache Configuration

```
Disk Cache: 100GB per node (aufs format, 32 dirs, 512 subdirs)
Memory Cache: 24GB RAM for hot objects
Workers: 4 concurrent worker processes
Replacement Policies: LFUDA (disk), GDSF (memory)
Max Object Size: 20GB
```

## Prerequisites

- Kubernetes cluster with DaemonSet support
- Nodes with sufficient resources:
  - Minimum: 8GB RAM, 1 CPU, 10GB storage
  - Recommended: 32GB RAM, 4 CPU, 100GB storage
- Root access for host setup script execution
- Docker image: `ubuntu/squid:latest`

## Installation

### 1. Host Preparation

Run the setup script on each compute node:

```bash
sudo ./host-setup.sh
```

This creates:
- Squid user/group (UID/GID 3128:3128)
- Cache directories at `/var/lib/squid`
- Proper permissions for container access

### 2. Kubernetes Deployment

Apply the manifests in order:

```bash
kubectl apply -f squid-namespace.yaml
kubectl apply -f squid_entrypoint.yaml
kubectl apply -f squid_cache-config.yaml
kubectl apply -f squid-whitelist.yaml
kubectl apply -f squid.yaml
```

### 3. Verification

Check pod status:

```bash
kubectl get pods -n squid-standard
kubectl logs -n squid-standard -l app=squid
```

## Configuration

### Peer Discovery

Peers are configured statically in `peer-discovery.sh`. To modify the peer list, edit:

```bash
# In squid_entrypoint.yaml - peer-discovery.sh
PEERS="172.26.92.2 172.26.92.3 172.26.92.4 172.26.92.5 172.26.92.6"
```

### Cache Size

Adjust cache size in `squid_cache-config.yaml`:

```squid
cache_dir aufs /var/lib/squid 100000 32 512  # 100GB
cache_mem 24576 MB                           # 24GB RAM
```

### Resource Limits

Modify resource requests/limits in `squid.yaml`:

```yaml
resources:
  requests:
    memory: "8Gi"
    cpu: "1000m"
  limits:
    memory: "32Gi"
    cpu: "4000m"
```

## Usage

### Configure Clients

Point your applications to use the Squid proxy:

```bash
export http_proxy=http://<node-ip>:3128
export https_proxy=http://<node-ip>:3128
export HTTP_PROXY=http://<node-ip>:3128
export HTTPS_PROXY=http://<node-ip>:3128
```

### Verify Proxy Access

```bash
curl -I --proxy http://<node-ip>:3128 http://www.google.com
```

### Test CVMFS Access

```bash
export http_proxy=http://172.26.92.2:3128
curl http://cvmfs-stratum-one.cern.ch/cvmfs/
```

## Monitoring

### Check Cache Status

```bash
# View cache statistics
kubectl exec -n squid-standard <pod-name> -- squidclient mgr:info

# View cache objects
kubectl exec -n squid-standard <pod-name> -- squidclient mgr:objects
```

### Pod Logs

```bash
# Stream logs
kubectl logs -n squid-standard -l app=squid -f

# Check startup sequence
kubectl logs -n squid-standard <pod-name> | grep -i "peer\|cache\|config"
```

### Resource Usage

```bash
kubectl top pods -n squid-standard
```

## Whitelisting

The deployment includes comprehensive whitelisting for:

- **Academic Institutions**: University networks and research centers
- **Scientific Repositories**: CERN, SLAC, CANFAR, etc.
- **ML/AI Platforms**: Hugging Face, OpenAI, Weights & Biases
- **Package Managers**: PyPI, CRAN, container registries
- **Cloud Services**: AWS, GCP, Kaggle

To add domains, edit `squid-whitelist.yaml`:

```squid
.example.com
.subdomain.example.org
```

## Troubleshooting

### Pods Not Starting

```bash
# Check events
kubectl describe pod -n squid-standard <pod-name>

# Check permissions
kubectl exec -n squid-standard <pod-name> -- ls -la /var/lib/squid
```

### Cache Issues

```bash
# Verify cache directory
kubectl exec -n squid-standard <pod-name> -- df -h /var/lib/squid

# Clear cache
kubectl exec -n squid-standard <pod-name> -- rm -rf /var/lib/squid/cache/*
```

### Peer Connectivity

```bash
# Check peer configuration
kubectl exec -n squid-standard <pod-name> -- cat /tmp/99-peers.conf

# Test peer reachability
kubectl exec -n squid-standard <pod-name> -- ping -c 3 172.26.92.3
```

## Performance Tuning

For HPC workloads, consider:

1. **Increase cache sizes** for nodes with more storage
2. **Adjust workers** based on CPU cores: `workers N`
3. **Tune timeouts** for large file transfers
4. **Monitor disk I/O** and adjust cache_dir layout

## Security

- **Read-only root filesystem**: Prevents container escape
- **Non-root user**: Runs as UID 3128 (Squid user)
- **Minimal capabilities**: Only NET_BIND_SERVICE and SYS_RESOURCE
- **Network ACLs**: Whitelist-based access control
- **Security context**: Seccomp and AppArmor profiles

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors

University of Alberta Research Computing Group - 2025

## Acknowledgments

- Built for the Vulcan HPC cluster
- Optimized for CVMFS caching
- Tested with CERN, CANFAR, and research data repositories