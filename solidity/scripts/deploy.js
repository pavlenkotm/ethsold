const hre = require("hardhat");

async function main() {
  console.log("Начинается деплой контрактов...\n");

  // Получение deployer аккаунта
  const [deployer] = await hre.ethers.getSigners();
  console.log("Деплой с аккаунта:", deployer.address);
  console.log("Баланс аккаунта:", (await hre.ethers.provider.getBalance(deployer.address)).toString(), "\n");

  // Деплой Voting контракта
  console.log("Деплой Voting контракта...");
  const Voting = await hre.ethers.getContractFactory("Voting");
  const voting = await Voting.deploy();
  await voting.waitForDeployment();
  console.log("Voting развернут по адресу:", await voting.getAddress(), "\n");

  // Деплой Crowdfunding контракта
  console.log("Деплой Crowdfunding контракта...");
  const Crowdfunding = await hre.ethers.getContractFactory("Crowdfunding");
  const crowdfunding = await Crowdfunding.deploy();
  await crowdfunding.waitForDeployment();
  console.log("Crowdfunding развернут по адресу:", await crowdfunding.getAddress(), "\n");

  // Деплой NFTMarketplace контракта
  console.log("Деплой NFTMarketplace контракта...");
  const NFTMarketplace = await hre.ethers.getContractFactory("NFTMarketplace");
  const nftMarketplace = await NFTMarketplace.deploy();
  await nftMarketplace.waitForDeployment();
  console.log("NFTMarketplace развернут по адресу:", await nftMarketplace.getAddress(), "\n");

  // Деплой SimpleToken контракта
  console.log("Деплой SimpleToken контракта...");
  const SimpleToken = await hre.ethers.getContractFactory("SimpleToken");
  const simpleToken = await SimpleToken.deploy(
    "Test Token",
    "TEST",
    18,
    1000000,
    true,
    true
  );
  await simpleToken.waitForDeployment();
  console.log("SimpleToken развернут по адресу:", await simpleToken.getAddress(), "\n");

  // Деплой Escrow контракта
  console.log("Деплой Escrow контракта...");
  const Escrow = await hre.ethers.getContractFactory("Escrow");
  const escrow = await Escrow.deploy();
  await escrow.waitForDeployment();
  console.log("Escrow развернут по адресу:", await escrow.getAddress(), "\n");

  // Деплой Lottery контракта
  console.log("Деплой Lottery контракта...");
  const Lottery = await hre.ethers.getContractFactory("Lottery");
  const lottery = await Lottery.deploy();
  await lottery.waitForDeployment();
  console.log("Lottery развернут по адресу:", await lottery.getAddress(), "\n");

  // Деплой DAO контракта
  console.log("Деплой DAO контракта...");
  const DAO = await hre.ethers.getContractFactory("DAO");
  const dao = await DAO.deploy();
  await dao.waitForDeployment();
  console.log("DAO развернут по адресу:", await dao.getAddress(), "\n");

  // Деплой Staking контракта
  console.log("Деплой Staking контракта...");
  const Staking = await hre.ethers.getContractFactory("Staking");
  const staking = await Staking.deploy();
  await staking.waitForDeployment();
  console.log("Staking развернут по адресу:", await staking.getAddress(), "\n");

  // Деплой MultiSigWallet контракта
  console.log("Деплой MultiSigWallet контракта...");
  const MultiSigWallet = await hre.ethers.getContractFactory("MultiSigWallet");
  const owners = [deployer.address]; // Можно добавить больше адресов
  const requiredConfirmations = 1;
  const multiSigWallet = await MultiSigWallet.deploy(owners, requiredConfirmations);
  await multiSigWallet.waitForDeployment();
  console.log("MultiSigWallet развернут по адресу:", await multiSigWallet.getAddress(), "\n");

  // Деплой Auction контракта
  console.log("Деплой Auction контракта...");
  const Auction = await hre.ethers.getContractFactory("Auction");
  const auction = await Auction.deploy();
  await auction.waitForDeployment();
  console.log("Auction развернут по адресу:", await auction.getAddress(), "\n");

  console.log("\n=== Все контракты успешно развернуты! ===\n");
  console.log("Сводка адресов:");
  console.log("Voting:", await voting.getAddress());
  console.log("Crowdfunding:", await crowdfunding.getAddress());
  console.log("NFTMarketplace:", await nftMarketplace.getAddress());
  console.log("SimpleToken:", await simpleToken.getAddress());
  console.log("Escrow:", await escrow.getAddress());
  console.log("Lottery:", await lottery.getAddress());
  console.log("DAO:", await dao.getAddress());
  console.log("Staking:", await staking.getAddress());
  console.log("MultiSigWallet:", await multiSigWallet.getAddress());
  console.log("Auction:", await auction.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
