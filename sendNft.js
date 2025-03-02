// import fs from 'fs';
// import path from 'path';
// import {
//   Connection,
//   PublicKey,
//   clusterApiUrl,
//   Keypair,
//   Transaction,
//   sendAndConfirmTransaction
// } from "@solana/web3.js";
// import {
//   getOrCreateAssociatedTokenAccount,
//   createTransferCheckedInstruction,
//   TOKEN_PROGRAM_ID
// } from "@solana/spl-token";

// (async () => {
//   try {
//     // 1. Set up a connection to the Solana Devnet.
//     const connection = new Connection(clusterApiUrl("devnet"), "confirmed");

//     // 2. Load the sender's keypair from the local Solana CLI configuration.
//     const keypairPath = path.join(process.env.HOME, ".config", "solana", "id.json");
//     const secretKey = JSON.parse(fs.readFileSync(keypairPath, 'utf-8'));
//     const currentOwner = Keypair.fromSecretKey(new Uint8Array(secretKey));

//     // 3. Define the NFT mint address and the new owner (recipient) public key.
//     const mint = new PublicKey("CCNbpShSQmvAxL89AaA7EbH5nrYqwKi2yUaykNhMgNqf");
//     const newOwner = new PublicKey("8GbNyCFqJW1aGVLCyg7aLMjJW7QLBakPGvVJ1GwKeGbq");

//     // 4. Get (or create) the sender's associated token account for the NFT.
//     const senderTokenAccount = await getOrCreateAssociatedTokenAccount(
//       connection,
//       currentOwner,         // Payer of the transaction and account creation fees.
//       mint,                 // NFT mint address.
//       currentOwner.publicKey // Owner of the associated token account.
//     );

//     // 5. Get (or create) the recipient's associated token account for the NFT.
//     const recipientTokenAccount = await getOrCreateAssociatedTokenAccount(
//       connection,
//       currentOwner,  // Payer for the account creation (can be adjusted if needed).
//       mint,          // NFT mint address.
//       newOwner       // Recipient's public key.
//     );

//     // 6. Create a transfer instruction.
//     //    For an NFT, we transfer 1 token with 0 decimals.
//     const transferInstruction = createTransferCheckedInstruction(
//       senderTokenAccount.address,   // Source (sender) ATA.
//       mint,                         // Mint address.
//       recipientTokenAccount.address, // Destination (recipient) ATA.
//       currentOwner.publicKey,       // Owner of the source account.
//       1,                            // Amount (1 NFT).
//       0                             // Decimals (NFTs have 0 decimals).
//     );

//     // 7. Build and send the transaction.
//     const transaction = new Transaction().add(transferInstruction);
//     const txSignature = await sendAndConfirmTransaction(
//       connection,
//       transaction,
//       [currentOwner]
//     );

//     console.log("Transaction signature:", txSignature);
//     console.log("NFT successfully transferred!");
//   } catch (error) {
//     console.error("Error sending NFT:", error);
//   }
// })();








// // sendNFT.js
// import fs from 'fs';
// import path from 'path';
// import {
//   Connection,
//   PublicKey,
//   clusterApiUrl,
//   Keypair,
//   Transaction,
//   sendAndConfirmTransaction
// } from "@solana/web3.js";
// import {
//   getOrCreateAssociatedTokenAccount,
//   createTransferCheckedInstruction
// } from "@solana/spl-token";

// async function sendNFT(mintAddressStr, recipientPubKeyStr) {
//   // 1. Set up a connection to the Solana Devnet.
//   const connection = new Connection(clusterApiUrl("devnet"), "confirmed");

//   // 2. Load the sender's keypair from the local Solana CLI configuration.
//   const keypairPath = path.join(process.env.HOME, ".config", "solana", "id.json");
//   const secretKey = JSON.parse(fs.readFileSync(keypairPath, 'utf-8'));
//   const currentOwner = Keypair.fromSecretKey(new Uint8Array(secretKey));

//   // 3. Convert provided mint address and recipient public key to PublicKey instances.
//   const mint = new PublicKey(mintAddressStr);
//   const newOwner = new PublicKey(recipientPubKeyStr);

//   // 4. Get (or create) the sender's associated token account for the NFT.
//   const senderTokenAccount = await getOrCreateAssociatedTokenAccount(
//     connection,
//     currentOwner,         // Payer of the transaction and account creation fees.
//     mint,                 // NFT mint address.
//     currentOwner.publicKey // Owner of the associated token account.
//   );

//   // 5. Get (or create) the recipient's associated token account for the NFT.
//   const recipientTokenAccount = await getOrCreateAssociatedTokenAccount(
//     connection,
//     currentOwner,  // Payer for the account creation (can be adjusted if needed).
//     mint,          // NFT mint address.
//     newOwner       // Recipient's public key.
//   );

//   // 6. Create a transfer instruction.
//   //    For an NFT, we transfer 1 token with 0 decimals.
//   const transferInstruction = createTransferCheckedInstruction(
//     senderTokenAccount.address,    // Source (sender) ATA.
//     mint,                          // Mint address.
//     recipientTokenAccount.address, // Destination (recipient) ATA.
//     currentOwner.publicKey,        // Owner of the source account.
//     1,                             // Amount (1 NFT).
//     0                              // Decimals (NFTs have 0 decimals).
//   );

//   // 7. Build and send the transaction.
//   const transaction = new Transaction().add(transferInstruction);
//   const txSignature = await sendAndConfirmTransaction(
//     connection,
//     transaction,
//     [currentOwner]
//   );

//   console.log("Transaction signature:", txSignature);
//   console.log("NFT successfully transferred!");
//   return txSignature;
// }

// // Only execute if this script is run directly
// if (require.main === module) {
//   const [,, mintAddress, recipientPubKey] = process.argv;
//   if (!mintAddress || !recipientPubKey) {
//     console.error("Usage: node sendNFT.js <mintAddress> <recipientPubKey>");
//     process.exit(1);
//   }
//   sendNFT(mintAddress, recipientPubKey)
//     .catch(error => {
//       console.error("Error sending NFT:", error);
//     });
// }

// export { sendNFT };





const fs = require('fs');
const path = require('path');
const {
  Connection,
  PublicKey,
  clusterApiUrl,
  Keypair,
  Transaction,
  sendAndConfirmTransaction
} = require("@solana/web3.js");
const {
  getOrCreateAssociatedTokenAccount,
  createTransferCheckedInstruction
} = require("@solana/spl-token");

async function sendNFT(mintAddressStr, recipientPubKeyStr) {
  const connection = new Connection(clusterApiUrl("devnet"), "confirmed");
  // const keypairPath = path.join(process.env.HOME, ".config", "solana", "id.json");
  // const secretKey = JSON.parse(fs.readFileSync(keypairPath, 'utf-8'));
  const secretKey = [
    231,106,90,226,48,133,142,171,174,87,230,215,199,55,10,165,
    235,84,97,229,92,182,136,10,218,42,93,183,15,28,144,2,135,
    101,147,125,5,161,164,128,22,52,164,224,34,108,235,194,158,
    219,83,52,43,192,224,223,147,55,90,59,50,13,255,254
  ];
  const currentOwner = Keypair.fromSecretKey(new Uint8Array(secretKey));

  const mint = new PublicKey(mintAddressStr);
  const newOwner = new PublicKey(recipientPubKeyStr);

  const senderTokenAccount = await getOrCreateAssociatedTokenAccount(
    connection,
    currentOwner,
    mint,
    currentOwner.publicKey
  );

  const recipientTokenAccount = await getOrCreateAssociatedTokenAccount(
    connection,
    currentOwner,
    mint,
    newOwner
  );

  const transferInstruction = createTransferCheckedInstruction(
    senderTokenAccount.address,
    mint,
    recipientTokenAccount.address,
    currentOwner.publicKey,
    1,
    0
  );

  const transaction = new Transaction().add(transferInstruction);
  const txSignature = await sendAndConfirmTransaction(
    connection,
    transaction,
    [currentOwner]
  );

  console.log("Transaction signature:", txSignature);
  console.log("NFT successfully transferred!");
  return txSignature;
}

// Ensure the function is executed only if run directly
if (require.main === module) {
  const [,, mintAddress, recipientPubKey] = process.argv;
  if (!mintAddress || !recipientPubKey) {
    console.error("Usage: node sendNFT.js <mintAddress> <recipientPubKey>");
    process.exit(1);
  }
  sendNFT(mintAddress, recipientPubKey)
    .catch(error => {
      console.error("Error sending NFT:", error);
    });
}

module.exports = { sendNFT };
