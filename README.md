# vulcan-squid

Kubernetes Squid proxy deployment for HPC clusters. Provides high-performance caching with peer coordination for CVMFS and research computing workloads at the University of Alberta.

## 🧰 Description

DaemonSet-based Squid proxy deployment optimized for the Vulcan HPC cluster. Each compute node runs a Squid instance with host networking for stable IP addresses and coordinated cache clustering across nodes.

## 🚀 Quick Start

### 1. Setup host directories

Run on each compute node:

```bash
sudo ./host-setup.sh
```

### 2. Deploy to Kubernetes

```bash
kubectl apply -f squid-namespace.yaml
kubectl apply -f squid_entrypoint.yaml
kubectl apply -f squid_cache-config.yaml
kubectl apply -f squid-whitelist.yaml
kubectl apply -f squid.yaml
```

### 3. Verify deployment

```bash
kubectl get pods -n squid-standard
kubectl logs -n squid-standard -l app=squid
```

## 📦 What's Inside

- **Squid 5.x** (from ubuntu/squid:latest)
- **100GB disk cache** per node (aufs format, 32 dirs, 512 subdirs)
- **24GB RAM cache** for hot objects
- **Peer clustering** across 5 compute nodes (172.26.92.2-6)
- **Domain whitelisting** for research networks (CERN, universities, scientific repos)
- **CVMFS-optimized** refresh patterns
- **Security hardening** with read-only rootfs, non-root user, minimal capabilities

## 🏗️ Components

- `squid.yaml` - DaemonSet deployment configuration
- `squid_entrypoint.yaml` - Main Squid config and peer discovery
- `squid_cache-config.yaml` - Cache optimization settings
- `squid-whitelist.yaml` - Domain whitelist for research networks
- `squid-namespace.yaml` - Kubernetes namespace
- `host-setup.sh` - Host directory setup script

## ⚙️ Configuration

Peering is configured for the Vulcan cluster nodes (172.26.92.2-6). To modify the peer list, edit `PEERS` in `squid_entrypoint.yaml`:

```bash
PEERS="172.26.92.2 172.26.92.3 172.26.92.4 172.26.92.5 172.26.92.6"
```

## 📖 Usage

Configure clients to use the proxy:

```bash
export http_proxy=http://<node-ip>:3128
export https_proxy=http://<node-ip>:3128
```

Test CVMFS access:

```bash
curl http://cvmfs-stratum-one.cern.ch/cvmfs/
```

## 🤝 Support

This project is provided as-is. Feel free to open an issue or email for U of A related deployments.

## 📜 License

MIT License - see [LICENSE](LICENSE) file.

**Maintained by:** University of Alberta Research Computing Group
