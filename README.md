# 🛠️ Nansen "Make Alpha" 

> **Developers use `make` to compile software. Traders use `make` to compile alpha.**

Built for Week 1 of the **[Nansen CLI Build Challenge](https://x.com/nansen_ai/status/2029121477367460127)**.

## 🧠 The Concept
On-chain data analysis is often plagued by heavy dashboards, slow browser tabs, and complex API scripts. But the best developer tools in history follow the Unix philosophy: *do one thing, do it well, and keep it lightweight.*

**Make Alpha** uses standard, zero-dependency `make` commands to orchestrate the new Nansen CLI. 

Instead of manually typing 10 different queries every morning to check cross-chain flows, a single `make alpha` command natively executes a suite of Nansen CLI calls in the background, handles errors gracefully, and compiles a clean, human-readable `daily_report.md` locally on your machine.

## ✨ Features
- **Zero Bloat:** No Python, no `node_modules` (besides the CLI itself), no heavy frameworks. Just a standard UNIX `Makefile`.
- **Fail-Soft Execution:** Uses native shell error-handling (`-` and `||`). If one chain's RPC endpoint is temporarily down, the `Makefile` catches the error, outputs a clean JSON error block into the report, and continues fetching the rest of your alpha.
- **Multi-Chain Lens:** Automatically queries Smart Money flows, DEX trades, and Whale portfolios across Ethereum, Solana, Arbitrum, Base, and Optimism in one go.

## 🚀 Quick Start

### 1. Setup & Authenticate
\`\`\`bash
# Install the Nansen CLI natively
make setup

# Authenticate your machine (Follow the interactive browser prompt)
make auth
\`\`\`

### 2. Test the Connection
Want to test your auth state before running the full suite?
\`\`\`bash
# Pings a single endpoint to verify JSON output formatting
make test
\`\`\`

### 3. Compile Your Alpha
\`\`\`bash
# Fetch 10 cross-chain data points and generate your daily report
make alpha
\`\`\`

### 4. Read the Report
Open the newly generated `daily_report.md` in your favorite Markdown viewer (like VS Code or Obsidian) to review the latest Smart Money netflows and Whale PnL.

## 🏆 Nansen CLI Challenge Checklist
- [x] **Install CLI:** Handled natively via `make setup`.
- [x] **10 API Calls:** `make alpha` automatically hits exactly 10 unique endpoints.
- [x] **Build Something Useful:** A streamlined, developer-first daily reporting tool that saves traders 30+ minutes a day.
- [x] **Technical Depth:** Uses native shell error-handling, stderr-swallowing (`2>/dev/null`), standard JSON formatting (`--pretty`), and standard UNIX orchestration.

---
*Built with ☕️ and standard UNIX tools for the #NansenCLI Challenge.*