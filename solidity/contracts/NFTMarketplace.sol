// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title NFTMarketplace
 * @dev Маркетплейс для торговли NFT токенами
 */
contract NFTMarketplace is ReentrancyGuard {
    // Структура NFT
    struct NFT {
        uint256 tokenId;
        address payable owner;
        address payable creator;
        string tokenURI;
        uint256 price;
        bool forSale;
        uint256 royaltyPercentage; // Процент роялти для создателя
    }

    // Структура предложения
    struct Offer {
        address buyer;
        uint256 price;
        bool active;
    }

    // Переменные состояния
    uint256 public tokenCounter;
    uint256 public marketplaceFee = 2; // 2% комиссия
    address payable public marketplaceOwner;

    mapping(uint256 => NFT) public nfts;
    mapping(uint256 => Offer[]) public offers;
    mapping(address => uint256[]) public ownedTokens;

    // События
    event NFTMinted(
        uint256 indexed tokenId,
        address indexed creator,
        string tokenURI,
        uint256 royaltyPercentage
    );

    event NFTListed(
        uint256 indexed tokenId,
        address indexed owner,
        uint256 price
    );

    event NFTSold(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to,
        uint256 price
    );

    event OfferMade(
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price
    );

    event OfferAccepted(
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price
    );

    event NFTTransferred(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to
    );

    // Модификаторы
    modifier onlyTokenOwner(uint256 _tokenId) {
        require(nfts[_tokenId].owner == msg.sender, "Not token owner");
        _;
    }

    modifier tokenExists(uint256 _tokenId) {
        require(_tokenId < tokenCounter, "Token does not exist");
        _;
    }

    constructor() {
        marketplaceOwner = payable(msg.sender);
    }

    /**
     * @dev Создание нового NFT
     * @param _tokenURI URI метаданных токена
     * @param _royaltyPercentage Процент роялти (0-10)
     */
    function mintNFT(string memory _tokenURI, uint256 _royaltyPercentage)
        external
        returns (uint256)
    {
        require(bytes(_tokenURI).length > 0, "Token URI cannot be empty");
        require(_royaltyPercentage <= 10, "Royalty cannot exceed 10%");

        uint256 tokenId = tokenCounter;

        nfts[tokenId] = NFT({
            tokenId: tokenId,
            owner: payable(msg.sender),
            creator: payable(msg.sender),
            tokenURI: _tokenURI,
            price: 0,
            forSale: false,
            royaltyPercentage: _royaltyPercentage
        });

        ownedTokens[msg.sender].push(tokenId);
        tokenCounter++;

        emit NFTMinted(tokenId, msg.sender, _tokenURI, _royaltyPercentage);

        return tokenId;
    }

    /**
     * @dev Выставить NFT на продажу
     * @param _tokenId ID токена
     * @param _price Цена в wei
     */
    function listNFT(uint256 _tokenId, uint256 _price)
        external
        onlyTokenOwner(_tokenId)
        tokenExists(_tokenId)
    {
        require(_price > 0, "Price must be positive");

        NFT storage nft = nfts[_tokenId];
        nft.price = _price;
        nft.forSale = true;

        emit NFTListed(_tokenId, msg.sender, _price);
    }

    /**
     * @dev Снять NFT с продажи
     * @param _tokenId ID токена
     */
    function unlistNFT(uint256 _tokenId)
        external
        onlyTokenOwner(_tokenId)
        tokenExists(_tokenId)
    {
        NFT storage nft = nfts[_tokenId];
        nft.forSale = false;
        nft.price = 0;
    }

    /**
     * @dev Купить NFT по установленной цене
     * @param _tokenId ID токена
     */
    function buyNFT(uint256 _tokenId)
        external
        payable
        nonReentrant
        tokenExists(_tokenId)
    {
        NFT storage nft = nfts[_tokenId];

        require(nft.forSale, "NFT not for sale");
        require(msg.value >= nft.price, "Insufficient payment");
        require(msg.sender != nft.owner, "Cannot buy your own NFT");

        address payable seller = nft.owner;
        uint256 salePrice = nft.price;

        // Расчет комиссий
        uint256 marketFee = (salePrice * marketplaceFee) / 100;
        uint256 royaltyFee = (salePrice * nft.royaltyPercentage) / 100;
        uint256 sellerAmount = salePrice - marketFee - royaltyFee;

        // Перевод NFT новому владельцу
        _removeTokenFromOwner(seller, _tokenId);
        nft.owner = payable(msg.sender);
        nft.forSale = false;
        nft.price = 0;
        ownedTokens[msg.sender].push(_tokenId);

        // Переводы средств
        (bool successMarket, ) = marketplaceOwner.call{value: marketFee}("");
        require(successMarket, "Marketplace fee transfer failed");
        (bool successCreator, ) = nft.creator.call{value: royaltyFee}("");
        require(successCreator, "Creator royalty transfer failed");
        (bool successSeller, ) = seller.call{value: sellerAmount}("");
        require(successSeller, "Seller transfer failed");

        // Возврат излишка
        if (msg.value > salePrice) {
            (bool successRefund, ) = payable(msg.sender).call{value: msg.value - salePrice}("");
            require(successRefund, "Refund transfer failed");
        }

        emit NFTSold(_tokenId, seller, msg.sender, salePrice);
    }

    /**
     * @dev Сделать предложение о покупке NFT
     * @param _tokenId ID токена
     */
    function makeOffer(uint256 _tokenId)
        external
        payable
        tokenExists(_tokenId)
    {
        require(msg.value > 0, "Offer must be positive");
        require(msg.sender != nfts[_tokenId].owner, "Cannot offer on your own NFT");

        offers[_tokenId].push(Offer({
            buyer: msg.sender,
            price: msg.value,
            active: true
        }));

        emit OfferMade(_tokenId, msg.sender, msg.value);
    }

    /**
     * @dev Принять предложение о покупке
     * @param _tokenId ID токена
     * @param _offerIndex Индекс предложения
     */
    function acceptOffer(uint256 _tokenId, uint256 _offerIndex)
        external
        nonReentrant
        onlyTokenOwner(_tokenId)
        tokenExists(_tokenId)
    {
        require(_offerIndex < offers[_tokenId].length, "Invalid offer index");

        Offer storage offer = offers[_tokenId][_offerIndex];
        require(offer.active, "Offer not active");

        NFT storage nft = nfts[_tokenId];
        uint256 offerPrice = offer.price;

        // Расчет комиссий
        uint256 marketFee = (offerPrice * marketplaceFee) / 100;
        uint256 royaltyFee = (offerPrice * nft.royaltyPercentage) / 100;
        uint256 sellerAmount = offerPrice - marketFee - royaltyFee;

        // Перевод NFT
        address payable seller = nft.owner;
        address buyer = offer.buyer;

        _removeTokenFromOwner(seller, _tokenId);
        nft.owner = payable(buyer);
        nft.forSale = false;
        nft.price = 0;
        ownedTokens[buyer].push(_tokenId);

        // Деактивация всех предложений
        for (uint256 i = 0; i < offers[_tokenId].length; i++) {
            if (offers[_tokenId][i].active && i != _offerIndex) {
                // Возврат средств остальным
                (bool successRefund, ) = payable(offers[_tokenId][i].buyer).call{value: offers[_tokenId][i].price}("");
                require(successRefund, "Offer refund failed");
            }
            offers[_tokenId][i].active = false;
        }

        // Переводы средств
        (bool successMarket, ) = marketplaceOwner.call{value: marketFee}("");
        require(successMarket, "Marketplace fee transfer failed");
        (bool successCreator, ) = nft.creator.call{value: royaltyFee}("");
        require(successCreator, "Creator royalty transfer failed");
        (bool successSeller, ) = seller.call{value: sellerAmount}("");
        require(successSeller, "Seller transfer failed");

        emit OfferAccepted(_tokenId, buyer, offerPrice);
        emit NFTSold(_tokenId, seller, buyer, offerPrice);
    }

    /**
     * @dev Отменить своё предложение
     * @param _tokenId ID токена
     * @param _offerIndex Индекс предложения
     */
    function cancelOffer(uint256 _tokenId, uint256 _offerIndex)
        external
        nonReentrant
        tokenExists(_tokenId)
    {
        require(_offerIndex < offers[_tokenId].length, "Invalid offer index");

        Offer storage offer = offers[_tokenId][_offerIndex];
        require(offer.buyer == msg.sender, "Not your offer");
        require(offer.active, "Offer not active");

        offer.active = false;
        (bool success, ) = payable(msg.sender).call{value: offer.price}("");
        require(success, "Offer cancel transfer failed");
    }

    /**
     * @dev Перевод NFT другому адресу
     * @param _to Адрес получателя
     * @param _tokenId ID токена
     */
    function transferNFT(address _to, uint256 _tokenId)
        external
        onlyTokenOwner(_tokenId)
        tokenExists(_tokenId)
    {
        require(_to != address(0), "Invalid address");
        require(_to != msg.sender, "Cannot transfer to yourself");

        NFT storage nft = nfts[_tokenId];

        _removeTokenFromOwner(msg.sender, _tokenId);
        nft.owner = payable(_to);
        nft.forSale = false;
        nft.price = 0;
        ownedTokens[_to].push(_tokenId);

        emit NFTTransferred(_tokenId, msg.sender, _to);
    }

    /**
     * @dev Получить информацию о NFT
     * @param _tokenId ID токена
     */
    function getNFT(uint256 _tokenId)
        external
        view
        tokenExists(_tokenId)
        returns (
            address owner,
            address creator,
            string memory tokenURI,
            uint256 price,
            bool forSale,
            uint256 royaltyPercentage
        )
    {
        NFT storage nft = nfts[_tokenId];
        return (
            nft.owner,
            nft.creator,
            nft.tokenURI,
            nft.price,
            nft.forSale,
            nft.royaltyPercentage
        );
    }

    /**
     * @dev Получить токены владельца
     * @param _owner Адрес владельца
     */
    function getOwnedTokens(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        return ownedTokens[_owner];
    }

    /**
     * @dev Получить предложения для токена
     * @param _tokenId ID токена
     */
    function getOffers(uint256 _tokenId)
        external
        view
        tokenExists(_tokenId)
        returns (Offer[] memory)
    {
        return offers[_tokenId];
    }

    /**
     * @dev Изменить комиссию маркетплейса
     * @param _newFee Новая комиссия
     */
    function setMarketplaceFee(uint256 _newFee) external {
        require(msg.sender == marketplaceOwner, "Only owner");
        require(_newFee <= 10, "Fee cannot exceed 10%");
        marketplaceFee = _newFee;
    }

    /**
     * @dev Удалить токен из списка владельца
     */
    function _removeTokenFromOwner(address _owner, uint256 _tokenId) private {
        uint256[] storage tokens = ownedTokens[_owner];
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == _tokenId) {
                tokens[i] = tokens[tokens.length - 1];
                tokens.pop();
                break;
            }
        }
    }
}
