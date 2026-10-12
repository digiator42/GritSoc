# GritSoc

Docker orchestration for the entire GritShield product stack. One repo, one
command, every service.

<img src="./badges/grit-philosophers.svg" width="960" alt="GritShield dining philosophers diagram" />

```bash
docker compose up --build
```

Then open:

| Service | URL | What it is |
|---|---|---|
| Admin Command Center | http://localhost:8000 | Platform UI + API (Postgres) |
| CyberFlow (logs-soc) console | http://localhost:8011 | Live SOC threat console |
| CyberFlow backend API | http://localhost:8010 | Log ingest + threat API |
| LuxShield console | http://localhost:8021 | XDP/WAF console |
| LuxShield backend API | http://localhost:8020 | Packet/DDoS manager |
| GritIRT console | http://localhost:8031 | Incident-response console |
| GritIRT backend API | http://localhost:8030 | Incident/playbook API |
| GritJira console | http://localhost:8041 | Issue tracker UI |
| GritJira backend API | http://localhost:8040 | Issue tracker API (Postgres) |

## Layout

This repo contains only Docker orchestration. It builds the sibling projects
under `..` (the shared workspace):

```
workspace/
├── admin-command-center/   # Rust + Postgres
├── logs-soc/               # CyberFlow: Rust backend + WASM frontend
├── LuxShield/              # Rust backend + WASM frontend
├── GritIRT/                # Rust backend + WASM frontend
├── GritJira/               # Rust backend + Next.js frontend
├── Gritshield/             # framework (path dep for SOC + GritJira backends)
├── Velo/                   # frontend framework (path dep for WASM frontends)
└── GritSoc/                # <- this repo (docker only)
```

Because the SOC/GritJira backends depend on `Gritshield` and the WASM frontends
depend on `Velo` by path, the compose build contexts point at the workspace root
(`..`) and rely on the workspace-root `.dockerignore` to keep the context small.
All siblings must be checked out alongside `GritSoc`.

## Ports

Host ports are assigned to avoid collisions (the per-repo composes both used
`8080` for their frontends):

| Host | Container | Service |
|---|---|---|
| 8000 | 8000 | admin-command-center |
| 8010 | 8010 | cyberflow-backend |
| 8011 | 80 | cyberflow-frontend |
| 8020 | 8020 | luxshield-backend |
| 8021 | 80 | luxshield-frontend |
| 8030 | 8030 | gritirt-backend |
| 8031 | 80 | gritirt-frontend |
| 8040 | 8040 | gritjira-backend |
| 8041 | 3000 | gritjira-frontend |

Postgres is internal-only on the compose network (not published).

## Configuration

Everything has a working default, so no `.env` is required. To customize, copy
`.env.example` to `.env` and edit (Postgres creds, API keys, JWT secret, sim
knobs). See `.env.example` for the full list.

## Notes

- `admin-command-center`, `logs-soc` backend, and `GritJira` persist to volumes
  (`pg-data`, `soc-data`, `irt-data`).
- GritJira's Next.js server proxies `/api/*` to `http://gritjira-backend:8040`
  on the compose network (baked at image build via `GRITJIRA_API_URL`).
- The WASM consoles bake `http://127.0.0.1:<port>` as their API base, so they
  talk to the published host ports from the browser.
- LuxShield's eBPF ring overlay (`docker-compose.ebpf.yml` in that repo) is
  Linux/host-network only and is intentionally not part of this stack; the
  default `sim` ring is used here.
