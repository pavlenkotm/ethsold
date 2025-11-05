const hre = require("hardhat");
const fs = require("fs");

async function main() {
  console.log("=================================");
  console.log("Deploying all contracts...");
  console.log("=================================\n");

  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", hre.ethers.formatEther(balance), "ETH\n");

  const deployments = {};

  // Deploy Voting
  console.log("1. Deploying Voting contract...");
  const Voting = await hre.ethers.getContractFactory("Voting");
  const voting = await Voting.deploy();
  await voting.waitForDeployment();
  const votingAddress = await voting.getAddress();
  console.log("✓ Voting deployed to:", votingAddress, "\n");

  deployments.voting = {
    name: "Voting",
    address: votingAddress
  };

  // Deploy Crowdfunding
  console.log("2. Deploying Crowdfunding contract...");
  const Crowdfunding = await hre.ethers.getContractFactory("Crowdfunding");
  const crowdfunding = await Crowdfunding.deploy();
  await crowdfunding.waitForDeployment();
  const crowdfundingAddress = await crowdfunding.getAddress();
  console.log("✓ Crowdfunding deployed to:", crowdfundingAddress, "\n");

  deployments.crowdfunding = {
    name: "Crowdfunding",
    address: crowdfundingAddress
  };

  // Save all deployment info
  const allDeploymentInfo = {
    network: hre.network.name,
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    contracts: deployments
  };

  if (!fs.existsSync("./deployments")) {
    fs.mkdirSync("./deployments");
  }

  fs.writeFileSync(
    "./deployments/all-contracts.json",
    JSON.stringify(allDeploymentInfo, null, 2)
  );

  console.log("=================================");
  console.log("All contracts deployed successfully!");
  console.log("=================================");
  console.log("\nDeployment info saved to deployments/all-contracts.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
