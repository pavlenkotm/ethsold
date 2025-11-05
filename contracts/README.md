# Smart Contracts

Этот каталог содержит смарт-контракты на Solidity.

## Контракты

### Voting.sol
Децентрализованная система голосования.

**Основные функции:**
- `registerVoter(address)` - Регистрация избирателя (только владелец)
- `createProposal(string)` - Создание нового предложения
- `vote(uint256, bool)` - Голосование за или против
- `getProposal(uint256)` - Получение информации о предложении
- `executeProposal(uint256)` - Завершение голосования

**Использование:**
```solidity
Voting voting = new Voting();
voting.registerVoter(voterAddress);
voting.createProposal("Increase budget");
voting.vote(0, true); // Vote FOR
```

**Адрес:** см. `deployments/voting-*.json` после деплоя

---

### Crowdfunding.sol
Платформа краудфандинга с автоматическим возвратом средств.

**Основные функции:**
- `createProject(string, string, uint256, uint256)` - Создание проекта
- `contribute(uint256) payable` - Внесение средств
- `withdrawFunds(uint256)` - Вывод средств (при успехе)
- `refund(uint256)` - Возврат средств (при неудаче)
- `getProject(uint256)` - Информация о проекте

**Использование:**
```solidity
Crowdfunding cf = new Crowdfunding();
cf.createProject("My Project", "Description", 10 ether, 30);
cf.contribute{value: 1 ether}(0);
```

**Адрес:** см. `deployments/crowdfunding-*.json` после деплоя

---

### SimpleNFT.sol
Простая реализация NFT контракта (ERC721-подобный).

**Основные функции:**
- `mint(string) payable` - Минт NFT (платный)
- `ownerMint(address, string)` - Минт владельцем (бесплатно)
- `transferFrom(address, address, uint256)` - Передача NFT
- `approve(address, uint256)` - Approve для токена
- `setApprovalForAll(address, bool)` - Approve для всех токенов
- `withdraw()` - Вывод средств владельцем

**Использование:**
```solidity
SimpleNFT nft = new SimpleNFT("My NFT", "MNFT", 1000, 0.01 ether);
nft.mint{value: 0.01 ether}("ipfs://...");
nft.transferFrom(from, to, tokenId);
```

**Адрес:** см. `deployments/nft-*.json` после деплоя

---

## Архитектура Контрактов

### Общие Паттерны

Все контракты используют:
- **Модификаторы доступа** для ограничения функций
- **События** для логирования операций
- **Require проверки** для валидации
- **Solidity 0.8+** встроенная защита от overflow/underflow

### Структура Файлов

```
contracts/
├── Voting.sol          # Система голосования
├── Crowdfunding.sol    # Краудфандинг
└── SimpleNFT.sol       # NFT контракт
```

## Компиляция

```bash
npx hardhat compile
```

Скомпилированные контракты сохраняются в:
- `artifacts/` - ABI и bytecode
- `cache/` - Кэш компиляции

## Деплой

См. скрипты в папке `scripts/`:
- `deploy-voting.js`
- `deploy-crowdfunding.js`
- `deploy-nft.js`
- `deploy-all.js`

```bash
npx hardhat run scripts/deploy-voting.js --network sepolia
```

## Тестирование

Тесты находятся в папке `test/`:
- `test/Voting.test.js`
- `test/Crowdfunding.test.js`

```bash
npx hardhat test
```

Запуск конкретного теста:
```bash
npx hardhat test test/Voting.test.js
```

## Верификация

После деплоя верифицируйте контракт на Etherscan:

```bash
npx hardhat verify --network sepolia CONTRACT_ADDRESS
```

## Оценка Gas

Проверьте стоимость операций:

```bash
npx hardhat test
# Включите gas reporter в hardhat.config.js
```

## Безопасность

### Аудит

Эти контракты НЕ прошли профессиональный аудит. Используйте на свой риск.

Для production рекомендуем аудит от:
- ConsenSys Diligence
- Trail of Bits
- OpenZeppelin
- Hacken

### Известные Ограничения

**Voting:**
- Нет защиты от sybil атак
- Централизованная регистрация избирателей
- Невозможно отозвать голос

**Crowdfunding:**
- Создатель должен сам вызвать withdrawFunds
- Спонсоры должны сами вызвать refund
- Нет milestone-based funding

**SimpleNFT:**
- Упрощенная реализация ERC721
- Нет поддержки royalties
- Нет безопасных проверок для контрактов-получателей

### Best Practices

При использовании:
1. ✅ Тестируйте на testnet
2. ✅ Проводите аудит
3. ✅ Используйте multisig для owner функций
4. ✅ Устанавливайте разумные лимиты
5. ✅ Мониторьте события контракта

## Расширение Контрактов

### Добавление Новых Функций

1. Измените контракт в `contracts/`
2. Обновите тесты в `test/`
3. Добавьте примеры в `scripts/`
4. Обновите документацию

### Создание Нового Контракта

Шаблон:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyContract {
    address public owner;

    event SomethingHappened(address indexed user);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function doSomething() external onlyOwner {
        // Your logic
        emit SomethingHappened(msg.sender);
    }
}
```

## Взаимодействие

### Через Hardhat Console

```bash
npx hardhat console --network sepolia
```

```javascript
const Voting = await ethers.getContractFactory("Voting");
const voting = await Voting.attach("CONTRACT_ADDRESS");
await voting.proposalCount();
```

### Через Ethers.js

```javascript
const { ethers } = require("ethers");
const provider = new ethers.JsonRpcProvider(RPC_URL);
const contract = new ethers.Contract(ADDRESS, ABI, provider);
```

### Через Web3.js

```javascript
const Web3 = require("web3");
const web3 = new Web3(RPC_URL);
const contract = new web3.eth.Contract(ABI, ADDRESS);
```

## Оптимизация

См. [docs/GAS_OPTIMIZATION.md](../docs/GAS_OPTIMIZATION.md) для советов по оптимизации gas.

Основные методы:
- Упаковка storage переменных
- Использование calldata вместо memory
- Кэширование значений из storage
- Оптимизация циклов

## Troubleshooting

### Контракт не компилируется
- Проверьте версию Solidity
- Убедитесь, что синтаксис корректен
- Проверьте импорты

### Ошибка при деплое
- Проверьте баланс аккаунта
- Увеличьте gas limit
- Проверьте правильность параметров конструктора

### Функция reverts
- Проверьте require условия
- Убедитесь в правильности доступа (modifiers)
- Проверьте достаточность средств

## Полезные Команды

```bash
# Размер контрактов
npx hardhat size-contracts

# Очистка артефактов
npx hardhat clean

# Список сетей
npx hardhat node

# Плоский файл для верификации
npx hardhat flatten contracts/Voting.sol > Voting_flat.sol
```

## Ресурсы

- [Solidity Documentation](https://docs.soliditylang.org/)
- [Hardhat Documentation](https://hardhat.org/docs)
- [Ethers.js Documentation](https://docs.ethers.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Ethereum Stack Exchange](https://ethereum.stackexchange.com/)

---

Для вопросов см. [FAQ](../docs/FAQ.md) или [SECURITY.md](../SECURITY.md)
