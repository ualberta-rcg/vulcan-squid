<img src="https://www.ualberta.ca/en/toolkit/media-library/homepage-assets/ua_logo_green_rgb.png" alt="University of Alberta Logo" width="50%" />

# Squid Deployment for Vulcan HPC Cluster

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

**Maintained by:** Karim Ali ([kali2@ualberta.ca](mailto:kali2@ualberta.ca))

## 🧰 Description

DaemonSet-based Squid proxy deployment for the Vulcan HPC cluster. Each Kubernetes node runs a Squid instance with host networking, providing stable IP addresses and peer cache coordination for CVMFS (CernVM File System).

This setup deploys Squid across all 5 Kubernetes nodes (172.26.92.2-6), where each node peers with the others to share cached content. CVMFS clients can use any of these node IPs for maximum availability and cache efficiency.

## 🚀 Quick Start

### 1. Setup host directories

Run on each Kubernetes node. The cache directory is typically mounted on its own partition for optimal performance:

```bash
sudo ./host-setup.sh
```

This creates the Squid user (UID/GID 3128:3128) and cache directory structure at `/var/lib/squid`.

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

- **Squid 5.x** (from `ubuntu/squid:latest`)
- **100GB disk cache** per node on host-mounted volume (aufs format, 32 dirs, 512 subdirs)
- **24GB RAM cache** for hot objects and metadata
- **4-worker process pool** for high concurrency
- **Peer clustering** across all 5 Kubernetes nodes (172.26.92.2-6) with automatic cache sharing as "siblings"
- **CVMFS-optimized refresh patterns** for long-term caching (1440 min TTL with 90% freshness)
- **Domain whitelisting** for research networks (CERN, universities, scientific repos, PyPI, Hugging Face, etc.)
- **Security hardening** with read-only rootfs, non-root user (UID 3128), minimal capabilities (NET_BIND_SERVICE, SYS_RESOURCE)

## 🏗️ Components

- `squid.yaml` - DaemonSet deployment configuration
- `squid_entrypoint.yaml` - Main Squid config and peer discovery
- `squid_cache-config.yaml` - Cache optimization settings
- `squid-whitelist.yaml` - Domain whitelist for research networks
- `squid-namespace.yaml` - Kubernetes namespace
- `host-setup.sh` - Host directory setup script

## 🏗️ Architecture

This deployment runs one Squid pod per Kubernetes node with host networking enabled. This provides:

- **Stable IP addresses**: Each node has a consistent IP (e.g., 172.26.92.2-6)
- **Peer cache clustering**: Squid instances communicate as "siblings" to share cached content
- **High availability**: CVMFS clients can connect to any of the 5 nodes
- **Host-mounted cache**: Cache data persists on the host filesystem (typically a dedicated partition)

When a CVMFS client requests data:
1. If the local node has it cached, it's served immediately
2. If not cached locally, the node queries peers for cached content
3. If peers have it, it's fetched from them (cache hierarchy)
4. Otherwise, the content is fetched from the upstream stratum server and cached

## ⚙️ Configuration

### Peer Discovery

Peering is configured for the Vulcan cluster nodes (172.26.92.2-6). Each Squid instance automatically discovers and connects to peers on other nodes at startup.

To modify the peer list, edit the `PEERS` variable in `squid_entrypoint.yaml`:

```bash
PEERS="172.26.92.2 172.26.92.3 172.26.92.4 172.26.92.5 172.26.92.6"
```

### Resource Limits

Default configuration:
- **Memory**: 8-32GB request/limit per pod
- **CPU**: 1-4 cores request/limit per pod
- **Cache**: 100GB disk cache (host-mounted), 24GB RAM cache

## 📖 Usage

### Configure CVMFS Clients

Provide all 5 node IPs to CVMFS for redundancy and load balancing:

```bash
export CVMFS_SQUID_LIST="http://172.26.92.2:3128|http://172.26.92.3:3128|http://172.26.92.4:3128|http://172.26.92.5:3128|http://172.26.92.6:3128"
```

Or configure in `/etc/cvmfs/default.local`:

```ini
CVMFS_SQUID_LIST="http://172.26.92.2:3128|http://172.26.92.3:3128|http://172.26.92.4:3128|http://172.26.92.5:3128|http://172.26.92.6:3128"
```

### Testing

Test proxy connectivity:

```bash
curl -v --proxy http://172.26.92.2:3128 http://www.google.com
```

Test CVMFS stratum access:

```bash
curl --proxy http://172.26.92.2:3128 http://cvmfs-stratum-one.cern.ch/cvmfs/
```

## 🤝 Support

Many Bothans died to bring us this information. This project is provided as-is, but reasonable questions may be answered based on my coffee intake or mood. ;)

Feel free to open an issue or email **[kali2@ualberta.ca](mailto:kali2@ualberta.ca)** for U of A related deployments.

## 📜 License

This project is released under the **MIT License** - one of the most permissive open-source licenses available.

**What this means:**
- ✅ Use it for anything (personal, commercial, whatever)
- ✅ Modify it however you want
- ✅ Distribute it freely
- ✅ Include it in proprietary software

**The only requirement:** Keep the copyright notice somewhere in your project.

That's it! No other strings attached. The MIT License is trusted by major projects worldwide and removes virtually all legal barriers to using this code.

**Full license text:** [MIT License](./LICENSE)

## 🧠 About University of Alberta Research Computing

The [Research Computing Group](https://www.ualberta.ca/en/information-services-and-technology/research-computing/index.html) supports high-performance computing, data-intensive research, and advanced infrastructure for researchers at the University of Alberta and across Canada.

We help design and operate compute environments that power innovation — from AI training clusters to national research infrastructure.


