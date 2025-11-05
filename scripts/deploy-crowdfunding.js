const hre = require("hardhat");

async function main() {
  console.log("Deploying Crowdfunding contract...");

  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", hre.ethers.formatEther(balance), "ETH");

  const Crowdfunding = await hre.ethers.getContractFactory("Crowdfunding");
  const crowdfunding = await Crowdfunding.deploy();

  await crowdfunding.waitForDeployment();

  const address = await crowdfunding.getAddress();
  console.log("Crowdfunding contract deployed to:", address);

  // Сохранение адреса контракта
  const fs = require("fs");
  const deploymentInfo = {
    network: hre.network.name,
    address: address,
    deployer: deployer.address,
    timestamp: new Date().toISOString()
  };

  fs.writeFileSync(
    "./deployments/crowdfunding-deployment.json",
    JSON.stringify(deploymentInfo, null, 2)
  );

  console.log("Deployment info saved to deployments/crowdfunding-deployment.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
