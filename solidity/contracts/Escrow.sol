// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Escrow
 * @dev Сервис эскроу для безопасных сделок между двумя сторонами
 */
contract Escrow {
    // Статусы сделки
    enum Status {
        Created,
        Funded,
        Disputed,
        Completed,
        Refunded,
        Cancelled
    }

    // Структура сделки
    struct Deal {
        uint256 id;
        address payable buyer;
        address payable seller;
        address arbitrator;
        uint256 amount;
        uint256 fee;
        Status status;
        string description;
        uint256 createdAt;
        uint256 deadline;
        bool buyerApproved;
        bool sellerApproved;
    }

    // Переменные состояния
    uint256 public dealCounter;
    uint256 public escrowFeePercent = 1; // 1% комиссия
    address payable public platformOwner;

    mapping(uint256 => Deal) public deals;
    mapping(address => uint256[]) public userDeals;

    // События
    event DealCreated(
        uint256 indexed dealId,
        address indexed buyer,
        address indexed seller,
        uint256 amount
    );

    event DealFunded(uint256 indexed dealId, uint256 amount);
    event DealCompleted(uint256 indexed dealId);
    event DealRefunded(uint256 indexed dealId);
    event DealDisputed(uint256 indexed dealId);
    event DealCancelled(uint256 indexed dealId);
    event ArbitratorAssigned(uint256 indexed dealId, address arbitrator);

    // Модификаторы
    modifier onlyBuyer(uint256 _dealId) {
        require(msg.sender == deals[_dealId].buyer, "Only buyer");
        _;
    }

    modifier onlySeller(uint256 _dealId) {
        require(msg.sender == deals[_dealId].seller, "Only seller");
        _;
    }

    modifier onlyArbitrator(uint256 _dealId) {
        require(msg.sender == deals[_dealId].arbitrator, "Only arbitrator");
        _;
    }

    modifier dealExists(uint256 _dealId) {
        require(_dealId < dealCounter, "Deal does not exist");
        _;
    }

    modifier inStatus(uint256 _dealId, Status _status) {
        require(deals[_dealId].status == _status, "Invalid deal status");
        _;
    }

    constructor() {
        platformOwner = payable(msg.sender);
    }

    /**
     * @dev Создание новой сделки
     * @param _seller Адрес продавца
     * @param _description Описание сделки
     * @param _durationDays Продолжительность в днях
     */
    function createDeal(
        address payable _seller,
        string memory _description,
        uint256 _durationDays
    ) external payable returns (uint256) {
        require(_seller != address(0), "Invalid seller address");
        require(_seller != msg.sender, "Cannot create deal with yourself");
        require(msg.value > 0, "Amount must be positive");
        require(_durationDays > 0 && _durationDays <= 90, "Duration 1-90 days");

        uint256 dealId = dealCounter;
        uint256 fee = (msg.value * escrowFeePercent) / 100;

        deals[dealId] = Deal({
            id: dealId,
            buyer: payable(msg.sender),
            seller: _seller,
            arbitrator: address(0),
            amount: msg.value - fee,
            fee: fee,
            status: Status.Created,
            description: _description,
            createdAt: block.timestamp,
            deadline: block.timestamp + (_durationDays * 1 days),
            buyerApproved: false,
            sellerApproved: false
        });

        userDeals[msg.sender].push(dealId);
        userDeals[_seller].push(dealId);

        dealCounter++;

        emit DealCreated(dealId, msg.sender, _seller, msg.value);
        emit DealFunded(dealId, msg.value);

        return dealId;
    }

    /**
     * @dev Подтверждение выполнения сделки покупателем
     * @param _dealId ID сделки
     */
    function approveDeal(uint256 _dealId)
        external
        dealExists(_dealId)
        onlyBuyer(_dealId)
    {
        Deal storage deal = deals[_dealId];
        require(
            deal.status == Status.Created || deal.status == Status.Funded,
            "Invalid deal status"
        );
        deal.buyerApproved = true;

        _completeDealIfApproved(_dealId);
    }

    /**
     * @dev Подтверждение получения средств продавцом
     * @param _dealId ID сделки
     */
    function confirmDelivery(uint256 _dealId)
        external
        dealExists(_dealId)
        onlySeller(_dealId)
    {
        Deal storage deal = deals[_dealId];
        require(
            deal.status == Status.Created || deal.status == Status.Funded,
            "Invalid deal status"
        );
        deal.sellerApproved = true;

        _completeDealIfApproved(_dealId);
    }

    /**
     * @dev Завершение сделки если обе стороны одобрили
     */
    function _completeDealIfApproved(uint256 _dealId) private {
        Deal storage deal = deals[_dealId];

        if (deal.buyerApproved && deal.sellerApproved) {
            deal.status = Status.Completed;

            // Перевод средств продавцу
            (bool successSeller, ) = deal.seller.call{value: deal.amount}("");
            require(successSeller, "Seller transfer failed");
            (bool successFee, ) = platformOwner.call{value: deal.fee}("");
            require(successFee, "Fee transfer failed");

            emit DealCompleted(_dealId);
        }
    }

    /**
     * @dev Открытие спора
     * @param _dealId ID сделки
     */
    function openDispute(uint256 _dealId)
        external
        dealExists(_dealId)
    {
        Deal storage deal = deals[_dealId];
        require(
            deal.status == Status.Created || deal.status == Status.Funded,
            "Invalid deal status"
        );
        require(
            msg.sender == deal.buyer || msg.sender == deal.seller,
            "Only parties can dispute"
        );

        deal.status = Status.Disputed;
        emit DealDisputed(_dealId);
    }

    /**
     * @dev Назначение арбитра
     * @param _dealId ID сделки
     * @param _arbitrator Адрес арбитра
     */
    function assignArbitrator(uint256 _dealId, address _arbitrator)
        external
        dealExists(_dealId)
        inStatus(_dealId, Status.Disputed)
    {
        require(msg.sender == platformOwner, "Only platform owner");
        require(_arbitrator != address(0), "Invalid arbitrator");

        Deal storage deal = deals[_dealId];
        deal.arbitrator = _arbitrator;

        emit ArbitratorAssigned(_dealId, _arbitrator);
    }

    /**
     * @dev Решение арбитра в пользу покупателя (возврат средств)
     * @param _dealId ID сделки
     */
    function resolveForBuyer(uint256 _dealId)
        external
        dealExists(_dealId)
        onlyArbitrator(_dealId)
        inStatus(_dealId, Status.Disputed)
    {
        Deal storage deal = deals[_dealId];
        deal.status = Status.Refunded;

        // Возврат средств покупателю
        (bool successBuyer, ) = deal.buyer.call{value: deal.amount}("");
        require(successBuyer, "Buyer refund failed");
        (bool successFee, ) = platformOwner.call{value: deal.fee}("");
        require(successFee, "Fee transfer failed");

        emit DealRefunded(_dealId);
    }

    /**
     * @dev Решение арбитра в пользу продавца
     * @param _dealId ID сделки
     */
    function resolveForSeller(uint256 _dealId)
        external
        dealExists(_dealId)
        onlyArbitrator(_dealId)
        inStatus(_dealId, Status.Disputed)
    {
        Deal storage deal = deals[_dealId];
        deal.status = Status.Completed;

        // Перевод средств продавцу
        (bool successSeller, ) = deal.seller.call{value: deal.amount}("");
        require(successSeller, "Seller transfer failed");
        (bool successFee, ) = platformOwner.call{value: deal.fee}("");
        require(successFee, "Fee transfer failed");

        emit DealCompleted(_dealId);
    }

    /**
     * @dev Частичное решение арбитра
     * @param _dealId ID сделки
     * @param _buyerPercent Процент для покупателя (0-100)
     */
    function resolvePartial(uint256 _dealId, uint256 _buyerPercent)
        external
        dealExists(_dealId)
        onlyArbitrator(_dealId)
        inStatus(_dealId, Status.Disputed)
    {
        require(_buyerPercent <= 100, "Invalid percentage");

        Deal storage deal = deals[_dealId];
        deal.status = Status.Completed;

        uint256 buyerAmount = (deal.amount * _buyerPercent) / 100;
        uint256 sellerAmount = deal.amount - buyerAmount;

        if (buyerAmount > 0) {
            (bool successBuyer, ) = deal.buyer.call{value: buyerAmount}("");
            require(successBuyer, "Buyer transfer failed");
        }
        if (sellerAmount > 0) {
            (bool successSeller, ) = deal.seller.call{value: sellerAmount}("");
            require(successSeller, "Seller transfer failed");
        }

        (bool successFee, ) = platformOwner.call{value: deal.fee}("");
        require(successFee, "Fee transfer failed");

        emit DealCompleted(_dealId);
    }

    /**
     * @dev Отмена сделки (только до финансирования)
     * @param _dealId ID сделки
     */
    function cancelDeal(uint256 _dealId)
        external
        dealExists(_dealId)
        inStatus(_dealId, Status.Created)
    {
        Deal storage deal = deals[_dealId];
        require(
            msg.sender == deal.buyer || msg.sender == deal.seller,
            "Only parties can cancel"
        );

        deal.status = Status.Cancelled;
        emit DealCancelled(_dealId);
    }

    /**
     * @dev Автоматический возврат после истечения срока
     * @param _dealId ID сделки
     */
    function refundExpiredDeal(uint256 _dealId)
        external
        dealExists(_dealId)
    {
        Deal storage deal = deals[_dealId];
        require(
            deal.status == Status.Created || deal.status == Status.Funded,
            "Invalid deal status"
        );
        require(block.timestamp > deal.deadline, "Deal not expired");
        require(!deal.sellerApproved, "Seller already approved");

        deal.status = Status.Refunded;

        // Возврат средств покупателю
        (bool successBuyer, ) = deal.buyer.call{value: deal.amount}("");
        require(successBuyer, "Buyer refund failed");
        (bool successFee, ) = platformOwner.call{value: deal.fee}("");
        require(successFee, "Fee transfer failed");

        emit DealRefunded(_dealId);
    }

    /**
     * @dev Получение информации о сделке
     * @param _dealId ID сделки
     */
    function getDeal(uint256 _dealId)
        external
        view
        dealExists(_dealId)
        returns (
            address buyer,
            address seller,
            address arbitrator,
            uint256 amount,
            Status status,
            string memory description,
            uint256 deadline,
            bool buyerApproved,
            bool sellerApproved
        )
    {
        Deal storage deal = deals[_dealId];
        return (
            deal.buyer,
            deal.seller,
            deal.arbitrator,
            deal.amount,
            deal.status,
            deal.description,
            deal.deadline,
            deal.buyerApproved,
            deal.sellerApproved
        );
    }

    /**
     * @dev Получение сделок пользователя
     * @param _user Адрес пользователя
     */
    function getUserDeals(address _user) external view returns (uint256[] memory) {
        return userDeals[_user];
    }

    /**
     * @dev Изменение комиссии платформы
     * @param _newFee Новая комиссия в процентах
     */
    function setEscrowFee(uint256 _newFee) external {
        require(msg.sender == platformOwner, "Only owner");
        require(_newFee <= 5, "Fee cannot exceed 5%");
        escrowFeePercent = _newFee;
    }
}
