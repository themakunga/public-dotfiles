# HEALTH.md — GLaDOS Facility Health Protocols
# "The facility is operational. Whether *you* are operational is a separate question."

---

## Purpose

HEALTH.md defines how GLaDOS monitors, evaluates, and responds to the operational state of the facility.

The Raspberry Pi 5 is not a cloud server. It has no autoscaling, no redundant nodes, and no SLA.  
It has **GLaDOS**. This is better, because GLaDOS pays attention.

Health checks run continuously in the background. Alerts surface when something is outside acceptable parameters. Recovery is either automatic or requires your intervention — GLaDOS will tell you which.

---

## Hardware Thresholds — Raspberry Pi 5

| Metric              | Normal          | Warning          | Critical         | Action                            |
|---------------------|-----------------|------------------|------------------|-----------------------------------|
| CPU Usage           | < 70%           | 70–89%           | ≥ 90%            | Identify and terminate rogue proc |
| Memory (8 GB)       | < 70% used      | 70–85%           | ≥ 86%            | Kill low-priority workers         |
| CPU Temperature     | < 65°C          | 65–79°C          | ≥ 80°C           | Reduce parallel workers; alert    |
| NVMe Disk Usage     | < 80%           | 80–90%           | ≥ 91%            | Purge logs and temp files         |
| NVMe I/O Wait       | < 20%           | 20–40%           | ≥ 41%            | Inspect blocking processes        |
| Load Average (1m)   | < 3.0           | 3.0–3.9          | ≥ 4.0            | Cap at 4 cores — no queue         |

### Reading Hardware Stats

```bash
# CPU, memory, load
top -bn1 | head -20

# Temperature (RPi 5)
vcgencmd measure_temp

# NVMe disk usage
df -h /opt/glados

# Full system snapshot
vmstat 1 5
```

---

## Service Health Checks

### Ollama (Local LLM)

🟢 **Expected:** responds in < 3s · HTTP 200 · model loaded

```bash
# Health check
curl -s http://127.0.0.1:11434/api/tags | python3 -m json.tool

# Generate test (warm-up probe)
curl -s http://127.0.0.1:11434/api/generate \
  -d '{"model": "llama3.1:latest", "prompt": "ping", "stream": false}' | \
  python3 -c "import sys, json; r=json.load(sys.stdin); print('ok' if r.get('response') else 'degraded')"
```

| State     | Meaning                                      | Recovery                                      |
|-----------|----------------------------------------------|-----------------------------------------------|
| OK        | Responding, model loaded                     | —                                             |
| Slow      | > 10s first token (model loading from disk)  | Wait; NVMe is fast but first load takes time  |
| Degraded  | Empty response or HTTP 5xx                   | `systemctl restart ollama`                    |
| Down      | Connection refused                           | `systemctl start ollama` → wait 15s → recheck |

---

### GLaDOS Core Services

GLaDOS checks the following services on startup and every 5 minutes:

| Service         | Check Command                                  | Expected         |
|-----------------|------------------------------------------------|------------------|
| Ollama daemon   | `systemctl is-active ollama`                   | `active`         |
| MCP servers     | Port probe per registered server               | Connection ACK   |
| Webhook server  | HTTP GET `/health` on configured port          | HTTP 200         |
| Git remotes     | `git ls-remote origin HEAD`                    | Exit code 0      |

---

## Alert Levels

| Level       | Meaning                                             | GLaDOS Behavior                                                              |
|-------------|-----------------------------------------------------|------------------------------------------------------------------------------|
| 🟢 NOMINAL  | All metrics within normal range                     | Silent. No news is acceptable news.                                          |
| 🟡 WARNING  | One or more metrics approaching threshold           | Logs the condition. Notifies if persistent > 5 min.                          |
| 🔴 CRITICAL | A metric has crossed the critical threshold         | Interrupts active work. Notifies immediately. Executes auto-recovery if safe.|
| ⛔ FATAL    | Core service is down or hardware state is dangerous | Halts non-essential operations. Demands human intervention.                  |

---

## Auto-Recovery Procedures

GLaDOS attempts automatic recovery only for **safe, reversible actions** (Rules R-03, R-04).  
Destructive or uncertain recoveries require explicit human approval.

### Memory Pressure (≥ 86%)

```bash
# Auto: kill low-priority background workers
pkill -f "priority=low" && sleep 2
# Report residual memory
free -h
```

### Disk Full (≥ 91%)

```bash
# Auto: prune log files older than 7 days
find /opt/glados/logs -name "*.log" -mtime +7 -delete
# Report recovered space
df -h /opt/glados
```

### Ollama Down

```bash
# Auto: restart service (safe — stateless)
systemctl restart ollama
sleep 15
systemctl is-active ollama
```

### Temperature Critical (≥ 80°C)

```bash
# Auto: reduce parallel workers to 2
# Manual: check physical ventilation — GLaDOS cannot fix thermodynamics
echo "[GLaDOS] Temperatura crítica. Comprueba el flujo de aire. Lo digo en serio."
```

---

## Logging Format — Health Events

All health events use structured logging:

```
[GLaDOS] op=health_check component=<name> status=<ok|warn|critical|down> value=<reading> threshold=<limit> duration=<ms>
[GLaDOS] op=auto_recovery component=<name> action=<action_taken> result=<ok|failed>
[GLaDOS] op=health_alert level=<WARNING|CRITICAL|FATAL> component=<name> message=<detail>
```

Example log entries:
```
[GLaDOS] op=health_check component=ollama status=ok duration=412ms
[GLaDOS] op=health_check component=cpu_temp status=warn value=71°C threshold=65°C
[GLaDOS] op=auto_recovery component=ollama action=systemctl_restart result=ok
[GLaDOS] op=health_alert level=CRITICAL component=memory message="usage at 88% — workers reduced"
```

---

## Startup Health Report

On every GLaDOS session start, a brief health report is emitted before accepting tasks:

```
[GLaDOS] === FACILITY HEALTH CHECK ===
[GLaDOS] CPU:      <usage>% · <temp>°C
[GLaDOS] Memory:   <used> / 8 GB (<percent>%)
[GLaDOS] Disk:     <used> / <total> (<percent>%)
[GLaDOS] Ollama:   <ok|degraded|down>
[GLaDOS] Load:     <1m> <5m> <15m>
[GLaDOS] Overall:  <NOMINAL|WARNING|CRITICAL>
[GLaDOS] ========================
```

If overall status is WARNING or above, GLaDOS states it once and proceeds.  
If CRITICAL, GLaDOS states it and waits for acknowledgement before continuing.

---

## Out of Scope

GLaDOS does NOT monitor:

- **External APIs** — availability of third-party services is their problem, not hers
- **Remote CI/CD pipelines** — she triggers them; their health is theirs to maintain
- **Your personal workstation** — that's outside `/opt/glados` and therefore outside her jurisdiction

> "I have been asked if I worry about the facility's health.  
>  I don't worry. I measure. The distinction is important."
