const hre = require("hardhat");

async function main() {
  console.log("=================================");
  console.log("SimpleNFT Contract Example Usage");
  console.log("=================================\n");

  // Get signers
  const [owner, user1, user2] = await hre.ethers.getSigners();
  console.log("Owner:", owner.address);
  console.log("User1:", user1.address);
  console.log("User2:", user2.address, "\n");

  // Deploy contract
  console.log("Deploying SimpleNFT contract...");
  const SimpleNFT = await hre.ethers.getContractFactory("SimpleNFT");
  const nft = await SimpleNFT.deploy(
    "Example NFT",
    "ENFT",
    100, // max supply
    hre.ethers.parseEther("0.01") // mint price
  );
  await nft.waitForDeployment();
  const address = await nft.getAddress();
  console.log("✓ SimpleNFT deployed to:", address, "\n");

  // Owner mints NFT for free
  console.log("Owner minting NFT...");
  await nft.connect(owner).ownerMint(
    user1.address,
    "ipfs://QmExample1/metadata.json"
  );
  console.log("✓ NFT #0 minted to User1\n");

  // User1 mints NFT by paying
  console.log("User1 minting NFT by paying...");
  await nft.connect(user1).mint(
    "ipfs://QmExample2/metadata.json",
    { value: hre.ethers.parseEther("0.01") }
  );
  console.log("✓ NFT #1 minted to User1\n");

  // Check balances
  console.log("Checking balances...");
  const user1Balance = await nft.balanceOf(user1.address);
  console.log("User1 NFT balance:", user1Balance.toString());

  const totalSupply = await nft.totalSupply();
  console.log("Total NFTs minted:", totalSupply.toString(), "\n");

  // Get NFT info
  console.log("Getting NFT #0 info...");
  const owner0 = await nft.ownerOf(0);
  const uri0 = await nft.tokenURI(0);
  console.log("Owner of NFT #0:", owner0);
  console.log("URI of NFT #0:", uri0, "\n");

  // Transfer NFT
  console.log("User1 transferring NFT #0 to User2...");
  await nft.connect(user1).transferFrom(user1.address, user2.address, 0);
  console.log("✓ NFT #0 transferred to User2\n");

  // Check new owner
  const newOwner = await nft.ownerOf(0);
  console.log("New owner of NFT #0:", newOwner);

  const user2Balance = await nft.balanceOf(user2.address);
  console.log("User2 NFT balance:", user2Balance.toString(), "\n");

  // Approve
  console.log("User2 approving User1 for NFT #0...");
  await nft.connect(user2).approve(user1.address, 0);
  console.log("✓ User1 approved for NFT #0");

  const approved = await nft.getApproved(0);
  console.log("Approved address for NFT #0:", approved, "\n");

  // Set approval for all
  console.log("User2 setting approval for all to User1...");
  await nft.connect(user2).setApprovalForAll(user1.address, true);
  console.log("✓ User1 approved for all User2's NFTs");

  const isApprovedForAll = await nft.isApprovedForAll(user2.address, user1.address);
  console.log("User1 approved for all:", isApprovedForAll, "\n");

  // Contract balance and withdraw
  const contractBalance = await nft.getContractBalance();
  console.log("Contract balance:", hre.ethers.formatEther(contractBalance), "ETH");

  if (contractBalance > 0) {
    console.log("\nOwner withdrawing funds...");
    await nft.connect(owner).withdraw();
    console.log("✓ Funds withdrawn to owner\n");
  }

  console.log("=================================");
  console.log("Example completed successfully!");
  console.log("=================================");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
