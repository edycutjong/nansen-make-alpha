# ==========================================
# NANSEN "MAKE ALPHA" CLI ORCHESTRATOR
# ==========================================

REPORT_FILE = daily_report.md
TIMESTAMP = $(shell date '+%Y-%m-%d %H:%M:%S')

.DEFAULT_GOAL := help
.PHONY: help setup auth login clean test alpha watch report

help:
	@echo "📊 Nansen Make Alpha — Compile your daily onchain alpha"
	@echo ""
	@echo "  make setup  — Install Nansen CLI"
	@echo "  make auth   — Authenticate (reads API key from .env)"
	@echo "  make login  — Authenticate with key: make login API_KEY=xxx"
	@echo "  make test   — Test single endpoint"
	@echo "  make alpha  — Generate full daily report (15 API calls)"
	@echo "  make report — List all saved reports"
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

# Show section summary from daily_report.md
report:
	@echo ""
	@if [ ! -f $(REPORT_FILE) ]; then \
		echo "  ❌ No report found — run 'make alpha' first"; \
		echo ""; \
		exit 0; \
	fi
	@TIMESTAMP=$$(head -2 $(REPORT_FILE) | tail -1); \
	echo "  📊 Daily Alpha Report"; \
	echo "  $$TIMESTAMP"; \
	echo ""; \
	echo "  ── Sections ─────────────────────────────"; \
	echo ""; \
	for i in $$(seq 1 15); do \
		TITLE=$$(grep "^## $$i\." $(REPORT_FILE) | sed 's/^## //' | head -1); \
		if [ -z "$$TITLE" ]; then \
			echo "  —  $$i. (missing)"; \
		else \
			HAS_ERROR=$$(awk "/^## $$i\./,/^## $$((i+1))\.|$$/" $(REPORT_FILE) | grep -c '"error"'); \
			HAS_DATA=$$(awk "/^## $$i\./,/^## $$((i+1))\.|$$/" $(REPORT_FILE) | grep -c '"success"'); \
			if [ "$$HAS_ERROR" -gt 0 ]; then \
				echo "  ✗  $$TITLE"; \
			elif [ "$$HAS_DATA" -gt 0 ]; then \
				echo "  ✓  $$TITLE"; \
			else \
				echo "  ✓  $$TITLE"; \
			fi; \
		fi; \
	done; \
	echo ""; \
	echo "  → View section: make report-1"; \
	echo ""

# View a section as readable table: make report-1
# View raw JSON: make report-1-raw
report-%:
	@if [ ! -f $(REPORT_FILE) ]; then \
		echo "  ❌ No report found — run 'make alpha' first"; \
		exit 1; \
	fi
	@NUM=$$(echo "$*" | sed 's/-raw//'); \
	NEXT=$$((NUM + 1)); \
	TITLE=$$(grep "^## $$NUM\." $(REPORT_FILE) | sed 's/^## //' | head -1); \
	if [ -z "$$TITLE" ]; then \
		echo "  ❌ Section $$NUM not found"; \
		exit 1; \
	fi; \
	echo ""; \
	echo "  📄 $$TITLE"; \
	echo "  ──────────────────────────────────────"; \
	echo ""; \
	CONTENT=$$(awk "/^## $$NUM\./,/^## $$NEXT\./" $(REPORT_FILE) | sed '1d' | sed '$$d'); \
	if echo "$*" | grep -q "raw"; then \
		echo "$$CONTENT"; \
	elif [ $$NUM -le 5 ]; then \
		printf "  %-12s %-10s %12s %12s %12s\n" "Token" "Chain" "24h Flow" "7d Flow" "MCap"; \
		printf "  %-12s %-10s %12s %12s %12s\n" "────────────" "──────────" "────────────" "────────────" "────────────"; \
		echo "$$CONTENT" | awk -F'"' ' \
			/token_symbol/{sym=$$4} \
			/"chain"/{chain=$$4} \
			/net_flow_24h_usd/{split($$0,a,":"); gsub(/[, ]/,"",a[2]); f24=a[2]+0} \
			/net_flow_7d_usd/{split($$0,a,":"); gsub(/[, ]/,"",a[2]); f7=a[2]+0} \
			/market_cap_usd/{split($$0,a,":"); gsub(/[, ]/,"",a[2]); mc=a[2]+0; \
				printf "  %-12s %-10s %12.0f %12.0f %12.0f\n", sym, chain, f24, f7, mc}'; \
	elif [ $$NUM -le 10 ]; then \
		printf "  %-10s %-10s %-18s %12s\n" "Bought" "Sold" "Trader" "Value"; \
		printf "  %-10s %-10s %-18s %12s\n" "──────────" "──────────" "──────────────────" "────────────"; \
		echo "$$CONTENT" | awk -F'"' ' \
			/token_bought_symbol/{buy=$$4} \
			/token_sold_symbol/{sell=$$4} \
			/trader_address_label/{label=$$4; if(label=="") label="Unknown"} \
			/trade_value_usd/{gsub(/[, ]/,"",$$0); split($$0,a,":"); val=a[2]+0; \
				printf "  %-10s %-10s %-18s %12.2f\n", buy, sell, substr(label,1,16), val}'; \
	elif [ $$NUM -le 13 ]; then \
		printf "  %-10s %14s %14s %14s %12s\n" "Token" "Price" "Volume" "Netflow" "MCap"; \
		printf "  %-10s %14s %14s %14s %12s\n" "──────────" "──────────────" "──────────────" "──────────────" "────────────"; \
		echo "$$CONTENT" | awk -F'"' ' \
			/token_symbol/{sym=$$4} \
			/"price_usd"/{gsub(/[, ]/,"",$$0); split($$0,a,":"); price=a[2]+0} \
			/"volume"/{gsub(/[, ]/,"",$$0); split($$0,a,":"); vol=a[2]+0} \
			/"netflow"/{gsub(/[, ]/,"",$$0); split($$0,a,":"); nf=a[2]+0} \
			/market_cap_usd/{split($$0,a,":"); gsub(/[, ]/,"",a[2]); mc=a[2]+0; \
				printf "  %-10s %14.6f %14.0f %14.0f %12.0f\n", sym, price, vol, nf, mc}'; \
	else \
		echo "$$CONTENT" | awk -F'"' ' \
			/token_symbol/{printf "  Token: %s\n", $$4} \
			/chain/{printf "  Chain: %s\n", $$4} \
			/trade_value_usd|net_flow/{gsub(/[, ]/,"",$$0); split($$0,a,":"); printf "  %s: %s\n", $$2, a[2]}'; \
	fi; \
	echo ""

alpha: clean
	@echo ""
	@echo "  ███╗   ███╗ █████╗ ██╗  ██╗███████╗"
	@echo "  ████╗ ████║██╔══██╗██║ ██╔╝██╔════╝"
	@echo "  ██╔████╔██║███████║█████╔╝ █████╗  "
	@echo "  ██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝  "
	@echo "  ██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗"
	@echo "  ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝"
	@echo "   █████╗ ██╗     ██████╗ ██╗  ██╗ █████╗ "
	@echo "  ██╔══██╗██║     ██╔══██╗██║  ██║██╔══██╗"
	@echo "  ███████║██║     ██████╔╝███████║███████║"
	@echo "  ██╔══██║██║     ██╔═══╝ ██╔══██║██╔══██║"
	@echo "  ██║  ██║███████╗██║     ██║  ██║██║  ██║"
	@echo "  ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝"
	@echo ""
	@echo "  powered by Nansen CLI · $(TIMESTAMP)"
	@echo ""
	@echo "# 📊 Daily Nansen Alpha Report" > $(REPORT_FILE)
	@echo "Generated at: $(TIMESTAMP) WIB\n" >> $(REPORT_FILE)

	@echo "  ── Smart Money Netflows ──────────────────"
	@echo ""

	@echo "## 1. Ethereum Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money netflow --chain ethereum --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Ethereum data"\n}' >> $(REPORT_FILE)
	@echo "  [ 1/15]  ✓ Ethereum"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 2. Solana Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money netflow --chain solana --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Solana data"\n}' >> $(REPORT_FILE)
	@echo "  [ 2/15]  ✓ Solana"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 3. Arbitrum Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money netflow --chain arbitrum --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Arbitrum data"\n}' >> $(REPORT_FILE)
	@echo "  [ 3/15]  ✓ Arbitrum"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 4. Base Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money netflow --chain base --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Base data"\n}' >> $(REPORT_FILE)
	@echo "  [ 4/15]  ✓ Base"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 5. Optimism Smart Money Netflow" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money netflow --chain optimism --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Optimism data"\n}' >> $(REPORT_FILE)
	@echo "  [ 5/15]  ✓ Optimism"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo ""
	@echo "  ── Smart Money DEX Trades ────────────────"
	@echo ""

	@echo "## 6. Ethereum DEX Trades" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money dex-trades --chain ethereum --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch ETH DEX data"\n}' >> $(REPORT_FILE)
	@echo "  [ 6/15]  ✓ Ethereum"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 7. Solana DEX Trades" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money dex-trades --chain solana --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch SOL DEX data"\n}' >> $(REPORT_FILE)
	@echo "  [ 7/15]  ✓ Solana"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 8. Base DEX Trades" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money dex-trades --chain base --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Base DEX data"\n}' >> $(REPORT_FILE)
	@echo "  [ 8/15]  ✓ Base"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 9. Arbitrum DEX Trades" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money dex-trades --chain arbitrum --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Arbitrum DEX data"\n}' >> $(REPORT_FILE)
	@echo "  [ 9/15]  ✓ Arbitrum"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 10. Optimism DEX Trades" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research smart-money dex-trades --chain optimism --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Optimism DEX data"\n}' >> $(REPORT_FILE)
	@echo "  [10/15]  ✓ Optimism"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo ""
	@echo "  ── Token Screeners ──────────────────────"
	@echo ""

	@echo "## 11. Ethereum Token Screener" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research token screener --chain ethereum --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch ETH Token Screener"\n}' >> $(REPORT_FILE)
	@echo "  [11/15]  ✓ Ethereum"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 12. Solana Token Screener" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research token screener --chain solana --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch SOL Token Screener"\n}' >> $(REPORT_FILE)
	@echo "  [12/15]  ✓ Solana"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 13. Base Token Screener" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen research token screener --chain base --limit 3 --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Base Token Screener"\n}' >> $(REPORT_FILE)
	@echo "  [13/15]  ✓ Base"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo ""
	@echo "  ── Whale Portfolios ─────────────────────"
	@echo ""

	@echo "## 14. vitalik.eth PnL Summary" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen profiler pnl-summary --address vitalik.eth --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Vitalik data"\n}' >> $(REPORT_FILE)
	@echo "  [14/15]  ✓ vitalik.eth"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo "## 15. justinsun.eth PnL Summary" >> $(REPORT_FILE)
	@echo "\`\`\`json" >> $(REPORT_FILE)
	@-nansen profiler pnl-summary --address justinsun.eth --pretty >> $(REPORT_FILE) 2>/dev/null || echo '{\n  "error": "Failed to fetch Justin Sun data"\n}' >> $(REPORT_FILE)
	@echo "  [15/15]  ✓ justinsun.eth"
	@echo "\`\`\`\n" >> $(REPORT_FILE)

	@echo ""
	@echo "  ✅ Done — 15 API calls across 5 chains"
	@echo "  📄 Report saved to $(REPORT_FILE)"
	@echo ""
