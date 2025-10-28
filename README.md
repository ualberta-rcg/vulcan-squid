<img src="https://www.ualberta.ca/en/toolkit/media-library/homepage-assets/ua_logo_green_rgb.png" alt="University of Alberta Logo" width="50%" />

# Squid Deployment for Vulcan HPC Cluster

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

**Maintained by:** Karim Ali ([kali2@ualberta.ca](mailto:kali2@ualberta.ca))

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


