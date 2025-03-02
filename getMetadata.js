const { Connection, clusterApiUrl, PublicKey } = require('@solana/web3.js');
const { Metaplex, keypairIdentity } = require('@metaplex-foundation/js');
const fs = require('fs');
const path = require('path');

async function fetchNFTMetadata(mintAddressString) {
  // Set up connection and wallet (reuse your wallet details)
  const connection = new Connection(clusterApiUrl('devnet'));
  const keypairPath = path.join(process.env.HOME, ".config", "solana", "id.json");
  const secretKey = JSON.parse(fs.readFileSync(keypairPath));
  const wallet = require('@solana/web3.js').Keypair.fromSecretKey(new Uint8Array(secretKey));

  // Initialize Metaplex instance
  const metaplex = Metaplex.make(connection).use(keypairIdentity(wallet));

  // Convert mint address string to PublicKey and fetch NFT metadata
  const mintAddress = new PublicKey(mintAddressString);
  const nft = await metaplex.nfts().findByMint({ mintAddress });
  console.log(nft);
}

fetchNFTMetadata('9JmzCUAgWQq935NnipCEAQYL5SRryJ5T4VewRXnNq6Fu')
  .catch(err => console.error(err));
