const { Connection, clusterApiUrl, PublicKey } = require('@solana/web3.js');

async function getNftOwner(mintAddressString) {
  // Connect to Solana Devnet
  const connection = new Connection(clusterApiUrl('devnet'));

  // Convert the mint address string to a PublicKey
  const mintAddress = new PublicKey(mintAddressString);

  // Get the largest token accounts for the given mint (should include the NFT's token account)
  const largestAccounts = await connection.getTokenLargestAccounts(mintAddress);
  if (!largestAccounts.value || largestAccounts.value.length === 0) {
    console.log("No token accounts found for this mint.");
    return;
  }
  
  // Typically, the account holding the NFT will be the first (and only) one with a balance of 1
  const tokenAccountAddress = largestAccounts.value[0].address;
  console.log("Token Account Address:", tokenAccountAddress.toBase58());

  // Fetch the parsed account info for the token account
  const accountInfo = await connection.getParsedAccountInfo(tokenAccountAddress);
  if (accountInfo.value === null) {
    console.log("Unable to fetch account info.");
    return;
  }

  // The owner of this token account is the current owner of the NFT.
  const ownerAddress = accountInfo.value.data.parsed.info.owner;
  console.log("NFT Owner Address:", ownerAddress);
}

// Replace with your NFT's mint address
getNftOwner('9JmzCUAgWQq935NnipCEAQYL5SRryJ5T4VewRXnNq6Fu')
  .catch(err => console.error(err));
