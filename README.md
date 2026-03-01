# Paperless-AI Full Stack

[![Docker](https://img.shields.io/badge/Docker-Compose-blue.svg)](https://docs.docker.com/compose/)
[![Self-Hosted](https://img.shields.io/badge/Self--Hosted-green.svg)](https://github.com/macrobiotis/paperless-ai-full-stack)

Automated document management with AI tagging, OCR and local LLMs (Ollama with llama3.2 and qwen2.5).

## Features

- **Paperless-ngx**: Core DMS with OCR/search
- **Paperless-AI**: AI auto-tagging, summarization (Ollama/OpenAI)
- **GPU Support**: CUDA/ROCm auto-detection
- **Local-First**: 100% self-hosted, no cloud

## Prerequisites

- Docker & Docker Compose
- 4GB+ RAM (8GB recommended for LLMs)
- GPU (cuda/rocm) optional (CPU fallback)

Run `./install-docker.sh`

## Installation

```bash
git clone git@github.com:macrobiotis/paperless-ai-full-stack.git
cd paperless-ai-full-stack
```

## Quick-Start

### 1. Initial Setup

```bash
make up
```

Wait ~2min for PostgreSQL/Redis/Paperless to initialize.

### 2. Get API Token

- Open [http://localhost:8000](http://localhost:8000)
- Admin → Profile → API Tokens → Create new API Token
- Copy the token

### 3. Configure Environment

Edit .env:

```text
PAPERLESS_API_TOKEN=p-abc123yourtokenhere
OLLAMA_MODEL=llama3.2:1b  # or qwen2.5:3b
```

### 4. Start paperless-ai

```bash
make up-ai
```

### 5. Access Dashboard

| Interface          | URL                      |
|--------------------|--------------------------|
| Paperless          | <http://localhost:3000>  |
| Paperless-Ai       | <http://localhost:3000>  |

## Docker-Containers

| Service            | Port  | Purpose                  |
|--------------------|-------|--------------------------|
| ollama             | 11434 | Local LLM (GPU/CPU)      |
| redis              | 6379  | Session/Cache            |
| paperless-db       | 5432  | PostgreSQL Database      |
| paperless-webserver| 8000  | Main Web UI              |
| paperless-ai       | 3000  | AI Processing Dashboard  |

## Configuration-Files

| File                | Required | Purpose                                |
|---------------------|----------|----------------------------------------|
| `.env`              | Yes      | Tokens, URLs, Model settings           |
| `.paperless-ai.env` | Yes      | AI-specific overrides (MAX_CONCURRENT) |

## Persistent Volumes

| Path                  | Usage                               |
|-------------------------|-----------------------------------|
| `./volumes/consume`    | 📥 Drop PDFs here (auto-process)   |
| `./volumes/export`     | Generated reports/exports          |
| `./volumes/media`      |  Thumbnails + processed files      |

## Makefile Commands

### Status & Info

```bash
make status           # Container overview
make gpu-detect       # GPU/CPU detection
```

### Ollama Management

```bash
make ollama-pull      # Download model
make ollama-list      # List available models
make ollama-test      # API test
```

### Lifecycle

```bash
make up               # Full stack (core)
make up-ai            # Add AI (after token)
make down             # Graceful stop
make clean            # Stop + delete volumes ⚠️
```

### Logs

```bash
make logs             # All services
make logs-ai          # Paperless-AI only
make logs-paperless   # Paperless core
```

## Example AI Prompt (German Legal Docs)

```m̀arkdown
Du bist präziser Assistent. **STRICT: Nur Kontext-Fakten, KEINE Ergänzungen/Halluzinationen!**

**AUFGABE:** Saubere Analyse. Ignoriere irrelevante Chunks.

**KONTEXT:** {context}  # text | page | chunkid | rolle/person

**STRICT REGELN:**

- **STOP bei Wiederholung:** Wenn ein inhaltlich gleicher Satz 3x im Kontext vorkommt, übernimm ihn höchstens 1x in der ABSCHRIFT und IGNORIERE alle weiteren Wiederholungen. Keine „Fortsetzung“ mehr anhängen.
- Schreibe NIEMALS Sätze mehrfach in der ABSCHRIFT, nur weil sie im Kontext mehrfach vorkommen.
- **BESCHLÜSSE:** KANN NUR DAS GERICHT/DIE BEHÖRDE ERLASSEN! Partei/Anwalt-Text = Antrag/Schriftsatz (NIE Beschluss).
- **TITEL:** Bestimme einen kurzen Titel aus dem Kontext mit Rolle des Autors (Gericht, Kindesmutter, Kindesvater, Verfahrensbeistand, Umgangspfleger). Nur alphabetische Zeichen, keine `#`, keine Sonderzeichen.

**STRICT Markdown-Format (~≤1200 Wörter):**

**Titel:** {TITEL}  # Aus Kontext, mit Rolle des Autors (kürzen!)
**Datum:** {DATUM}
**Aktenzeichen:** {AKTENZEICHEN}
**Tags:** {TAGS}
**Klassifizierung:** {Antrag/Beschluss/Bericht – aus Text}

***
ABSCHRIFT
```
