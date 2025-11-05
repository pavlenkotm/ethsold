const hre = require("hardhat");

async function main() {
  console.log("Deploying SimpleNFT contract...");

  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", hre.ethers.formatEther(balance), "ETH");

  // Параметры NFT коллекции
  const name = "My Awesome NFT";
  const symbol = "MNFT";
  const maxSupply = 1000;
  const mintPrice = hre.ethers.parseEther("0.01"); // 0.01 ETH

  console.log("\nNFT Collection Parameters:");
  console.log("Name:", name);
  console.log("Symbol:", symbol);
  console.log("Max Supply:", maxSupply);
  console.log("Mint Price:", hre.ethers.formatEther(mintPrice), "ETH\n");

  const SimpleNFT = await hre.ethers.getContractFactory("SimpleNFT");
  const nft = await SimpleNFT.deploy(name, symbol, maxSupply, mintPrice);

  await nft.waitForDeployment();

  const address = await nft.getAddress();
  console.log("SimpleNFT contract deployed to:", address);

  // Сохранение адреса контракта
  const fs = require("fs");
  const deploymentInfo = {
    network: hre.network.name,
    address: address,
    deployer: deployer.address,
    name: name,
    symbol: symbol,
    maxSupply: maxSupply,
    mintPrice: hre.ethers.formatEther(mintPrice),
    timestamp: new Date().toISOString()
  };

  if (!fs.existsSync("./deployments")) {
    fs.mkdirSync("./deployments");
  }

  fs.writeFileSync(
    "./deployments/nft-deployment.json",
    JSON.stringify(deploymentInfo, null, 2)
  );

  console.log("Deployment info saved to deployments/nft-deployment.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
