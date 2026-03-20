# 🛠️ Nansen "Make Alpha" 

> **Developers use `make` to compile software. Traders use `make` to compile alpha.**

*A lightweight, zero-bloat CLI orchestrator. Built to give your terminal an onchain lens for the [Nansen CLI Build Challenge](https://x.com/nansen_ai/status/2029121477367460127).*

---

## 🧠 The Concept
On-chain data analysis is often plagued by heavy dashboards, slow browser tabs, and complex API scripts. But the best developer tools in history follow the Unix philosophy: *do one thing, do it well, and keep it lightweight.*

**Make Alpha** uses standard, zero-dependency `make` commands to orchestrate the new Nansen CLI. 

Instead of manually typing 10 different queries every morning to check cross-chain flows, a single `make alpha` command natively executes a suite of Nansen CLI calls in the background, handles errors gracefully, and compiles a clean, human-readable `daily_report.md` locally on your machine.

## ✨ Features
- **Zero Bloat:** No Python, no `node_modules` (besides the CLI itself), no heavy frameworks. Just a standard UNIX `Makefile`.
- **Fail-Soft Execution:** Uses native shell error-handling (`-` and `||`). If one chain's RPC endpoint is temporarily down, the `Makefile` catches the error, outputs a clean JSON error block into the report, and continues fetching the rest of your alpha.
- **Multi-Chain Lens:** Automatically queries Smart Money flows, DEX trades, and Whale portfolios across Ethereum, Solana, Arbitrum, Base, and Optimism in one go.
- **Self-Documenting:** Just type `make` to see all available commands.

## 🚀 Quick Start

### 1. Install the Nansen CLI
```bash
make setup
```

### 2. Authenticate
Two options — pick one:
```bash
# Option A: Auto-auth (reads API key from .env file)
make auth

# Option B: Pass your key directly
make login API_KEY=your_nansen_api_key_here
```
Get your free API key at [app.nansen.ai/auth/agent-setup](https://app.nansen.ai/auth/agent-setup).

### 3. Test the Connection
```bash
# Pings a single endpoint to verify JSON output formatting
make test
```

### 4. Compile Your Alpha
```bash
# Fetch 10 cross-chain data points and generate your daily report
make alpha
```

### 5. Read the Report
Open the newly generated `daily_report.md` in your favorite Markdown viewer (like VS Code or Obsidian) to review the latest Smart Money netflows and Whale PnL.

## 📋 Available Commands

| Command | Description |
|---------|-------------|
| `make` | Show all available commands |
| `make setup` | Install Nansen CLI |
| `make auth` | Authenticate using API key from `.env` |
| `make login API_KEY=xxx` | Authenticate with key passed directly |
| `make test` | Test a single endpoint |
| `make alpha` | Generate full daily report (10 API calls) |
| `make clean` | Remove old reports |

---

## 🏆 Hackathon Context: Week 1 Submission

This project was built specifically for **Week 1 of the Nansen CLI Build Challenge** (Deadline: Sunday, Mar 22). 

As the Nansen Intern noted in the kickoff email: *"Give your agent onchain lens."* While many reach for heavy LLM frameworks to build "agents," **Make Alpha** takes a literal approach: the most reliable, fastest, and most useful autonomous agent for a daily trader is a standard UNIX task runner (`make`). It acts autonomously to fetch your data so you don't have to.

**How this hits the 4 core judging criteria:**
1. **Usefulness:** Saves traders 30+ minutes a day. Instead of clicking through explorers, one command generates a comprehensive daily onchain report locally.
2. **Creativity:** Applying a 48-year-old C-compiler tool (`make`) to orchestrate cutting-edge Web3 onchain data. 
3. **Technical Depth:** Bypasses basic scripting by using native `stderr` swallowing (`2>/dev/null`), fail-soft error handling (`-` prefixes), standard JSON formatting (`--pretty`), and dynamic timestamp generation via shell macros.
4. **Presentation:** A clean, documented repository that perfectly explains the "why" and "how".

**Challenge Checklist:**
- [x] Install CLI (`make setup`)
- [x] Make minimum 10 API calls (`make alpha` runs exactly 10 multi-chain queries)
- [x] Build something real (A developer-first daily reporting pipeline)
- [x] Share on X tagging @nansen_ai with #NansenCLI

---
*Built with ☕️ and standard UNIX tools for the #NansenCLI Challenge.*