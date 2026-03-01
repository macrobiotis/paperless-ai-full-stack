# Makefile: Paperless-ngx + paperless-ai + Ollama (GPU-aware)
# =======================================================

# .paperless-ai.env Auto-Create (if not exists)
ifeq ($(wildcard .paperless-ai.env),)
.paperless-ai.env:
	@echo "📝 Creating .paperless-ai.env template..."
	@cat > .paperless-ai.env <<- 'EOF'
# Paperless-AI specific .env (optional overrides)
# ===============================================
# PAPERLESS_API_TOKEN=your_token_here  # Override from .env
# OLLAMA_URL=http://ollama:11434
# AI_PROVIDER=ollama
# MAX_CONCURRENT=2
EOF
	@echo "✅ .paperless-ai.env created! Edit if needed."
endif

# .env Auto-Create (Template)
ifeq ($(wildcard .env),)
.env:
	@echo "📝 Creating .env template..."
	@cat > .env <<- 'EOF'
# Paperless-ngx + paperless-ai + Ollama (.env)
# =============================================
# ⚠️  EDIT THESE BEFORE FIRST 'make up'! ⚠️

# Paperless-ngx Database (sichere Defaults)
PAPERLESS_DBNAME=paperless
PAPERLESS_DBUSER=paperless
PAPERLESS_DBPASS=paperless123

# Paperless-ngx URLs
PAPERLESS_URL=http://paperless-webserver:8000
PAPERLESS_REDIS=redis://paperless-redis:6379

# paperless-ai API (Token from Paperless UI: Settings > API Tokens generate/yes!)
PAPERLESS_API_TOKEN=change_me_super_secret_token_here
PAPERLESS_USERNAME=admin

# Ollama (intern, Bridge-Network)
OLLAMA_URL=http://ollama:11434
OLLAMA_MODEL=llama3.2:1b  # Alternativen: qwen2.5:3b, phi3:mini, gemma2:2b

# AI Provider & Limits
AI_PROVIDER=ollama
MAX_CONCURRENT=2
OLLAMA_NUM_CTX=8192
MAX_TOKENS=2048

# Paperless-ngx Network/CSRF (Bridge-compatible)
PAPERLESS_CSRF_TRUSTED_ORIGINS=http://paperless-webserver:8000,http://127.0.0.1:8000
PAPERLESS_ALLOWED_HOSTS=paperless-webserver,127.0.0.1,localhost

# Optional: Debug/Logs
PAPERLESS_LOG_LEVEL=info
PAPERLESS_TIME_ZONE=Europe/Berlin
EOF
	@echo "✅ .env erstellt! 🔧 Editiere PAPERLESS_API_TOKEN & OLLAMA_MODEL:"
	@echo "   → Paperless UI: Settings → API Tokens → Copy Token"
	@echo "   → make up (nach Edit)"
	@exit 1  # Stoppe bis konfiguriert
endif

include .env
export  # Export for Docker Compose

# GPU Detection (rocm/cuda/fallback)
ifeq ($(shell test -e /dev/kfd && echo rocm),rocm)
  DETECT_GPU ?= rocm
else ifeq ($(shell ls /dev/nvidia* >/dev/null 2>&1 && echo cuda),cuda)
  DETECT_GPU ?= cuda
else
  DETECT_GPU ?= latest
endif

OLLAMA_IMAGE = ollama/ollama:$(DETECT_GPU)

# Status/Info
gpu-detect:
	@echo "🔍 GPU erkannt: $(DETECT_GPU)"
	@echo "🖼️  Ollama Image: $(OLLAMA_IMAGE)"
	@echo "🐳  PAPERLESS_URL: $(PAPERLESS_URL)"
	@echo "🔑  PAPERLESS_API_TOKEN: $(shell echo $${PAPERLESS_API_TOKEN:0:8}...)"

status:
	docker compose ps
	@echo "\n📊 Logs (tail -f): make logs"

# Docker Compose Targets
up: .env gpu-detect
	sed -i.bak "s|image: .*ollama/ollama[^ ]*|image: $(OLLAMA_IMAGE)|g" docker-compose.yaml || true
	docker compose --env-file .env up -d
	@echo "🚀 Alle Services up. Warte 2min → make status"

up-paperless:
	docker compose --env-file .env up -d paperless-db paperless-redis paperless-webserver
	@echo "📄 Paperless ready in ~2min"

up-ai: up-paperless
	docker compose --env-file .env up -d ollama paperless-ai
	@echo "🤖 AI ready. RAG-Index: http://localhost:3000"

down:
	docker compose --env-file .env down

clean:
	rm -f docker-compose.yaml.bak
	docker compose --env-file .env down -v --remove-orphans
	@echo "🧹 Cleaned (Volumes gelöscht)"

logs:
	docker compose --env-file .env logs -f

logs-ai:
	docker compose --env-file .env logs -f paperless-ai

logs-paperless:
	docker compose --env-file .env logs -f paperless-webserver

# Ollama Helpers
ollama-pull:
	docker compose --env-file .env exec ollama ollama pull $(OLLAMA_MODEL)

ollama-list:
	docker compose --env-file .env exec ollama ollama list

ollama-test:
	curl -X POST http://localhost:11434/api/generate -d '{ "model": "$(OLLAMA_MODEL)", "prompt": "Test" }' | jq .

# Paperless Helpers
paperless-token:
	@echo "🔑 Gehe zu: http://localhost:8000 → Admin → Settings → API Tokens"
	@echo "   → Create Token → Copy in .env"

.PHONY: gpu-detect status up up-paperless up-ai down clean logs logs-ai logs-paperless ollama-pull ollama-list ollama-test paperless-token

# =======================================================
