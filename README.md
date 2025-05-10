
## 📘 README.md – AIDER Token Sale dApp (AI-Built)

```markdown
# 🪙 AIDER Token Sale dApp (Built with AI Assistance)

This project is a full-stack Web3 decentralized application (dApp) for creating and selling an ERC20 token called **AIDER**. It is developed using:

- 🧠 **Aider** AI Coding Assistant + **Gemini 2.5 Pro**
- 🛠️ **Foundry** (for smart contract development)
- 🌐 **Next.js + RainbowKit + Wagmi + Shadcn UI** (for frontend)
- 🐳 **Docker** (to run Aider)
- 🔒 **OpenZeppelin Contracts v5** (for token standards)

---

## 🔥 Features

- ERC20 Token: `AIDER` with symbol `AID`, 18 decimals
- Token Sale Logic: Buy 1 AID for 0.1 ETH
- Automatic minting with refund for excess ETH
- Secure ownership with OpenZeppelin's `Ownable`
- Direct ETH transfers supported via `receive()`
- Withdraw function for the contract owner
- Integrated test suite with Foundry
- Beautiful Next.js frontend with wallet support

---

## 📁 Project Structure

```

aider-gemini-dapp/
├── contracts/                # Foundry-based smart contract project
│   ├── src/AiderToken.sol   # ERC20 token + sale logic
│   ├── script/AiderToken.s.sol # Deployment script
│   ├── test/AiderToken.t.sol   # Tests using forge
│   └── foundry.toml         # Foundry config
├── app/                     # Frontend (Next.js App Router)
│   ├── layout.tsx
│   ├── page.tsx
│   └── providers.tsx
├── .env                     # Gemini API key
├── .gitignore
└── README.md

````

---

## 🚀 Quick Start

### 1. Clone & Setup

```bash
git clone https://github.com/your-username/aider-gemini-dapp.git
cd aider-gemini-dapp
````

### 2. Install Prerequisites

* Node.js & npm: [https://nodejs.org](https://nodejs.org)
* Foundry (in WSL): `curl -L https://foundry.paradigm.xyz | bash && foundryup`
* Docker Desktop (enable WSL integration): [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
* Google Gemini API Key: [https://makersuite.google.com/app/apikey](https://makersuite.google.com/app/apikey)

### 3. Setup Foundry Contracts

```bash
cd contracts
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 --no-commit
forge build
cd ..
```

### 4. Add Your Gemini API Key

Create a `.env` file in the root:

```
GEMINI_API_KEY=your_actual_google_gemini_api_key
```

---

## 🤖 AI Coding Workflow with Aider

Launch Aider via Docker:

```bash
docker run --rm -it \
  -v $(pwd):/app \
  --env-file .env \
  paulgauthier/aider-full \
  --model gemini/gemini-2.5-pro-preview-05-06
```

Then inside Aider:

```bash
/add contracts/src/Counter.sol contracts/script/Counter.s.sol contracts/test/Counter.t.sol contracts/README.md
```

Use prompts like:

> Replace the Counter contract with an ERC20 token named AIDER. Add a buyTokens() function with 1 AID = 0.1 ETH. Refund extra ETH. Add receive(), withdraw(), Ownable, and update deploy/test/README files.

---

## 🧪 Testing

Run smart contract tests:

```bash
cd contracts
forge test
```

---

## 🌐 Frontend

### 1. Setup

```bash
npx create-next-app@latest . --ts --tailwind --eslint --app --no-src-dir --import-alias "@/*"
npx shadcn-ui@latest init
npm install @rainbow-me/rainbowkit wagmi viem@2.x @tanstack/react-query
npx shadcn-ui@latest add button alert
```

### 2. Run Next.js Dev Server

```bash
npm run dev
```

Access at: [http://localhost:3000](http://localhost:3000)

---

## 🛠️ Deployment (Local Anvil + MetaMask)

1. Start local chain:

```bash
anvil
```

2. Deploy contract:

```bash
forge script script/AiderToken.s.sol:DeployScript --rpc-url http://127.0.0.1:8545 --private-key YOUR_PRIVATE_KEY --broadcast
```

3. Paste deployed contract address in `app/page.tsx`.

4. Connect MetaMask → Buy tokens → Confirm in UI.

---

## 📚 Learn More

* Aider: [https://github.com/paul-gauthier/aider](https://github.com/paul-gauthier/aider)
* Foundry Book: [https://book.getfoundry.sh/](https://book.getfoundry.sh/)
* RainbowKit: [https://www.rainbowkit.com/](https://www.rainbowkit.com/)
* Gemini API: [https://makersuite.google.com/](https://makersuite.google.com/)

---

## ✨ Credits

This project was generated iteratively using [Aider](https://github.com/paul-gauthier/aider) and [Gemini 2.5 Pro](https://ai.google.dev/gemini-api) as an AI co-pilot.


