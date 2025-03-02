// createNFT.js
const { Connection, clusterApiUrl, Keypair } = require('@solana/web3.js');
const { Metaplex, keypairIdentity } = require('@metaplex-foundation/js');
const fs = require('fs');
const path = require('path');
const bs58 = require('bs58');
const Irys = require('@irys/sdk'); // New Irys Bundler SDK



async function createNFT(imagePath, name, symbol, description) {
  // 1. Set up a connection to the Solana Devnet.
  // console.log("here1");
  const connection = new Connection(clusterApiUrl('devnet'));
  // console.log("here2");
  // const keypairPath = path.join(process.env.HOME, ".config", "solana", "id.json");
  const secretKey = [
    231,106,90,226,48,133,142,171,174,87,230,215,199,55,10,165,
    235,84,97,229,92,182,136,10,218,42,93,183,15,28,144,2,135,
    101,147,125,5,161,164,128,22,52,164,224,34,108,235,194,158,
    219,83,52,43,192,224,223,147,55,90,59,50,13,255,254
  ];
  
  
  // const secretKey = JSON.parse(fs.readFileSync(keypairPath));
  const wallet = Keypair.fromSecretKey(new Uint8Array(secretKey));
  // console.log("Public Key:", wallet.publicKey.toBase58());

  // Convert secretKey to a base58 string for Irys.
  const irysKey = bs58.encode(new Uint8Array(secretKey));
  // console.log("here3");

  // 2. Define your RPC provider URL (for devnet).
  const providerUrl = 'https://api.devnet.solana.com'; // You can replace this with your preferred devnet RPC

  // 3. Initialize Irys using the new syntax.
  // According to the migration guide, we now use:
  //    network, token, key, and config: { providerUrl }
  const network = "devnet";    // Using devnet for testing
  const token = "solana";      // Token identifier for Solana
  const irys = new Irys({
    network,      // "devnet"
    token,        // "solana"
    key: irysKey, // your private key (in base58)
    config: { providerUrl }, // RPC provider specified in config
  });
  // console.log("here4");

  // Optionally, fund your Irys node (here funding 0.05 SOL in atomic units).
  const fundTx = await irys.fund(irys.utils.toAtomic(0.05));
  // console.log('Fund transaction:', fundTx);

  // 4. Upload the image file to the Irys datachain.
  // This returns a receipt with an id that forms part of the URI.
  const imageReceipt = await irys.uploadFile(imagePath);
  // const imageUri = `https://arweave.net/${imageReceipt.id}`;
  const imageUri = `https://gateway.irys.xyz/${imageReceipt.id}`;

  // console.log('Image uploaded to:', imageUri);

  // 5. Build a metadata JSON object.
  const metadataJson = {
    name,
    symbol,
    description,
    image: imageUri,
  };
  // console.log("Metadata JSON:", JSON.stringify(metadataJson, null, 2));

  // 6. Write metadata JSON to a temporary file.
  const metadataTempPath = path.join(__dirname, 'temp_metadata.json');
  fs.writeFileSync(metadataTempPath, JSON.stringify(metadataJson));

  // 7. Upload the metadata JSON file.
  const metadataReceipt = await irys.uploadFile(metadataTempPath);
  const metadataUri = `https://gateway.irys.xyz/${metadataReceipt.id}`;
  // console.log('Metadata JSON uploaded to:', metadataUri);

  // Clean up the temporary metadata file.
  fs.unlinkSync(metadataTempPath);

  // 8. Initialize Metaplex without the storage plugin.
  const metaplex = Metaplex.make(connection).use(keypairIdentity(wallet));

  // 9. Mint the NFT using the metadata URI.
  const { nft } = await metaplex.nfts().create({
    uri: metadataUri,
    name: name,
    symbol: symbol,
    sellerFeeBasisPoints: 500, // e.g., 5% royalties
    creators: [
      {
        address: wallet.publicKey,
        verified: true,
        share: 100,
      },
    ],
  });

  console.log('NFT created with address:', nft.address.toBase58());
  return nft.address.toBase58();
}

// Only call createNFT if this script is executed directly from the CLI.
if (require.main === module) {
  // Retrieve command-line arguments (node mintNft.js imagePath name symbol description)
  const [,, imagePath, name, symbol, description] = process.argv;
  if (!imagePath || !name || !symbol || !description) {
    console.error("Usage: node mintNft.js <imagePath> <name> <symbol> <description>");
    process.exit(1);
  }
  createNFT(imagePath, name, symbol, description)
    .catch(err => {
      console.error(err);
    });
}

module.exports = { createNFT };
