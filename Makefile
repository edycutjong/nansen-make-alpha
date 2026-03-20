# ==========================================
# NANSEN "MAKE ALPHA" CLI ORCHESTRATOR
# ==========================================

-include .env
export

REPORT_FILE = daily_report.md
TIMESTAMP = $(shell date '+%Y-%m-%d %H:%M:%S')

.DEFAULT_GOAL := help
.PHONY: help setup auth login clean test alpha

help:
	@echo "📊 Nansen Make Alpha — Compile your daily onchain alpha"
	@echo ""
	@echo "  make setup  — Install Nansen CLI"
	@echo "  make auth   — Authenticate (reads API key from .env)"
	@echo "  make login  — Authenticate with key: make login API_KEY=xxx"
	@echo "  make test   — Test single endpoint"
	@echo "  make alpha  — Generate full daily report (10 API calls)"
	@echo "  make clean  — Remove old reports"

setup:
	@echo "📦 Installing Nansen CLI..."
	npm install -g nansen-cli

auth:
	@echo "🔐 Authenticating with Nansen (using .env)..."
	nansen login

login:
	@echo "🔐 Authenticating with Nansen (manual key)..."
	@if [ -z "$(API_KEY)" ]; then \
		echo "❌ Usage: make login API_KEY=your_key_here"; exit 1; \
	fi
	nansen login --api-key $(API_KEY)

clean:
	@echo "🧹 Cleaning up old reports..."
	rm -f $(REPORT_FILE)

# A quick test command to let you verify JSON output in your terminal before running the full suite
test:
	@echo "🧪 Testing single endpoint..."
	nansen research smart-money netflow --chain ethereum --limit 1 --pretty

alpha: clean
	@echo "🚀 Generating Nansen Alpha Report for $(TIMESTAMP)..."
	@echo "# 📊 Daily Nansen Alpha Report" > $(REPORT_FILE)
	@echo "Generated at: $(TIMESTAMP) WIB\n" >> $(REPORT_FILE)

	@echo "Fetching Smart Money Netflows (Calls 1-5)..."
	
	@echo "## 1. Ethereum Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	-nansen research smart-money netflow --chain ethereum --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Ethereum data"\n}' >> $(REPORT_FILE)
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 2. Solana Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	-nansen research smart-money netflow --chain solana --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Solana data"\n}' >> $(REPORT_FILE)
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 3. Arbitrum Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	-nansen research smart-money netflow --chain arbitrum --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Arbitrum data"\n}' >> $(REPORT_FILE)
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 4. Base Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	-nansen research smart-money netflow --chain base --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Base data"\n}' >> $(REPORT_FILE)
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 5. Optimism Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	-nansen research smart-money netflow --chain optimism --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Optimism data"\n}' >> $(REPORT_FILE)
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "Fetching Smart Money DEX Trades (Calls 6-8)..."
	
	@echo "## 6. Ethereum DEX Trades" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	-nansen research smart-money dex-trades --chain ethereum --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch ETH DEX data"\n}' >> $(REPORT_FILE)
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 7. Solana DEX Trades" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	-nansen research smart-money dex-trades --chain solana --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch SOL DEX data"\n}' >> $(REPORT_FILE)
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 8. Base DEX Trades" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	-nansen research smart-money dex-trades --chain base --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Base DEX data"\n}' >> $(REPORT_FILE)
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "Fetching Whale Portfolios (Calls 9-10)..."
	
	@echo "## 9. vitalik.eth PnL Summary" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	-nansen profiler address pnl-summary --address vitalik.eth --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Vitalik data"\n}' >> $(REPORT_FILE)
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 10. justinsun.eth PnL Summary" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	-nansen profiler address pnl-summary --address justinsun.eth --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Justin Sun data"\n}' >> $(REPORT_FILE)
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "✅ Done! Open $(REPORT_FILE) to view your daily alpha."
