# Scripts Directory

Коллекция скриптов для развертывания и взаимодействия со смарт-контрактами.

## Deployment Scripts

### deploy-voting.js
Разворачивает контракт Voting.

```bash
npx hardhat run scripts/deploy-voting.js --network <network>
```

### deploy-crowdfunding.js
Разворачивает контракт Crowdfunding.

```bash
npx hardhat run scripts/deploy-crowdfunding.js --network <network>
```

### deploy-nft.js
Разворачивает контракт SimpleNFT.

```bash
npx hardhat run scripts/deploy-nft.js --network <network>
```

### deploy-all.js
Разворачивает все контракты за один раз.

```bash
npx hardhat run scripts/deploy-all.js --network <network>
```

## Example Scripts

### example-voting.js
Демонстрирует полный цикл использования контракта Voting:
- Регистрация избирателей
- Создание предложения
- Голосование
- Просмотр результатов

```bash
npx hardhat run scripts/example-voting.js --network localhost
```

### example-crowdfunding.js
Демонстрирует использование контракта Crowdfunding:
- Создание проекта
- Внесение средств
- Проверка статуса
- Вывод средств

```bash
npx hardhat run scripts/example-crowdfunding.js --network localhost
```

### example-nft.js
Демонстрирует использование контракта SimpleNFT:
- Минт NFT
- Передача токенов
- Approval операции
- Вывод средств

```bash
npx hardhat run scripts/example-nft.js --network localhost
```

## Utilities

### utils/helpers.js
Вспомогательные функции для работы с контрактами:

- `formatAddress(address)` - Форматирование адреса
- `waitForConfirmations(tx, confirmations)` - Ожидание подтверждений
- `getGasPrice()` - Получение текущей цены gas
- `estimateTransactionCost(contract, method, args)` - Оценка стоимости
- `getBalance(address)` - Получение баланса
- `saveDeployment(contractName, address, deployer)` - Сохранение деплоя
- `loadDeployment(contractName)` - Загрузка информации о деплое
- `printNetworkInfo()` - Вывод информации о сети
- `verifyContract(address, constructorArguments)` - Верификация на Etherscan
- `daysToSeconds(days)` - Конвертация дней в секунды
- `formatTimestamp(timestamp)` - Форматирование timestamp

#### Пример использования:

```javascript
const { getBalance, formatAddress } = require('./utils/helpers');

const balance = await getBalance(address);
console.log(`Balance of ${formatAddress(address)}: ${balance} ETH`);
```

## Сети

Доступные сети (настроены в `hardhat.config.js`):

- `hardhat` - Локальная сеть Hardhat (по умолчанию)
- `localhost` - Локальная нода Hardhat
- `sepolia` - Sepolia testnet
- `mainnet` - Ethereum mainnet

## Общие Советы

### 1. Тестирование на локальной сети

```bash
# Терминал 1: Запуск локальной ноды
npx hardhat node

# Терминал 2: Запуск скриптов
npx hardhat run scripts/deploy-all.js --network localhost
npx hardhat run scripts/example-voting.js --network localhost
```

### 2. Проверка gas costs

Все deployment скрипты выводят информацию о использованном gas:

```bash
npx hardhat run scripts/deploy-voting.js --network sepolia
# Output: Gas used: 2345678
```

### 3. Сохранение адресов контрактов

Deployment скрипты автоматически сохраняют адреса в папку `deployments/`:

```
deployments/
├── voting-deployment.json
├── crowdfunding-deployment.json
├── nft-deployment.json
└── all-contracts.json
```

### 4. Верификация контрактов

После деплоя в testnet/mainnet, верифицируйте контракты:

```bash
npx hardhat verify --network sepolia DEPLOYED_CONTRACT_ADDRESS
```

## Создание Своих Скриптов

Шаблон для нового скрипта:

```javascript
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Working with account:", deployer.address);

  // Ваш код здесь

  console.log("Script completed!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

## Troubleshooting

### Ошибка: "Network not found"
Проверьте, что сеть настроена в `hardhat.config.js` и правильно указано имя.

### Ошибка: "Insufficient funds"
Убедитесь, что на аккаунте есть средства для gas.

### Ошибка: "Contract not found"
Сначала выполните компиляцию: `npx hardhat compile`

### Ошибка: "Nonce too low"
Очистите кэш: `npx hardhat clean`

## Полезные Команды

```bash
# Компиляция контрактов
npx hardhat compile

# Очистка артефактов
npx hardhat clean

# Запуск консоли
npx hardhat console --network <network>

# Список аккаунтов
npx hardhat accounts

# Проверка размера контракта
npx hardhat size-contracts
```

## Дополнительные Ресурсы

- [Hardhat Scripts Documentation](https://hardhat.org/guides/scripts.html)
- [Ethers.js Documentation](https://docs.ethers.org/)
- [Deployment Guide](../docs/DEPLOYMENT.md)

---

Для вопросов см. [FAQ](../docs/FAQ.md) или создайте issue.
