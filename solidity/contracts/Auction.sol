// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Auction
 * @dev Платформа для проведения аукционов с английской и голландской системами
 */
contract Auction {
    // Типы аукционов
    enum AuctionType {
        English, // Цена растет
        Dutch // Цена падает
    }

    // Статусы аукциона
    enum AuctionStatus {
        Active,
        Ended,
        Cancelled
    }

    // Структура аукциона
    struct AuctionItem {
        uint256 id;
        address payable seller;
        string title;
        string description;
        AuctionType auctionType;
        uint256 startPrice;
        uint256 reservePrice; // Минимальная цена для английского, начальная для голландского
        uint256 currentPrice;
        uint256 priceDecrement; // Для голландского аукциона
        uint256 decrementInterval; // Интервал снижения цены
        address payable highestBidder;
        uint256 highestBid;
        uint256 startTime;
        uint256 endTime;
        AuctionStatus status;
    }

    // Переменные состояния
    uint256 public auctionCounter;
    uint256 public platformFee = 2; // 2% комиссия
    address payable public platformOwner;

    mapping(uint256 => AuctionItem) public auctions;
    mapping(address => uint256[]) public userAuctions;
    // Mapping для хранения ставок: auctionId => bidder => amount
    mapping(uint256 => mapping(address => uint256)) public auctionBids;

    // События
    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed seller,
        AuctionType auctionType,
        uint256 startPrice,
        uint256 endTime
    );

    event BidPlaced(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 amount
    );

    event AuctionEnded(
        uint256 indexed auctionId,
        address indexed winner,
        uint256 winningBid
    );

    event AuctionCancelled(uint256 indexed auctionId);
    event BidWithdrawn(uint256 indexed auctionId, address indexed bidder, uint256 amount);

    // Модификаторы
    modifier auctionExists(uint256 _auctionId) {
        require(_auctionId < auctionCounter, "Auction does not exist");
        _;
    }

    modifier onlySeller(uint256 _auctionId) {
        require(
            msg.sender == auctions[_auctionId].seller,
            "Only seller can call this"
        );
        _;
    }

    modifier auctionActive(uint256 _auctionId) {
        require(
            auctions[_auctionId].status == AuctionStatus.Active,
            "Auction not active"
        );
        _;
    }

    constructor() {
        platformOwner = payable(msg.sender);
    }

    /**
     * @dev Создание английского аукциона (цена растет)
     * @param _title Название лота
     * @param _description Описание
     * @param _startPrice Начальная цена
     * @param _reservePrice Минимальная цена продажи
     * @param _durationHours Продолжительность в часах
     */
    function createEnglishAuction(
        string memory _title,
        string memory _description,
        uint256 _startPrice,
        uint256 _reservePrice,
        uint256 _durationHours
    ) external returns (uint256) {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(_startPrice > 0, "Start price must be positive");
        require(_reservePrice >= _startPrice, "Reserve must be >= start price");
        require(_durationHours > 0, "Duration must be positive");

        uint256 auctionId = auctionCounter;
        AuctionItem storage auction = auctions[auctionId];

        auction.id = auctionId;
        auction.seller = payable(msg.sender);
        auction.title = _title;
        auction.description = _description;
        auction.auctionType = AuctionType.English;
        auction.startPrice = _startPrice;
        auction.reservePrice = _reservePrice;
        auction.currentPrice = _startPrice;
        auction.highestBid = 0;
        auction.startTime = block.timestamp;
        auction.endTime = block.timestamp + (_durationHours * 1 hours);
        auction.status = AuctionStatus.Active;

        userAuctions[msg.sender].push(auctionId);
        auctionCounter++;

        emit AuctionCreated(
            auctionId,
            msg.sender,
            AuctionType.English,
            _startPrice,
            auction.endTime
        );

        return auctionId;
    }

    /**
     * @dev Создание голландского аукциона (цена падает)
     * @param _title Название лота
     * @param _description Описание
     * @param _startPrice Начальная (максимальная) цена
     * @param _reservePrice Минимальная цена
     * @param _priceDecrement Величина снижения цены
     * @param _decrementInterval Интервал снижения в секундах
     * @param _durationHours Максимальная продолжительность
     */
    function createDutchAuction(
        string memory _title,
        string memory _description,
        uint256 _startPrice,
        uint256 _reservePrice,
        uint256 _priceDecrement,
        uint256 _decrementInterval,
        uint256 _durationHours
    ) external returns (uint256) {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(_startPrice > _reservePrice, "Start price must be > reserve");
        require(_priceDecrement > 0, "Decrement must be positive");
        require(_decrementInterval > 0, "Interval must be positive");

        uint256 auctionId = auctionCounter;
        AuctionItem storage auction = auctions[auctionId];

        auction.id = auctionId;
        auction.seller = payable(msg.sender);
        auction.title = _title;
        auction.description = _description;
        auction.auctionType = AuctionType.Dutch;
        auction.startPrice = _startPrice;
        auction.reservePrice = _reservePrice;
        auction.currentPrice = _startPrice;
        auction.priceDecrement = _priceDecrement;
        auction.decrementInterval = _decrementInterval;
        auction.startTime = block.timestamp;
        auction.endTime = block.timestamp + (_durationHours * 1 hours);
        auction.status = AuctionStatus.Active;

        userAuctions[msg.sender].push(auctionId);
        auctionCounter++;

        emit AuctionCreated(
            auctionId,
            msg.sender,
            AuctionType.Dutch,
            _startPrice,
            auction.endTime
        );

        return auctionId;
    }

    /**
     * @dev Сделать ставку на английском аукционе
     * @param _auctionId ID аукциона
     */
    function bidEnglish(uint256 _auctionId)
        external
        payable
        auctionExists(_auctionId)
        auctionActive(_auctionId)
    {
        AuctionItem storage auction = auctions[_auctionId];

        require(
            auction.auctionType == AuctionType.English,
            "Not an English auction"
        );
        require(block.timestamp < auction.endTime, "Auction ended");
        require(msg.sender != auction.seller, "Seller cannot bid");
        require(msg.value > auction.highestBid, "Bid too low");
        require(msg.value >= auction.startPrice, "Below start price");

        // Возврат предыдущей ставки
        if (auction.highestBidder != address(0)) {
            auctionBids[_auctionId][auction.highestBidder] += auction.highestBid;
        }

        auction.highestBidder = payable(msg.sender);
        auction.highestBid = msg.value;
        auction.currentPrice = msg.value;

        emit BidPlaced(_auctionId, msg.sender, msg.value);
    }

    /**
     * @dev Купить на голландском аукционе по текущей цене
     * @param _auctionId ID аукциона
     */
    function buyDutch(uint256 _auctionId)
        external
        payable
        auctionExists(_auctionId)
        auctionActive(_auctionId)
    {
        AuctionItem storage auction = auctions[_auctionId];

        require(
            auction.auctionType == AuctionType.Dutch,
            "Not a Dutch auction"
        );
        require(block.timestamp < auction.endTime, "Auction ended");
        require(msg.sender != auction.seller, "Seller cannot buy");

        uint256 currentPrice = getCurrentDutchPrice(_auctionId);
        require(msg.value >= currentPrice, "Insufficient payment");

        auction.highestBidder = payable(msg.sender);
        auction.highestBid = currentPrice;
        auction.status = AuctionStatus.Ended;

        // Расчет комиссий
        uint256 fee = (currentPrice * platformFee) / 100;
        uint256 sellerAmount = currentPrice - fee;

        // Переводы
        (bool successFee, ) = platformOwner.call{value: fee}("");
        require(successFee, "Fee transfer failed");
        (bool successSeller, ) = auction.seller.call{value: sellerAmount}("");
        require(successSeller, "Seller transfer failed");

        // Возврат излишка
        if (msg.value > currentPrice) {
            (bool successRefund, ) = payable(msg.sender).call{value: msg.value - currentPrice}("");
            require(successRefund, "Refund transfer failed");
        }

        emit BidPlaced(_auctionId, msg.sender, currentPrice);
        emit AuctionEnded(_auctionId, msg.sender, currentPrice);
    }

    /**
     * @dev Завершить английский аукцион
     * @param _auctionId ID аукциона
     */
    function endEnglishAuction(uint256 _auctionId)
        external
        auctionExists(_auctionId)
        auctionActive(_auctionId)
    {
        AuctionItem storage auction = auctions[_auctionId];

        require(
            auction.auctionType == AuctionType.English,
            "Not an English auction"
        );
        require(block.timestamp >= auction.endTime, "Auction still active");

        auction.status = AuctionStatus.Ended;

        // Если есть победитель и цена выше резервной
        if (
            auction.highestBidder != address(0) &&
            auction.highestBid >= auction.reservePrice
        ) {
            uint256 fee = (auction.highestBid * platformFee) / 100;
            uint256 sellerAmount = auction.highestBid - fee;

            (bool successFee, ) = platformOwner.call{value: fee}("");
            require(successFee, "Fee transfer failed");
            (bool successSeller, ) = auction.seller.call{value: sellerAmount}("");
            require(successSeller, "Seller transfer failed");

            emit AuctionEnded(_auctionId, auction.highestBidder, auction.highestBid);
        } else {
            // Аукцион не состоялся, возврат ставки
            if (auction.highestBidder != address(0)) {
                auctionBids[_auctionId][auction.highestBidder] += auction.highestBid;
            }
            emit AuctionCancelled(_auctionId);
        }
    }

    /**
     * @dev Отменить аукцион (только продавец, до первой ставки)
     * @param _auctionId ID аукциона
     */
    function cancelAuction(uint256 _auctionId)
        external
        auctionExists(_auctionId)
        onlySeller(_auctionId)
        auctionActive(_auctionId)
    {
        AuctionItem storage auction = auctions[_auctionId];

        require(auction.highestBidder == address(0), "Cannot cancel: bids exist");

        auction.status = AuctionStatus.Cancelled;

        emit AuctionCancelled(_auctionId);
    }

    /**
     * @dev Вывести неиспользованные ставки
     * @param _auctionId ID аукциона
     */
    function withdrawBid(uint256 _auctionId)
        external
        auctionExists(_auctionId)
    {
        uint256 amount = auctionBids[_auctionId][msg.sender];

        require(amount > 0, "No funds to withdraw");

        auctionBids[_auctionId][msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw transfer failed");

        emit BidWithdrawn(_auctionId, msg.sender, amount);
    }

    /**
     * @dev Получить текущую цену голландского аукциона
     * @param _auctionId ID аукциона
     */
    function getCurrentDutchPrice(uint256 _auctionId)
        public
        view
        auctionExists(_auctionId)
        returns (uint256)
    {
        AuctionItem storage auction = auctions[_auctionId];

        require(
            auction.auctionType == AuctionType.Dutch,
            "Not a Dutch auction"
        );

        if (auction.status != AuctionStatus.Active) {
            return auction.currentPrice;
        }

        uint256 timeElapsed = block.timestamp - auction.startTime;
        uint256 decrements = timeElapsed / auction.decrementInterval;
        uint256 priceReduction = decrements * auction.priceDecrement;

        if (priceReduction >= auction.startPrice - auction.reservePrice) {
            return auction.reservePrice;
        }

        return auction.startPrice - priceReduction;
    }

    /**
     * @dev Получить информацию об аукционе
     * @param _auctionId ID аукциона
     */
    function getAuction(uint256 _auctionId)
        external
        view
        auctionExists(_auctionId)
        returns (
            address seller,
            string memory title,
            string memory description,
            AuctionType auctionType,
            uint256 startPrice,
            uint256 currentPrice,
            address highestBidder,
            uint256 highestBid,
            uint256 endTime,
            AuctionStatus status
        )
    {
        AuctionItem storage auction = auctions[_auctionId];

        uint256 price = auction.currentPrice;
        if (auction.auctionType == AuctionType.Dutch &&
            auction.status == AuctionStatus.Active) {
            price = getCurrentDutchPrice(_auctionId);
        }

        return (
            auction.seller,
            auction.title,
            auction.description,
            auction.auctionType,
            auction.startPrice,
            price,
            auction.highestBidder,
            auction.highestBid,
            auction.endTime,
            auction.status
        );
    }

    /**
     * @dev Получить аукционы пользователя
     * @param _user Адрес пользователя
     */
    function getUserAuctions(address _user)
        external
        view
        returns (uint256[] memory)
    {
        return userAuctions[_user];
    }

    /**
     * @dev Получить сумму доступную для вывода
     * @param _auctionId ID аукциона
     * @param _user Адрес пользователя
     */
    function getWithdrawableAmount(uint256 _auctionId, address _user)
        external
        view
        auctionExists(_auctionId)
        returns (uint256)
    {
        return auctionBids[_auctionId][_user];
    }

    /**
     * @dev Проверить активен ли аукцион
     * @param _auctionId ID аукциона
     */
    function isAuctionActive(uint256 _auctionId)
        external
        view
        auctionExists(_auctionId)
        returns (bool)
    {
        AuctionItem storage auction = auctions[_auctionId];
        return (
            auction.status == AuctionStatus.Active &&
            block.timestamp < auction.endTime
        );
    }

    /**
     * @dev Изменить комиссию платформы
     * @param _newFee Новая комиссия
     */
    function setPlatformFee(uint256 _newFee) external {
        require(msg.sender == platformOwner, "Only owner");
        require(_newFee <= 10, "Fee cannot exceed 10%");
        platformFee = _newFee;
    }
}
