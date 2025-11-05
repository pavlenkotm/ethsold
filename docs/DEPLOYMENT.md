# Deployment Guide

Руководство по развертыванию смарт-контрактов в различных сетях Ethereum.

## Подготовка

### 1. Установка зависимостей

```bash
npm install
```

### 2. Настройка окружения

Создайте `.env` файл на основе `.env.example`:

```bash
cp .env.example .env
```

Заполните переменные окружения:

```env
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
MAINNET_RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID
PRIVATE_KEY=your_private_key_here
ETHERSCAN_API_KEY=your_etherscan_api_key
```

**⚠️ ВАЖНО:** Никогда не коммитьте `.env` файл с реальными ключами!

### 3. Компиляция контрактов

```bash
npx hardhat compile
```

## Развертывание в Локальной Сети

### Запуск локальной ноды

```bash
npx hardhat node
```

В отдельном терминале:

```bash
# Деплой всех контрактов
npx hardhat run scripts/deploy-all.js --network localhost

# Или отдельно
npx hardhat run scripts/deploy-voting.js --network localhost
npx hardhat run scripts/deploy-crowdfunding.js --network localhost
```

## Развертывание в Testnet (Sepolia)

### 1. Получите тестовый ETH

Получите тестовый ETH для Sepolia:
- [Sepolia Faucet](https://sepoliafaucet.com/)
- [Alchemy Sepolia Faucet](https://sepoliafaucet.com/)

### 2. Разверните контракты

```bash
# Все контракты
npx hardhat run scripts/deploy-all.js --network sepolia

# Voting
npx hardhat run scripts/deploy-voting.js --network sepolia

# Crowdfunding
npx hardhat run scripts/deploy-crowdfunding.js --network sepolia
```

### 3. Верификация контрактов

После развертывания верифицируйте контракт на Etherscan:

```bash
npx hardhat verify --network sepolia DEPLOYED_CONTRACT_ADDRESS
```

## Развертывание в Mainnet

**⚠️ КРИТИЧЕСКИ ВАЖНО:**
- Тщательно протестируйте на testnet
- Проведите аудит безопасности
- Убедитесь, что у вас достаточно ETH для gas
- Дважды проверьте все параметры

### 1. Проверка баланса

Убедитесь, что у вас достаточно ETH:

```bash
# В консоли Hardhat
npx hardhat console --network mainnet

> const balance = await ethers.provider.getBalance("YOUR_ADDRESS")
> ethers.formatEther(balance)
```

### 2. Деплой

```bash
npx hardhat run scripts/deploy-all.js --network mainnet
```

### 3. Верификация

```bash
npx hardhat verify --network mainnet DEPLOYED_CONTRACT_ADDRESS
```

## Примеры использования

После развертывания, протестируйте контракты:

```bash
# Пример использования Voting
npx hardhat run scripts/example-voting.js --network sepolia

# Пример использования Crowdfunding
npx hardhat run scripts/example-crowdfunding.js --network sepolia
```

## Взаимодействие с Развернутыми Контрактами

### Через Hardhat Console

```bash
npx hardhat console --network sepolia
```

```javascript
// Подключение к контракту
const Voting = await ethers.getContractFactory("Voting")
const voting = await Voting.attach("CONTRACT_ADDRESS")

// Вызов функций
await voting.registerVoter("0x...")
await voting.createProposal("Proposal description")
```

### Через Etherscan

1. Откройте контракт на Etherscan
2. Перейдите на вкладку "Write Contract"
3. Подключите MetaMask
4. Вызывайте функции через UI

## Оценка Gas Costs

Перед развертыванием в mainnet, проверьте стоимость:

```bash
npx hardhat run scripts/deploy-all.js --network sepolia
```

Умножьте использованный gas на текущую цену gas в mainnet.

## Troubleshooting

### Ошибка: insufficient funds

- Убедитесь, что у вас достаточно ETH на балансе
- Проверьте правильность адреса кошелька

### Ошибка: nonce too low

```bash
# Сброс nonce
npx hardhat clean
rm -rf cache artifacts
```

### Ошибка: replacement transaction underpriced

Увеличьте gas price в hardhat.config.js:

```javascript
networks: {
  sepolia: {
    url: process.env.SEPOLIA_RPC_URL,
    accounts: [process.env.PRIVATE_KEY],
    gasPrice: ethers.parseUnits("50", "gwei")
  }
}
```

## Мониторинг

После развертывания:

1. Сохраните адреса контрактов
2. Настройте мониторинг событий
3. Подпишитесь на алерты Etherscan
4. Регулярно проверяйте активность контрактов

## Полезные Ссылки

- [Hardhat Documentation](https://hardhat.org/docs)
- [Etherscan](https://etherscan.io)
- [Gas Tracker](https://etherscan.io/gastracker)
- [Sepolia Faucet](https://sepoliafaucet.com/)

## Контрольный Список Деплоя

- [ ] Код откомпилирован без ошибок
- [ ] Все тесты проходят
- [ ] Контракты протестированы на testnet
- [ ] Проведен аудит безопасности (для mainnet)
- [ ] Настроены переменные окружения
- [ ] Достаточно ETH для gas
- [ ] Сохранены адреса контрактов
- [ ] Контракты верифицированы на Etherscan
- [ ] Настроен мониторинг
