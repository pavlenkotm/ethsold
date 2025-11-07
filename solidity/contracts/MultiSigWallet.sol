// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MultiSigWallet
 * @dev Мультиподписной кошелек, требующий подтверждения от нескольких владельцев
 */
contract MultiSigWallet {
    // Структура транзакции
    struct Transaction {
        uint256 id;
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
        uint256 createdAt;
    }

    // Переменные состояния
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public requiredConfirmations;

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmations;

    // События
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event OwnerAdded(address indexed owner);
    event OwnerRemoved(address indexed owner);

    event TransactionSubmitted(
        uint256 indexed txId,
        address indexed owner,
        address indexed to,
        uint256 value,
        bytes data
    );

    event TransactionConfirmed(uint256 indexed txId, address indexed owner);
    event ConfirmationRevoked(uint256 indexed txId, address indexed owner);
    event TransactionExecuted(uint256 indexed txId);
    event TransactionFailed(uint256 indexed txId);

    // Модификаторы
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].executed, "Transaction already executed");
        _;
    }

    modifier notConfirmed(uint256 _txId) {
        require(!confirmations[_txId][msg.sender], "Transaction already confirmed");
        _;
    }

    /**
     * @dev Конструктор мультиподписного кошелька
     * @param _owners Адреса владельцев
     * @param _requiredConfirmations Количество требуемых подтверждений
     */
    constructor(address[] memory _owners, uint256 _requiredConfirmations) {
        require(_owners.length > 0, "Owners required");
        require(
            _requiredConfirmations > 0 &&
                _requiredConfirmations <= _owners.length,
            "Invalid number of required confirmations"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");

            isOwner[owner] = true;
            owners.push(owner);

            emit OwnerAdded(owner);
        }

        requiredConfirmations = _requiredConfirmations;
    }

    // Получение средств
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    /**
     * @dev Создание транзакции
     * @param _to Адрес получателя
     * @param _value Сумма в wei
     * @param _data Данные для вызова
     */
    function submitTransaction(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public onlyOwner returns (uint256) {
        require(_to != address(0), "Invalid address");

        uint256 txId = transactions.length;

        transactions.push(
            Transaction({
                id: txId,
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                confirmations: 0,
                createdAt: block.timestamp
            })
        );

        emit TransactionSubmitted(txId, msg.sender, _to, _value, _data);

        // Автоматическое подтверждение от создателя
        confirmTransaction(txId);

        return txId;
    }

    /**
     * @dev Подтверждение транзакции
     * @param _txId ID транзакции
     */
    function confirmTransaction(uint256 _txId)
        public
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
        notConfirmed(_txId)
    {
        confirmations[_txId][msg.sender] = true;
        transactions[_txId].confirmations += 1;

        emit TransactionConfirmed(_txId, msg.sender);

        // Автоматическое выполнение если достаточно подтверждений
        if (transactions[_txId].confirmations >= requiredConfirmations) {
            executeTransaction(_txId);
        }
    }

    /**
     * @dev Отзыв подтверждения
     * @param _txId ID транзакции
     */
    function revokeConfirmation(uint256 _txId)
        public
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        require(confirmations[_txId][msg.sender], "Transaction not confirmed");

        confirmations[_txId][msg.sender] = false;
        transactions[_txId].confirmations -= 1;

        emit ConfirmationRevoked(_txId, msg.sender);
    }

    /**
     * @dev Выполнение транзакции
     * @param _txId ID транзакции
     */
    function executeTransaction(uint256 _txId)
        public
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        Transaction storage transaction = transactions[_txId];

        require(
            transaction.confirmations >= requiredConfirmations,
            "Cannot execute: insufficient confirmations"
        );

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );

        if (success) {
            emit TransactionExecuted(_txId);
        } else {
            transaction.executed = false;
            emit TransactionFailed(_txId);
        }
    }

    /**
     * @dev Получить количество владельцев
     */
    function getOwnerCount() public view returns (uint256) {
        return owners.length;
    }

    /**
     * @dev Получить список всех владельцев
     */
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    /**
     * @dev Получить количество транзакций
     */
    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    /**
     * @dev Получить информацию о транзакции
     * @param _txId ID транзакции
     */
    function getTransaction(uint256 _txId)
        public
        view
        txExists(_txId)
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 numConfirmations,
            uint256 createdAt
        )
    {
        Transaction storage transaction = transactions[_txId];
        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.confirmations,
            transaction.createdAt
        );
    }

    /**
     * @dev Проверить, подтвердил ли владелец транзакцию
     * @param _txId ID транзакции
     * @param _owner Адрес владельца
     */
    function isConfirmed(uint256 _txId, address _owner)
        public
        view
        txExists(_txId)
        returns (bool)
    {
        return confirmations[_txId][_owner];
    }

    /**
     * @dev Получить список подтверждений для транзакции
     * @param _txId ID транзакции
     */
    function getConfirmations(uint256 _txId)
        public
        view
        txExists(_txId)
        returns (address[] memory)
    {
        address[] memory confirmedOwners = new address[](
            transactions[_txId].confirmations
        );
        uint256 count = 0;

        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[_txId][owners[i]]) {
                confirmedOwners[count] = owners[i];
                count++;
            }
        }

        return confirmedOwners;
    }

    /**
     * @dev Получить ожидающие транзакции
     */
    function getPendingTransactions()
        public
        view
        returns (uint256[] memory)
    {
        uint256 count = 0;

        // Подсчет ожидающих транзакций
        for (uint256 i = 0; i < transactions.length; i++) {
            if (!transactions[i].executed) {
                count++;
            }
        }

        // Создание массива
        uint256[] memory pending = new uint256[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < transactions.length; i++) {
            if (!transactions[i].executed) {
                pending[index] = i;
                index++;
            }
        }

        return pending;
    }

    /**
     * @dev Получить выполненные транзакции
     */
    function getExecutedTransactions()
        public
        view
        returns (uint256[] memory)
    {
        uint256 count = 0;

        // Подсчет выполненных транзакций
        for (uint256 i = 0; i < transactions.length; i++) {
            if (transactions[i].executed) {
                count++;
            }
        }

        // Создание массива
        uint256[] memory executed = new uint256[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < transactions.length; i++) {
            if (transactions[i].executed) {
                executed[index] = i;
                index++;
            }
        }

        return executed;
    }

    /**
     * @dev Получить баланс кошелька
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Создать транзакцию добавления владельца
     * @param _owner Адрес нового владельца
     */
    function submitAddOwner(address _owner) public onlyOwner returns (uint256) {
        require(_owner != address(0), "Invalid owner");
        require(!isOwner[_owner], "Already an owner");

        bytes memory data = abi.encodeWithSignature("addOwner(address)", _owner);
        return submitTransaction(address(this), 0, data);
    }

    /**
     * @dev Создать транзакцию удаления владельца
     * @param _owner Адрес владельца для удаления
     */
    function submitRemoveOwner(address _owner)
        public
        onlyOwner
        returns (uint256)
    {
        require(isOwner[_owner], "Not an owner");
        require(owners.length > requiredConfirmations, "Cannot remove: would break requirements");

        bytes memory data = abi.encodeWithSignature(
            "removeOwner(address)",
            _owner
        );
        return submitTransaction(address(this), 0, data);
    }

    /**
     * @dev Добавление владельца (вызывается через мультисиг)
     * @param _owner Адрес нового владельца
     */
    function addOwner(address _owner) public {
        require(msg.sender == address(this), "Only through multisig");
        require(_owner != address(0), "Invalid owner");
        require(!isOwner[_owner], "Already an owner");

        isOwner[_owner] = true;
        owners.push(_owner);

        emit OwnerAdded(_owner);
    }

    /**
     * @dev Удаление владельца (вызывается через мультисиг)
     * @param _owner Адрес владельца
     */
    function removeOwner(address _owner) public {
        require(msg.sender == address(this), "Only through multisig");
        require(isOwner[_owner], "Not an owner");

        isOwner[_owner] = false;

        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == _owner) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                break;
            }
        }

        emit OwnerRemoved(_owner);
    }

    /**
     * @dev Изменение количества требуемых подтверждений
     * @param _required Новое количество
     */
    function changeRequirement(uint256 _required) public {
        require(msg.sender == address(this), "Only through multisig");
        require(
            _required > 0 && _required <= owners.length,
            "Invalid requirement"
        );

        requiredConfirmations = _required;
    }
}
