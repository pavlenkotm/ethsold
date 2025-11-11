// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleToken
 * @dev Implementation of ERC20 token standard with additional features
 * @notice This contract provides a flexible ERC20 token with optional minting and burning capabilities
 */
contract SimpleToken {
    // Core token parameters
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // State mappings
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Control parameters
    address public owner;
    bool public mintable;
    bool public burnable;

    // ERC20 events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    /**
     * @dev Token constructor
     * @param _name Token name
     * @param _symbol Token symbol
     * @param _decimals Number of decimal places
     * @param _initialSupply Initial token supply
     * @param _mintable Whether new tokens can be minted
     * @param _burnable Whether tokens can be burned
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

        // Mint initial supply
        if (_initialSupply > 0) {
            totalSupply = _initialSupply * 10**uint256(_decimals);
            balanceOf[msg.sender] = totalSupply;
            emit Transfer(address(0), msg.sender, totalSupply);
        }
    }

    /**
     * @dev Transfer tokens to a specified address
     * @param _to Recipient address
     * @param _value Amount of tokens to transfer
     * @return success True if the operation was successful
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
     * @dev Approve spender to spend tokens on behalf of msg.sender
     * @param _spender Address authorized to spend
     * @param _value Amount of tokens approved
     * @return success True if the operation was successful
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid address");

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from Sender address
     * @param _to Recipient address
     * @param _value Amount of tokens to transfer
     * @return success True if the operation was successful
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
     * @dev Mint new tokens (only owner, if mintable is enabled)
     * @param _to Recipient address
     * @param _value Amount of tokens to mint
     * @return success True if the operation was successful
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
     * @dev Burn tokens from sender's balance
     * @param _value Amount of tokens to burn
     * @return success True if the operation was successful
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
     * @dev Burn tokens from another address
     * @param _from Token owner address
     * @param _value Amount of tokens to burn
     * @return success True if the operation was successful
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
     * @dev Increase allowance for spender
     * @param _spender Address to increase allowance for
     * @param _addedValue Amount to increase by
     * @return success True if the operation was successful
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
     * @dev Decrease allowance for spender
     * @param _spender Address to decrease allowance for
     * @param _subtractedValue Amount to decrease by
     * @return success True if the operation was successful
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
     * @dev Transfer contract ownership
     * @param _newOwner Address of the new owner
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        address previousOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }
}
