# Problem 2 — Production troubleshooting (NGINX load-balancer VM)

Ubuntu 24.04, 64 GB disk, single role: **NGINX load balancer** to upstream app pools. Two incidents below.

Runnable scripts (run on the **load-balancer VM**, from this problem folder or with absolute path):

- [scripts/issue1-disk-triage.sh](scripts/issue1-disk-triage.sh)
- [scripts/issue2-nginx-upstream-triage.sh](scripts/issue2-nginx-upstream-triage.sh)

## Context

```mermaid
flowchart LR
  users[Clients]
  lb[NGINX LB VM 64GB]
  pool[App pool upstreams]
  users --> lb --> pool
```

---

## Issue 1 — Disk at 99%

### Who runs what

| Step | User | Host |
| --- | --- | --- |
| Triage | `ops` or `devops` with sudo | Load-balancer VM |
| Log rotate / cleanup | same | LB VM |
| Volume resize | `devops` + cloud console/IaC | AWS EC2/EBS |

### Procedure

```bash
sudo bash scripts/issue1-disk-triage.sh
```

### Expected output (abbreviated)

```text
=== Step 1: block vs inode usage ===
Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n1p1   64G   63G  1.0G  99% /

=== Step 3: NGINX log sizes ===
-rw-r----- 1 www-data adm  42G Nov 20 access.log
-rw-r----- 1 www-data adm  18G Nov 20 error.log
```

### Root causes matrix

| Cause | Clue in output | Impact | Recovery |
| --- | --- | --- | --- |
| Unrotated access logs | Huge `/var/log/nginx/*.log` | Writes fail; NGINX may refuse reload | `logrotate -f /etc/logrotate.d/nginx`; ship to central log store; truncate after copy |
| journald growth | `journalctl --disk-usage` &gt; 4G | Same | `journalctl --vacuum-size=500M`; cap `/etc/systemd/journald.conf` |
| Packed cores | `/var/crash` or `/var/lib/apport` | Disk full | Remove after RCA; fix upstream crash |
| Wrong mount growth | `du` shows `/opt` or `/var/lib/docker` | Service outage | Move workload or resize EBS |
| Inode exhaustion | `df -i` → IUse% ~100% | Cannot create files despite free blocks | Find dense dirs; purge cache/temp queues |
| NGINX body/proxy temp | `nginx -T` → `client_body_temp_path`, `proxy_temp_path` | Upload/proxy failures fill disk | Tune buffers; fix slow upstreams; clean old temps safely |
| NGINX proxy cache | `proxy_cache_path` with high `max_size` | Cache competes with OS | Set `max_size`, `inactive`, `min_free`; separate volume if needed |
| Deleted file still open | `lsof +L1` shows `(deleted)` | `df` high but `du` low | `nginx -s reopen` after logrotate; restart offender process |

### NGINX-focused checks (before global `du /`)

```bash
sudo nginx -T 2>&1 | grep -E 'access_log|error_log|proxy_cache_path|proxy_temp_path|client_body_temp_path'
sudo du -sh /var/log/nginx/* 2>/dev/null
sudo lsof +L1
sudo journalctl --disk-usage
```

### Manual commands (if script unavailable)

```bash
sudo df -h /
sudo du -xh /var/log/nginx | sort -h | tail
sudo logrotate -f /etc/logrotate.d/nginx
```

---

## Issue 2 — Intermittent 502 / 504

### Who runs what

| Step | User | Host |
| --- | --- | --- |
| Log analysis | on-call SRE | LB VM |
| Upstream fix | app team | app servers |
| Kernel/nginx tuning | platform | LB VM |

### Procedure

```bash
sudo bash scripts/issue2-nginx-upstream-triage.sh
```

### Expected output (patterns)

```text
=== Step 2: recent upstream errors ===
2026/11/20 14:02:11 [error] upstream timed out (110: Connection timed out) while reading response header, upstream: "http://10.0.1.15:8080/api"
2026/11/20 14:02:19 [error] connect() failed (111: Connection refused) while connecting to upstream

=== Step 4: file descriptor limit ===
1024
```

### Root causes matrix

| Cause | Clue | Impact | Recovery |
| --- | --- | --- | --- |
| FD exhaustion | low `ulimit -n`, high `ss -s` | Random 502 under load | Raise `worker_rlimit_nofile`, systemd `LimitNOFILE`, reload NGINX |
| Slow upstream | `timed out` in error.log | 504 to clients | Fix app latency; tune timeouts only after root fix |
| All backends down | `connection refused` | Hard outage | Restore healthy backend; verify health probe path |
| Bad deploy | errors start after release | Spike 5xx | Roll back upstream; keep LB config stable |

### NGINX checks

```bash
sudo nginx -t
sudo nginx -s reload
grep worker_connections /etc/nginx/nginx.conf
```

---

## Prevention (both issues)

- Centralize logs; alert disk **80%** and **5xx rate**.
- Prefer **managed ALB** when policy allows; VM LB only with automation for logs and patching.
