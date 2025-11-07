// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Lottery
 * @dev Децентрализованная лотерея с прозрачным выбором победителя
 */
contract Lottery {
    // Статусы лотереи
    enum LotteryStatus {
        Open,
        Closed,
        Completed
    }

    // Структура лотереи
    struct LotteryRound {
        uint256 id;
        uint256 ticketPrice;
        uint256 maxTickets;
        uint256 endTime;
        uint256 totalPrize;
        address winner;
        LotteryStatus status;
        address[] participants;
        mapping(address => uint256) ticketCount;
        uint256 randomSeed;
    }

    // Переменные состояния
    uint256 public roundCounter;
    uint256 public platformFeePercent = 5; // 5% комиссия
    address payable public owner;

    mapping(uint256 => LotteryRound) public lotteries;
    mapping(address => uint256[]) public userParticipations;

    // События
    event LotteryCreated(
        uint256 indexed roundId,
        uint256 ticketPrice,
        uint256 maxTickets,
        uint256 endTime
    );

    event TicketPurchased(
        uint256 indexed roundId,
        address indexed participant,
        uint256 ticketCount
    );

    event WinnerSelected(
        uint256 indexed roundId,
        address indexed winner,
        uint256 prize
    );

    event LotteryClosed(uint256 indexed roundId);
    event PrizeWithdrawn(uint256 indexed roundId, address winner, uint256 amount);

    // Модификаторы
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier lotteryExists(uint256 _roundId) {
        require(_roundId < roundCounter, "Lottery does not exist");
        _;
    }

    modifier lotteryOpen(uint256 _roundId) {
        require(lotteries[_roundId].status == LotteryStatus.Open, "Lottery not open");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
    }

    /**
     * @dev Создание новой лотереи
     * @param _ticketPrice Цена одного билета
     * @param _maxTickets Максимальное количество билетов
     * @param _durationHours Продолжительность в часах
     */
    function createLottery(
        uint256 _ticketPrice,
        uint256 _maxTickets,
        uint256 _durationHours
    ) external onlyOwner returns (uint256) {
        require(_ticketPrice > 0, "Ticket price must be positive");
        require(_maxTickets > 0, "Max tickets must be positive");
        require(_durationHours > 0, "Duration must be positive");

        uint256 roundId = roundCounter;
        LotteryRound storage lottery = lotteries[roundId];

        lottery.id = roundId;
        lottery.ticketPrice = _ticketPrice;
        lottery.maxTickets = _maxTickets;
        lottery.endTime = block.timestamp + (_durationHours * 1 hours);
        lottery.totalPrize = 0;
        lottery.status = LotteryStatus.Open;
        lottery.randomSeed = 0;

        roundCounter++;

        emit LotteryCreated(roundId, _ticketPrice, _maxTickets, lottery.endTime);

        return roundId;
    }

    /**
     * @dev Покупка билетов
     * @param _roundId ID раунда лотереи
     * @param _ticketAmount Количество билетов
     */
    function buyTickets(uint256 _roundId, uint256 _ticketAmount)
        external
        payable
        lotteryExists(_roundId)
        lotteryOpen(_roundId)
    {
        LotteryRound storage lottery = lotteries[_roundId];

        require(block.timestamp < lottery.endTime, "Lottery has ended");
        require(_ticketAmount > 0, "Must buy at least one ticket");
        require(
            lottery.participants.length + _ticketAmount <= lottery.maxTickets,
            "Not enough tickets available"
        );

        uint256 totalCost = lottery.ticketPrice * _ticketAmount;
        require(msg.value >= totalCost, "Insufficient payment");

        // Добавление билетов участнику
        if (lottery.ticketCount[msg.sender] == 0) {
            userParticipations[msg.sender].push(_roundId);
        }

        lottery.ticketCount[msg.sender] += _ticketAmount;

        // Добавление участника в список для каждого билета
        for (uint256 i = 0; i < _ticketAmount; i++) {
            lottery.participants.push(msg.sender);
        }

        lottery.totalPrize += totalCost;

        // Добавление к seed для генерации случайного числа
        lottery.randomSeed += uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    msg.sender,
                    lottery.participants.length
                )
            )
        );

        // Возврат излишка
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }

        emit TicketPurchased(_roundId, msg.sender, _ticketAmount);

        // Автоматическое закрытие если все билеты проданы
        if (lottery.participants.length >= lottery.maxTickets) {
            _closeLottery(_roundId);
        }
    }

    /**
     * @dev Закрытие лотереи вручную (только владелец)
     * @param _roundId ID раунда
     */
    function closeLottery(uint256 _roundId)
        external
        onlyOwner
        lotteryExists(_roundId)
        lotteryOpen(_roundId)
    {
        require(
            block.timestamp >= lotteries[_roundId].endTime,
            "Lottery not ended yet"
        );
        _closeLottery(_roundId);
    }

    /**
     * @dev Внутренняя функция закрытия лотереи
     */
    function _closeLottery(uint256 _roundId) private {
        LotteryRound storage lottery = lotteries[_roundId];

        require(lottery.participants.length > 0, "No participants");

        lottery.status = LotteryStatus.Closed;

        emit LotteryClosed(_roundId);

        // Выбор победителя
        _selectWinner(_roundId);
    }

    /**
     * @dev Выбор победителя
     */
    function _selectWinner(uint256 _roundId) private {
        LotteryRound storage lottery = lotteries[_roundId];

        require(lottery.status == LotteryStatus.Closed, "Lottery not closed");
        require(lottery.participants.length > 0, "No participants");

        // Генерация случайного индекса
        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(
                    lottery.randomSeed,
                    block.timestamp,
                    block.prevrandao,
                    blockhash(block.number - 1)
                )
            )
        ) % lottery.participants.length;

        address winnerAddress = lottery.participants[randomIndex];
        lottery.winner = winnerAddress;
        lottery.status = LotteryStatus.Completed;

        // Расчет призового фонда
        uint256 fee = (lottery.totalPrize * platformFeePercent) / 100;
        uint256 prize = lottery.totalPrize - fee;

        // Перевод средств
        owner.transfer(fee);
        payable(winnerAddress).transfer(prize);

        emit WinnerSelected(_roundId, winnerAddress, prize);
        emit PrizeWithdrawn(_roundId, winnerAddress, prize);
    }

    /**
     * @dev Получить информацию о лотерее
     * @param _roundId ID раунда
     */
    function getLottery(uint256 _roundId)
        external
        view
        lotteryExists(_roundId)
        returns (
            uint256 ticketPrice,
            uint256 maxTickets,
            uint256 soldTickets,
            uint256 endTime,
            uint256 totalPrize,
            address winner,
            LotteryStatus status
        )
    {
        LotteryRound storage lottery = lotteries[_roundId];
        return (
            lottery.ticketPrice,
            lottery.maxTickets,
            lottery.participants.length,
            lottery.endTime,
            lottery.totalPrize,
            lottery.winner,
            lottery.status
        );
    }

    /**
     * @dev Получить количество билетов участника
     * @param _roundId ID раунда
     * @param _participant Адрес участника
     */
    function getParticipantTickets(uint256 _roundId, address _participant)
        external
        view
        lotteryExists(_roundId)
        returns (uint256)
    {
        return lotteries[_roundId].ticketCount[_participant];
    }

    /**
     * @dev Получить всех участников лотереи
     * @param _roundId ID раунда
     */
    function getParticipants(uint256 _roundId)
        external
        view
        lotteryExists(_roundId)
        returns (address[] memory)
    {
        return lotteries[_roundId].participants;
    }

    /**
     * @dev Получить участия пользователя
     * @param _user Адрес пользователя
     */
    function getUserParticipations(address _user)
        external
        view
        returns (uint256[] memory)
    {
        return userParticipations[_user];
    }

    /**
     * @dev Проверить активна ли лотерея
     * @param _roundId ID раунда
     */
    function isLotteryActive(uint256 _roundId)
        external
        view
        lotteryExists(_roundId)
        returns (bool)
    {
        LotteryRound storage lottery = lotteries[_roundId];
        return (
            lottery.status == LotteryStatus.Open &&
            block.timestamp < lottery.endTime &&
            lottery.participants.length < lottery.maxTickets
        );
    }

    /**
     * @dev Изменить комиссию платформы
     * @param _newFee Новая комиссия
     */
    function setPlatformFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= 20, "Fee cannot exceed 20%");
        platformFeePercent = _newFee;
    }

    /**
     * @dev Получить баланс контракта
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Экстренный вывод средств (только владелец)
     */
    function emergencyWithdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }
}
