// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleToken
 * @dev Реализация стандарта ERC20 токена с дополнительными функциями
 */
contract SimpleToken {
    // Основные параметры токена
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // Маппинги
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Функции для управления
    address public owner;
    bool public mintable;
    bool public burnable;

    // События ERC20
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    // Модификаторы
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    /**
     * @dev Конструктор токена
     * @param _name Название токена
     * @param _symbol Символ токена
     * @param _decimals Количество десятичных знаков
     * @param _initialSupply Начальное предложение
     * @param _mintable Возможность создания новых токенов
     * @param _burnable Возможность сжигания токенов
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply,
        bool _mintable,
        bool _burnable
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        mintable = _mintable;
        burnable = _burnable;
        owner = msg.sender;

        // Создание начального предложения
        if (_initialSupply > 0) {
            totalSupply = _initialSupply * 10**uint256(_decimals);
            balanceOf[msg.sender] = totalSupply;
            emit Transfer(address(0), msg.sender, totalSupply);
        }
    }

    /**
     * @dev Перевод токенов
     * @param _to Адрес получателя
     * @param _value Количество токенов
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Одобрение расходования токенов
     * @param _spender Адрес, которому разрешено тратить
     * @param _value Количество токенов
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid address");

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Перевод токенов от имени другого адреса
     * @param _from Адрес отправителя
     * @param _to Адрес получателя
     * @param _value Количество токенов
     */
    function transferFrom(address _from, address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(_to != address(0), "Invalid address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Создание новых токенов (только владелец, если mintable)
     * @param _to Адрес получателя
     * @param _value Количество токенов
     */
    function mint(address _to, uint256 _value) public onlyOwner returns (bool success) {
        require(mintable, "Minting is disabled");
        require(_to != address(0), "Invalid address");

        totalSupply += _value;
        balanceOf[_to] += _value;

        emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

    /**
     * @dev Сжигание токенов
     * @param _value Количество токенов
     */
    function burn(uint256 _value) public returns (bool success) {
        require(burnable, "Burning is disabled");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;

        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    /**
     * @dev Сжигание токенов от имени другого адреса
     * @param _from Адрес владельца токенов
     * @param _value Количество токенов
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(burnable, "Burning is disabled");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        balanceOf[_from] -= _value;
        totalSupply -= _value;
        allowance[_from][msg.sender] -= _value;

        emit Burn(_from, _value);
        emit Transfer(_from, address(0), _value);
        return true;
    }

    /**
     * @dev Увеличение allowance
     * @param _spender Адрес получателя разрешения
     * @param _addedValue Добавляемое количество
     */
    function increaseAllowance(address _spender, uint256 _addedValue)
        public
        returns (bool success)
    {
        require(_spender != address(0), "Invalid address");

        allowance[msg.sender][_spender] += _addedValue;

        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Уменьшение allowance
     * @param _spender Адрес получателя разрешения
     * @param _subtractedValue Уменьшаемое количество
     */
    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        public
        returns (bool success)
    {
        require(_spender != address(0), "Invalid address");
        require(allowance[msg.sender][_spender] >= _subtractedValue, "Allowance below zero");

        allowance[msg.sender][_spender] -= _subtractedValue;

        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Передача владения контрактом
     * @param _newOwner Адрес нового владельца
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }
}
