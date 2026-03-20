# ==========================================
# NANSEN "MAKE ALPHA" CLI ORCHESTRATOR
# ==========================================

REPORT_FILE = daily_report.md
TIMESTAMP = $(shell date '+%Y-%m-%d %H:%M:%S')

.DEFAULT_GOAL := help
.PHONY: help setup auth login clean test alpha watch

help:
	@echo "📊 Nansen Make Alpha — Compile your daily onchain alpha"
	@echo ""
	@echo "  make setup  — Install Nansen CLI"
	@echo "  make auth   — Authenticate (reads API key from .env)"
	@echo "  make login  — Authenticate with key: make login API_KEY=xxx"
	@echo "  make test   — Test single endpoint"
	@echo "  make alpha  — Generate full daily report (15 API calls)"
	@echo "  make watch  — Auto-run alpha every 6 hours"
	@echo "  make clean  — Remove old reports"

setup:
	@echo "📦 Installing Nansen CLI..."
	npm install -g nansen-cli

auth:
	@echo "🔐 Authenticating with Nansen (using .env)..."
	@if [ ! -f .env ]; then \
		echo "❌ No .env file found. Create one with: echo 'NANSEN_API_KEY=your_key' > .env"; exit 1; \
	fi
	@KEY=$$(grep NANSEN_API_KEY .env | cut -d'=' -f2); \
	if [ -z "$$KEY" ] || [ "$$KEY" = "your_api_key_here" ]; then \
		echo "❌ Set your real API key in .env first"; exit 1; \
	fi; \
	nansen login --api-key $$KEY

login:
	@echo "🔐 Authenticating with Nansen (manual key)..."
	@if [ -z "$(API_KEY)" ]; then \
		echo "❌ Usage: make login API_KEY=your_key_here"; exit 1; \
	fi
	nansen login --api-key $(API_KEY)

clean:
	@echo "🧹 Archiving old report..."
	@if [ -f $(REPORT_FILE) ]; then \
		mv $(REPORT_FILE) daily_report_$$(date '+%Y%m%d_%H%M%S').bak; \
		echo "📦 Old report archived"; \
	fi

# A quick test command to let you verify JSON output in your terminal before running the full suite
test:
	@echo "🧪 Testing single endpoint..."
	nansen research smart-money netflow --chain ethereum --limit 1 --pretty

# Auto-pilot: run alpha every 6 hours
watch:
	@echo "⏰ Alpha Watch Mode — Running every 6 hours. Press Ctrl+C to stop."
	@while true; do \
		make alpha; \
		echo "💤 Next run in 6 hours..."; \
		sleep 21600; \
	done

alpha: clean
	@echo ""
	@echo "╔══════════════════════════════════════════════╗"
	@echo "║   📊 NANSEN MAKE ALPHA — Daily Report       ║"
	@echo "║   $(TIMESTAMP)                    ║"
	@echo "╚══════════════════════════════════════════════╝"
	@echo ""
	@echo "# 📊 Daily Nansen Alpha Report" > $(REPORT_FILE)
	@echo "Generated at: $(TIMESTAMP) WIB\n" >> $(REPORT_FILE)

	@echo "━━━ Smart Money Netflows ━━━━━━━━━━━━━━━━━━━━━"
	@echo ""

	@echo "## 1. Ethereum Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money netflow --chain ethereum --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Ethereum data"\n}' >> $(REPORT_FILE)
	@echo "  [ 1/15]  ✅ Ethereum netflow"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 2. Solana Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money netflow --chain solana --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Solana data"\n}' >> $(REPORT_FILE)
	@echo "  [ 2/15]  ✅ Solana netflow"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 3. Arbitrum Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money netflow --chain arbitrum --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Arbitrum data"\n}' >> $(REPORT_FILE)
	@echo "  [ 3/15]  ✅ Arbitrum netflow"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 4. Base Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money netflow --chain base --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Base data"\n}' >> $(REPORT_FILE)
	@echo "  [ 4/15]  ✅ Base netflow"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 5. Optimism Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money netflow --chain optimism --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Optimism data"\n}' >> $(REPORT_FILE)
	@echo "  [ 5/15]  ✅ Optimism netflow"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo ""
	@echo "━━━ Smart Money DEX Trades ━━━━━━━━━━━━━━━━━━━"
	@echo ""

	@echo "## 6. Ethereum DEX Trades" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money dex-trades --chain ethereum --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch ETH DEX data"\n}' >> $(REPORT_FILE)
	@echo "  [ 6/15]  ✅ Ethereum DEX trades"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 7. Solana DEX Trades" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money dex-trades --chain solana --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch SOL DEX data"\n}' >> $(REPORT_FILE)
	@echo "  [ 7/15]  ✅ Solana DEX trades"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 8. Base DEX Trades" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money dex-trades --chain base --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Base DEX data"\n}' >> $(REPORT_FILE)
	@echo "  [ 8/15]  ✅ Base DEX trades"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 9. Arbitrum DEX Trades" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money dex-trades --chain arbitrum --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Arbitrum DEX data"\n}' >> $(REPORT_FILE)
	@echo "  [ 9/15]  ✅ Arbitrum DEX trades"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 10. Optimism DEX Trades" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money dex-trades --chain optimism --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Optimism DEX data"\n}' >> $(REPORT_FILE)
	@echo "  [10/15]  ✅ Optimism DEX trades"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo ""
	@echo "━━━ Token Screeners ━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""

	@echo "## 11. Ethereum Token Screener" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research token screener --chain ethereum --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch ETH Token Screener"\n}' >> $(REPORT_FILE)
	@echo "  [11/15]  ✅ Ethereum token screener"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 12. Solana Token Screener" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research token screener --chain solana --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch SOL Token Screener"\n}' >> $(REPORT_FILE)
	@echo "  [12/15]  ✅ Solana token screener"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 13. Base Token Screener" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research token screener --chain base --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Base Token Screener"\n}' >> $(REPORT_FILE)
	@echo "  [13/15]  ✅ Base token screener"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo ""
	@echo "━━━ Whale Portfolios ━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""

	@echo "## 14. vitalik.eth PnL Summary" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen profiler pnl-summary --address vitalik.eth --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Vitalik data"\n}' >> $(REPORT_FILE)
	@echo "  [14/15]  ✅ vitalik.eth PnL"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 15. justinsun.eth PnL Summary" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen profiler pnl-summary --address justinsun.eth --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Justin Sun data"\n}' >> $(REPORT_FILE)
	@echo "  [15/15]  ✅ justinsun.eth PnL"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo ""
	@echo "╔══════════════════════════════════════════════╗"
	@echo "║  ✅ REPORT COMPLETE                          ║"
	@echo "║                                              ║"
	@echo "║  📄 Output: $(REPORT_FILE)              ║"
	@echo "║  📡 API Calls: 15                            ║"
	@echo "║  🔗 Chains: ETH · SOL · ARB · BASE · OP     ║"
	@echo "║  📊 Sections: Netflows · DEX · Screener · PnL║"
	@echo "╚══════════════════════════════════════════════╝"
	@echo ""
