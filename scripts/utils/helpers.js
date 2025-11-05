const hre = require("hardhat");
const fs = require("fs");

/**
 * Форматирует адрес Ethereum для отображения
 * @param {string} address - Ethereum адрес
 * @returns {string} Отформатированный адрес
 */
function formatAddress(address) {
  return `${address.substring(0, 6)}...${address.substring(address.length - 4)}`;
}

/**
 * Ждет указанное количество подтверждений блоков
 * @param {Object} tx - Transaction object
 * @param {number} confirmations - Количество подтверждений
 */
async function waitForConfirmations(tx, confirmations = 2) {
  console.log(`Waiting for ${confirmations} confirmations...`);
  await tx.wait(confirmations);
  console.log(`✓ Confirmed!`);
}

/**
 * Получает текущую цену gas
 * @returns {Promise<Object>} Gas price info
 */
async function getGasPrice() {
  const feeData = await hre.ethers.provider.getFeeData();
  return {
    gasPrice: feeData.gasPrice,
    maxFeePerGas: feeData.maxFeePerGas,
    maxPriorityFeePerGas: feeData.maxPriorityFeePerGas
  };
}

/**
 * Оценивает стоимость транзакции
 * @param {Object} contract - Contract instance
 * @param {string} method - Method name
 * @param {Array} args - Method arguments
 * @returns {Promise<string>} Estimated cost in ETH
 */
async function estimateTransactionCost(contract, method, args = []) {
  const gasEstimate = await contract[method].estimateGas(...args);
  const feeData = await hre.ethers.provider.getFeeData();
  const cost = gasEstimate * feeData.gasPrice;
  return hre.ethers.formatEther(cost);
}

/**
 * Получает баланс адреса
 * @param {string} address - Ethereum address
 * @returns {Promise<string>} Balance in ETH
 */
async function getBalance(address) {
  const balance = await hre.ethers.provider.getBalance(address);
  return hre.ethers.formatEther(balance);
}

/**
 * Сохраняет информацию о развертывании
 * @param {string} contractName - Name of contract
 * @param {string} address - Contract address
 * @param {Object} deployer - Deployer info
 */
function saveDeployment(contractName, address, deployer) {
  const deploymentInfo = {
    network: hre.network.name,
    contractName,
    address,
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    blockNumber: null // Will be filled after deployment
  };

  const dir = "./deployments";
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  const filename = `${dir}/${contractName.toLowerCase()}-${hre.network.name}.json`;
  fs.writeFileSync(filename, JSON.stringify(deploymentInfo, null, 2));

  console.log(`✓ Deployment info saved to ${filename}`);
  return deploymentInfo;
}

/**
 * Загружает информацию о развертывании
 * @param {string} contractName - Name of contract
 * @returns {Object|null} Deployment info or null
 */
function loadDeployment(contractName) {
  const filename = `./deployments/${contractName.toLowerCase()}-${hre.network.name}.json`;

  if (!fs.existsSync(filename)) {
    return null;
  }

  return JSON.parse(fs.readFileSync(filename, "utf8"));
}

/**
 * Выводит информацию о сети
 */
async function printNetworkInfo() {
  console.log("=================================");
  console.log("Network Information");
  console.log("=================================");
  console.log("Network:", hre.network.name);
  console.log("Chain ID:", (await hre.ethers.provider.getNetwork()).chainId);
  console.log("Block Number:", await hre.ethers.provider.getBlockNumber());

  const feeData = await hre.ethers.provider.getFeeData();
  console.log("Gas Price:", hre.ethers.formatUnits(feeData.gasPrice, "gwei"), "gwei");
  console.log("=================================\n");
}

/**
 * Верифицирует контракт на Etherscan
 * @param {string} address - Contract address
 * @param {Array} constructorArguments - Constructor arguments
 */
async function verifyContract(address, constructorArguments = []) {
  if (hre.network.name === "hardhat" || hre.network.name === "localhost") {
    console.log("Skipping verification on local network");
    return;
  }

  console.log("Verifying contract on Etherscan...");

  try {
    await hre.run("verify:verify", {
      address,
      constructorArguments
    });
    console.log("✓ Contract verified!");
  } catch (error) {
    if (error.message.includes("Already Verified")) {
      console.log("Contract already verified!");
    } else {
      console.error("Verification failed:", error.message);
    }
  }
}

/**
 * Конвертирует дни в секунды
 * @param {number} days - Number of days
 * @returns {number} Seconds
 */
function daysToSeconds(days) {
  return days * 24 * 60 * 60;
}

/**
 * Форматирует timestamp в читаемую дату
 * @param {number} timestamp - Unix timestamp
 * @returns {string} Formatted date
 */
function formatTimestamp(timestamp) {
  return new Date(timestamp * 1000).toLocaleString();
}

module.exports = {
  formatAddress,
  waitForConfirmations,
  getGasPrice,
  estimateTransactionCost,
  getBalance,
  saveDeployment,
  loadDeployment,
  printNetworkInfo,
  verifyContract,
  daysToSeconds,
  formatTimestamp
};
