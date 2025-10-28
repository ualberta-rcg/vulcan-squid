<img src="https://www.ualberta.ca/en/toolkit/media-library/homepage-assets/ua_logo_green_rgb.png" alt="University of Alberta Logo" width="50%" />

# Warewulf Slurmd Node Image

[![CI/CD](https://github.com/ualberta-rcg/warewulf-slurmd/actions/workflows/deploy-warewulf-slurmd.yml/badge.svg)](https://github.com/ualberta-rcg/warewulf-slurmd/actions/workflows/deploy-warewulf-slurmd.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/rkhoja/warewulf-slurmd?style=flat-square)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

**Maintained by:** Rahim Khoja ([khoja1@ualberta.ca](mailto:khoja1@ualberta.ca)) & Karim Ali ([kali2@ualberta.ca](mailto:kali2@ualberta.ca))

## 🧰 Description

This repository contains a hardened **Slurm compute node image** based on Ubuntu 24.04, built into a Docker container that is **Warewulf-compatible** and deployable on bare metal.

It's primarily used for imaging and provisioning Slurm compute nodes using [Warewulf 4](https://warewulf.org) in high-performance computing clusters. The image includes the full Slurm daemon stack and CIS security hardening using the SCAP Security Guide.

The image is automatically built and pushed to Docker Hub using GitHub Actions whenever changes are pushed to the `latest` branch.

## 📦 Docker Image

**Docker Hub:** [rkhoja/warewulf-slurmd:latest](https://hub.docker.com/r/rkhoja/warewulf-slurmd)

```bash
docker pull rkhoja/warewulf-slurmd:latest
```

## 🏗️ What's Inside

This container includes:

* **Slurm 24.11+** (installed from custom DEB packages)
* **Slurm daemon** (`slurmd`) and client tools
* **Optional kernel installation** with configurable version
* **Optional NVIDIA driver support** (requires kernel installation)
* SSH, networking tools, monitoring utilities, debugging tools
* SCAP CIS Level 2 hardening (automatically applied)
* Systemd-based boot compatible with Warewulf PXE deployments
* Pre-created `wwuser` (UID/GID 1001) and `slurm` (UID/GID 999) users
* `changeme` root password (change in production!)

**Slurm** ([docs](https://slurm.schedmd.com/)) is ready for integration with existing Slurm clusters.

## 🚀 Build Options

The image supports several build-time configurations:

### **Kernel Installation**
- **With Kernel** (default): Installs specific Linux kernel version with headers and modules
- **No Kernel**: Skips kernel installation for use with host kernel or different kernel management

### **NVIDIA Support**
- **Enabled**: Installs NVIDIA drivers (requires kernel installation)
- **Disabled**: No NVIDIA components (faster builds, smaller images)

### **Slurm Version**
- **Latest**: Automatically detects and uses latest stable Slurm release
- **Specific**: Override with exact version (e.g., `24-11-6-1`)

### **Autologin & Firstboot**
- **Console Autologin**: Optional root autologin for debugging
- **Firstboot Service**: Optional Ansible playbook execution on first boot

## 🏷️ Docker Tags

Images are tagged with a descriptive naming scheme:

**With Kernel + NVIDIA:**
```bash
u24-6.8.0-31-slurm-24.11.6-1-nv570.148
# Ubuntu 24.04 + Kernel 6.8.0-31 + Slurm 24.11.6-1 + NVIDIA 570.148
```

**With Kernel Only:**
```bash
u24-6.8.0-31-slurm-24.11.6-1
# Ubuntu 24.04 + Kernel 6.8.0-31 + Slurm 24.11.6-1
```

**No Kernel:**
```bash
slurm-24.11.6-1
# Slurm 24.11.6-1 only (no kernel, no NVIDIA)
```

## 🛠️ GitHub Actions - CI/CD Pipeline

This project includes a GitHub Actions workflow: `.github/workflows/deploy-warewulf-slurmd.yml`.

### 🔄 What It Does

* Builds the Docker image from the `Dockerfile` with configurable options
* Automatically detects latest Slurm and kernel versions
* Generates appropriate Docker tags based on configuration
* Logs into Docker Hub using stored GitHub Secrets
* Pushes the image with descriptive tagging

### 🎛️ Build Configuration Options

The GitHub Actions workflow provides several build-time options that you can configure when manually triggering the build:

![GitHub Actions Build Options](slurmd-actions.png)

**Available Options:**
- **Kernel Installation**: Choose whether to include a specific Linux kernel
- **NVIDIA Support**: Enable/disable NVIDIA driver installation
- **Slurm Version**: Select specific Slurm version or use latest
- **Console Autologin**: Enable root autologin for debugging
- **Firstboot Service**: Enable Ansible playbook execution on first boot

### 🍴 Forking for Custom Versions

**Important:** If you want to customize this image for your own environment or requirements, please **fork this repository** rather than using it directly. This allows you to:

- Modify build parameters for your specific needs
- Add custom packages or configurations
- Maintain your own version control
- Customize the CI/CD pipeline for your infrastructure

Most of the information needed to get started is already documented in this README, including the required GitHub Secrets setup and workflow configuration.

### ✅ Setting Up GitHub Secrets

To enable pushing to your Docker Hub:

1. Go to your fork's GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. Add the following:

   * `DOCKER_HUB_REPO` → your Docker Hub repo. In this case: *rkhoja/warewulf-slurmd*
   * `DOCKER_HUB_USER` → your Docker Hub username
   * `DOCKER_HUB_TOKEN` → create a [Docker Hub access token](https://hub.docker.com/settings/security)

### 🚀 Manual Trigger & Auto-Build

* **Manual**: Run the workflow from the **Actions** tab with **Run workflow** (enabled via `workflow_dispatch`)
* **Automatic**: Any push to the `latest` branch triggers the CI/CD pipeline

**Recommended branching model:**
```bash
git checkout latest
git merge main
git push origin latest
```

## 🧪 How To Use This Image with Warewulf 4

Once you have Warewulf 4 setup on your control node:

```bash
# Import with kernel and NVIDIA support
wwctl image import --build --force docker://rkhoja/warewulf-slurmd:u24-6.8.0-31-slurm-24.11.6-1-nv570.148 slurmd-gpu

# Import with kernel only (no NVIDIA)
wwctl image import --build --force docker://rkhoja/warewulf-slurmd:u24-6.8.0-31-slurm-24.11.6-1 slurmd-cpu

# Import without kernel (use host kernel)
wwctl image import --build --force docker://rkhoja/warewulf-slurmd:slurm-24.11.6-1 slurmd-minimal
```

### Warewulf Configuration

The image includes a firstboot service that can run Ansible playbooks for post-deployment configuration. Place your playbooks in `/etc/ansible/playbooks/*.yaml` on the deployed nodes.

## 🤝 Support

Many Bothans died to bring us this information. This project is provided as-is, but reasonable questions may be answered based on my coffee intake or mood. ;)

Feel free to open an issue or email **[khoja1@ualberta.ca](mailto:khoja1@ualberta.ca)** or **[kali2@ualberta.ca](mailto:kali2@ualberta.ca)** for U of A related deployments.

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
