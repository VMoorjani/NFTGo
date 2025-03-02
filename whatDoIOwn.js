import { PublicKey, Connection, clusterApiUrl } from '@solana/web3.js';
import { Metaplex } from '@metaplex-foundation/js';

async function viewNFTs(pubkeyString) {
  // 1. Establish a connection (e.g., to Devnet)
  const connection = new Connection(clusterApiUrl('devnet'));

  // 2. Initialize Metaplex
  const metaplex = Metaplex.make(connection);

  // 3. Convert the string to a PublicKey
  const owner = new PublicKey(pubkeyString);

  // 4. Retrieve all NFTs for the given owner
  const nfts = await metaplex.nfts().findAllByOwner({ owner });
  
  return nfts;
}

// Replace with the desired public key
const pubkey = "8GbNyCFqJW1aGVLCyg7aLMjJW7QLBakPGvVJ1GwKeGbq";

viewNFTs(pubkey)
  .then(nfts => {
    console.log("NFTs owned by the public key:", nfts);
  })
  .catch(err => {
    console.error(err);
  });
