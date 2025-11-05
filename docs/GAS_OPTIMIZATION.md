# Gas Optimization Guide

Руководство по оптимизации газа для смарт-контрактов Ethereum.

## Почему это важно?

Каждая операция в Ethereum стоит газ. Оптимизация газа:
- Снижает стоимость транзакций для пользователей
- Делает контракты более конкурентоспособными
- Улучшает UX

## Общие Принципы

### 1. Используйте подходящие типы данных

```solidity
// ❌ Неоптимально
uint256 public smallNumber = 1;

// ✅ Оптимально (если значение <= 255)
uint8 public smallNumber = 1;
```

**Но помните:** Solidity упаковывает переменные по 32 байта. Используйте uint256 по умолчанию, если не упаковываете несколько переменных в один слот.

### 2. Упаковка переменных

```solidity
// ❌ Неоптимально - 3 storage slots
contract Unoptimized {
    uint256 a;      // slot 0
    uint8 b;        // slot 1
    uint256 c;      // slot 2
}

// ✅ Оптимально - 2 storage slots
contract Optimized {
    uint256 a;      // slot 0
    uint256 c;      // slot 1
    uint8 b;        // slot 1 (упаковано с c)
}
```

### 3. Кэширование значений из storage

```solidity
// ❌ Неоптимально - множественное чтение из storage
function bad() public view returns (uint256) {
    return array.length + array.length + array.length;
}

// ✅ Оптимально - одно чтение из storage
function good() public view returns (uint256) {
    uint256 length = array.length;
    return length + length + length;
}
```

### 4. Используйте calldata вместо memory

```solidity
// ❌ Неоптимально
function processData(uint256[] memory data) external {
    // ...
}

// ✅ Оптимально для external функций
function processData(uint256[] calldata data) external {
    // ...
}
```

### 5. Избегайте ненужных проверок

```solidity
// ❌ Неоптимально
require(amount > 0, "Amount must be positive");
require(amount <= balance, "Insufficient balance");

// ✅ Оптимально - вторая проверка покрывает первую
require(amount <= balance && amount > 0, "Invalid amount");
```

### 6. Short-circuit операторы

```solidity
// ✅ Более дешевые проверки первыми
require(msg.sender == owner && expensiveCheck(), "Failed");
```

### 7. Используйте events вместо storage

```solidity
// ❌ Неоптимально - хранение истории в storage
mapping(uint256 => Transaction) public transactions;

// ✅ Оптимально - использование events
event TransactionExecuted(uint256 id, address user, uint256 amount);
```

## Оптимизация Циклов

### 1. Кэширование длины массива

```solidity
// ❌ Неоптимально
for (uint i = 0; i < array.length; i++) {
    // array.length читается каждую итерацию
}

// ✅ Оптимально
uint256 length = array.length;
for (uint i = 0; i < length; i++) {
    // length кэширован
}
```

### 2. Инкремент без проверки

```solidity
// ❌ Стандартный инкремент
for (uint i = 0; i < length; i++) {
    // ...
}

// ✅ Unchecked инкремент (безопасно если i не переполнится)
for (uint i = 0; i < length;) {
    // ...
    unchecked { ++i; }
}
```

### 3. Используйте ++i вместо i++

```solidity
// ❌ i++ создает временную переменную
for (uint i = 0; i < length; i++) {}

// ✅ ++i более эффективен
for (uint i = 0; i < length; ++i) {}
```

## Оптимизация Строк

### 1. Используйте bytes32 для коротких строк

```solidity
// ❌ Дороже для коротких строк
string public name = "Alice";

// ✅ Дешевле для строк <= 32 байт
bytes32 public name = "Alice";
```

### 2. Проверка длины строки

```solidity
// ❌ Неоптимально
require(keccak256(bytes(str)) != keccak256(bytes("")), "Empty string");

// ✅ Оптимально
require(bytes(str).length > 0, "Empty string");
```

## Оптимизация Mappings

### 1. Используйте mapping вместо array где возможно

```solidity
// ❌ Поиск в массиве - O(n)
address[] public users;

// ✅ Поиск в mapping - O(1)
mapping(address => bool) public isUser;
```

### 2. Удаление из mapping

```solidity
// Удаление освобождает газ
delete mapping[key];
```

## Функции и Модификаторы

### 1. External vs Public

```solidity
// ❌ Public - дороже
function getData(uint256[] memory data) public {}

// ✅ External - дешевле (использует calldata)
function getData(uint256[] calldata data) external {}
```

### 2. View и Pure функции

```solidity
// Не стоят газа при вызове извне
function calculate(uint a, uint b) public pure returns (uint) {
    return a + b;
}
```

### 3. Inline вместо модификаторов

```solidity
// Модификаторы дублируют код
modifier onlyOwner() {
    require(msg.sender == owner);
    _;
}

// Иногда лучше использовать internal функцию
function _onlyOwner() internal view {
    require(msg.sender == owner);
}
```

## Конкретные Оптимизации для Наших Контрактов

### Voting Contract

1. **Используйте uint128 для счетчиков голосов**
   - Если не ожидается > 2^128 голосов
   - Можно упаковать votesFor и votesAgainst в один slot

2. **Bitmap для hasVoted**
   - Вместо mapping(address => bool)
   - Экономия на больших числах избирателей

### Crowdfunding Contract

1. **Batch contributions**
   - Позволить пользователям вносить средства за одну транзакцию

2. **Lazy evaluation**
   - Не обновлять percentageFunded при каждом contribution
   - Считать on-demand

### SimpleNFT Contract

1. **Batch minting**
   - Позволить минтить несколько NFT за раз

2. **Использование ERC721A**
   - Для более дешевого batch minting

## Инструменты для Анализа

### 1. Hardhat Gas Reporter

```bash
npm install --save-dev hardhat-gas-reporter
```

```javascript
// hardhat.config.js
module.exports = {
  gasReporter: {
    enabled: true,
    currency: 'USD',
    gasPrice: 21
  }
}
```

### 2. Foundry Gas Snapshots

```bash
forge snapshot
```

### 3. Solidity Visual Auditor

VSCode extension для анализа газа.

## Best Practices Checklist

- [ ] Используйте uint256 по умолчанию (кроме упаковки)
- [ ] Упаковывайте переменные в storage slots
- [ ] Кэшируйте значения из storage
- [ ] Используйте calldata для external функций
- [ ] Оптимизируйте циклы
- [ ] Используйте events вместо storage для истории
- [ ] Используйте mapping вместо array для lookups
- [ ] Делайте функции external вместо public где возможно
- [ ] Проверяйте стоимость gas в тестах
- [ ] Используйте unchecked где безопасно

## Когда НЕ оптимизировать

1. **Читаемость > оптимизация**
   - Не жертвуйте читаемостью ради 100 gas

2. **Безопасность > оптимизация**
   - Не убирайте проверки безопасности

3. **Premature optimization**
   - Сначала работающий код, потом оптимизация

## Ресурсы

- [Solidity Gas Optimization Tips](https://mudit.blog/solidity-gas-optimization-tips/)
- [EVM Codes](https://www.evm.codes/) - стоимость opcodes
- [Solidity Optimizer](https://docs.soliditylang.org/en/latest/internals/optimizer.html)

---

**Помните:** Каждый сэкономленный gas делает ваш контракт доступнее для пользователей!
