// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleNFT
 * @dev Простая реализация NFT (ERC721-подобный) контракта
 */
contract SimpleNFT {
    // Имя коллекции
    string public name;
    // Символ коллекции
    string public symbol;

    // Счетчик токенов
    uint256 private _tokenIdCounter;

    // Владелец контракта
    address public owner;

    // Маппинг от token ID к владельцу
    mapping(uint256 => address) private _owners;

    // Маппинг от владельца к количеству токенов
    mapping(address => uint256) private _balances;

    // Маппинг от token ID к approved адресу
    mapping(uint256 => address) private _tokenApprovals;

    // Маппинг от владельца к operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Маппинг от token ID к URI метаданных
    mapping(uint256 => string) private _tokenURIs;

    // Максимальное количество NFT
    uint256 public maxSupply;

    // Цена минта
    uint256 public mintPrice;

    // События
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Minted(address indexed to, uint256 indexed tokenId, string tokenURI);

    // Модификаторы
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _mintPrice
    ) {
        name = _name;
        symbol = _symbol;
        maxSupply = _maxSupply;
        mintPrice = _mintPrice;
        owner = msg.sender;
        _tokenIdCounter = 0;
    }

    /**
     * @dev Возвращает количество токенов у владельца
     */
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "Query for zero address");
        return _balances[_owner];
    }

    /**
     * @dev Возвращает владельца токена
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0), "Token does not exist");
        return tokenOwner;
    }

    /**
     * @dev Возвращает URI токена
     */
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Минт нового NFT
     */
    function mint(string memory _tokenURI) public payable {
        require(_tokenIdCounter < maxSupply, "Max supply reached");
        require(msg.value >= mintPrice, "Insufficient payment");

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = msg.sender;
        _balances[msg.sender]++;
        _tokenURIs[tokenId] = _tokenURI;

        emit Transfer(address(0), msg.sender, tokenId);
        emit Minted(msg.sender, tokenId, _tokenURI);
    }

    /**
     * @dev Минт владельцем контракта (бесплатно)
     */
    function ownerMint(address to, string memory _tokenURI) public onlyOwner {
        require(_tokenIdCounter < maxSupply, "Max supply reached");
        require(to != address(0), "Cannot mint to zero address");

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to]++;
        _tokenURIs[tokenId] = _tokenURI;

        emit Transfer(address(0), to, tokenId);
        emit Minted(to, tokenId, _tokenURI);
    }

    /**
     * @dev Передача токена
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        require(ownerOf(tokenId) == from, "From is not owner");
        require(to != address(0), "Transfer to zero address");

        // Очистка approvals
        _tokenApprovals[tokenId] = address(0);

        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Безопасная передача (упрощенная версия)
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        transferFrom(from, to, tokenId);
    }

    /**
     * @dev Approve адресу для управления токеном
     */
    function approve(address to, uint256 tokenId) public {
        address tokenOwner = ownerOf(tokenId);
        require(msg.sender == tokenOwner || isApprovedForAll(tokenOwner, msg.sender),
            "Not owner or approved for all");
        require(to != tokenOwner, "Approval to current owner");

        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }

    /**
     * @dev Возвращает approved адрес для токена
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Устанавливает operator для всех токенов
     */
    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "Approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev Проверяет, является ли operator approved для всех токенов владельца
     */
    function isApprovedForAll(address _owner, address operator) public view returns (bool) {
        return _operatorApprovals[_owner][operator];
    }

    /**
     * @dev Проверяет, является ли spender владельцем или approved
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) private view returns (bool) {
        address tokenOwner = ownerOf(tokenId);
        return (spender == tokenOwner ||
                getApproved(tokenId) == spender ||
                isApprovedForAll(tokenOwner, spender));
    }

    /**
     * @dev Возвращает общее количество выпущенных токенов
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }

    /**
     * @dev Изменение цены минта (только владелец)
     */
    function setMintPrice(uint256 newPrice) public onlyOwner {
        mintPrice = newPrice;
    }

    /**
     * @dev Вывод средств (только владелец)
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner).transfer(balance);
    }

    /**
     * @dev Получение баланса контракта
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
