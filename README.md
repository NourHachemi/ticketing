# NFT Ticketing

Application de billetterie NFT réalisée pour le cours Blockchain.

## Fonctionnalités

- création et consultation d'événements ;
- une catégorie de billets par contrat ERC-721 ;
- image et métadonnées stockées sur IPFS avec Pinata ;
- achat direct en SepoliaETH avec MetaMask ;
- faux paiement par carte, suivi d'un mint par l'API ;
- affichage des NFT possédés ;
- retrait des fonds par le vendeur.

## Architecture

- `contracts/` : contrats Solidity, tests et scripts Foundry ;
- `api/` : FastAPI en trois couches (`presentation`, `domain`, `infrastructure`) ;
- `frontend/` : React, Vite et Ethers.js ;
- SQLite pour les événements et catégories.

## Lancement

API :

```bash
cd api
source .venv/bin/activate
uvicorn app.main:app --reload
```

Frontend :

```bash
cd frontend
npm install
npm run dev
```

Swagger : http://127.0.0.1:8000/docs

Frontend : http://127.0.0.1:5173

## Tests

```bash
cd contracts && forge test
cd ../api && .venv/bin/python -m pytest
cd ../frontend && npm run lint && npm run build
```

## Configuration

Le fichier local `contracts/.env`, exclu de Git, contient :

- `SEPOLIA_RPC_URL`
- `SELLER_ADDRESS`
- `PRIVATE_KEY`
- `PINATA_JWT`
- `TICKET_NFT_ADDRESS`

Ne jamais publier les clés privées ou le JWT Pinata.

## Contrat Sepolia

`0x2B7A5d59B8Ae33e4B6b0894442603038166BBB5d`
