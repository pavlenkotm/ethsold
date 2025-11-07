// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Staking
 * @dev Контракт для стейкинга токенов с начислением вознаграждений
 */
contract Staking {
    // Структура стейка пользователя
    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 lastClaimTime;
        uint256 rewardDebt;
    }

    // Структура пула стейкинга
    struct StakingPool {
        uint256 id;
        uint256 rewardRate; // Вознаграждение в процентах годовых (APR)
        uint256 minStakeAmount;
        uint256 lockPeriod; // Период блокировки в секундах
        uint256 totalStaked;
        bool active;
    }

    // Переменные состояния
    address public owner;
    uint256 public poolCounter;
    uint256 public totalRewardsDistributed;

    mapping(uint256 => StakingPool) public pools;
    mapping(uint256 => mapping(address => Stake)) public stakes;
    mapping(address => uint256[]) public userPools;

    // События
    event PoolCreated(
        uint256 indexed poolId,
        uint256 rewardRate,
        uint256 minStakeAmount,
        uint256 lockPeriod
    );

    event Staked(
        uint256 indexed poolId,
        address indexed user,
        uint256 amount
    );

    event Unstaked(
        uint256 indexed poolId,
        address indexed user,
        uint256 amount
    );

    event RewardClaimed(
        uint256 indexed poolId,
        address indexed user,
        uint256 reward
    );

    event PoolStatusChanged(uint256 indexed poolId, bool active);
    event RewardRateUpdated(uint256 indexed poolId, uint256 newRate);

    // Модификаторы
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier poolExists(uint256 _poolId) {
        require(_poolId < poolCounter, "Pool does not exist");
        _;
    }

    modifier poolActive(uint256 _poolId) {
        require(pools[_poolId].active, "Pool not active");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Получение средств для выплаты наград
    receive() external payable {}

    /**
     * @dev Создание нового пула стейкинга
     * @param _rewardRate APR в процентах (например, 10 = 10% годовых)
     * @param _minStakeAmount Минимальная сумма для стейкинга
     * @param _lockPeriodDays Период блокировки в днях
     */
    function createPool(
        uint256 _rewardRate,
        uint256 _minStakeAmount,
        uint256 _lockPeriodDays
    ) external onlyOwner returns (uint256) {
        require(_rewardRate > 0 && _rewardRate <= 1000, "Invalid reward rate");
        require(_minStakeAmount > 0, "Min stake must be positive");

        uint256 poolId = poolCounter;

        pools[poolId] = StakingPool({
            id: poolId,
            rewardRate: _rewardRate,
            minStakeAmount: _minStakeAmount,
            lockPeriod: _lockPeriodDays * 1 days,
            totalStaked: 0,
            active: true
        });

        poolCounter++;

        emit PoolCreated(poolId, _rewardRate, _minStakeAmount, _lockPeriodDays * 1 days);

        return poolId;
    }

    /**
     * @dev Застейкать средства
     * @param _poolId ID пула
     */
    function stake(uint256 _poolId)
        external
        payable
        poolExists(_poolId)
        poolActive(_poolId)
    {
        StakingPool storage pool = pools[_poolId];
        Stake storage userStake = stakes[_poolId][msg.sender];

        require(msg.value >= pool.minStakeAmount, "Below minimum stake");

        // Если уже есть стейк, начисляем награды
        if (userStake.amount > 0) {
            uint256 pending = calculateReward(_poolId, msg.sender);
            userStake.rewardDebt += pending;
        } else {
            // Первый стейк - добавляем в список пулов пользователя
            userPools[msg.sender].push(_poolId);
        }

        userStake.amount += msg.value;
        userStake.startTime = block.timestamp;
        userStake.lastClaimTime = block.timestamp;

        pool.totalStaked += msg.value;

        emit Staked(_poolId, msg.sender, msg.value);
    }

    /**
     * @dev Вывести застейканные средства
     * @param _poolId ID пула
     * @param _amount Сумма для вывода
     */
    function unstake(uint256 _poolId, uint256 _amount)
        external
        poolExists(_poolId)
    {
        StakingPool storage pool = pools[_poolId];
        Stake storage userStake = stakes[_poolId][msg.sender];

        require(userStake.amount >= _amount, "Insufficient staked amount");
        require(
            block.timestamp >= userStake.startTime + pool.lockPeriod,
            "Lock period not ended"
        );

        // Начисление наград перед выводом
        uint256 reward = calculateReward(_poolId, msg.sender);
        if (reward > 0) {
            userStake.rewardDebt += reward;
        }

        userStake.amount -= _amount;
        pool.totalStaked -= _amount;

        // Перевод средств пользователю
        payable(msg.sender).transfer(_amount);

        emit Unstaked(_poolId, msg.sender, _amount);
    }

    /**
     * @dev Получить награды
     * @param _poolId ID пула
     */
    function claimReward(uint256 _poolId) external poolExists(_poolId) {
        Stake storage userStake = stakes[_poolId][msg.sender];

        require(userStake.amount > 0, "No active stake");

        uint256 reward = calculateReward(_poolId, msg.sender);
        reward += userStake.rewardDebt;

        require(reward > 0, "No rewards available");
        require(address(this).balance >= reward, "Insufficient contract balance");

        userStake.lastClaimTime = block.timestamp;
        userStake.rewardDebt = 0;

        totalRewardsDistributed += reward;

        payable(msg.sender).transfer(reward);

        emit RewardClaimed(_poolId, msg.sender, reward);
    }

    /**
     * @dev Вывести средства и получить награды
     * @param _poolId ID пула
     */
    function unstakeAndClaim(uint256 _poolId) external poolExists(_poolId) {
        StakingPool storage pool = pools[_poolId];
        Stake storage userStake = stakes[_poolId][msg.sender];

        require(userStake.amount > 0, "No active stake");
        require(
            block.timestamp >= userStake.startTime + pool.lockPeriod,
            "Lock period not ended"
        );

        uint256 stakedAmount = userStake.amount;
        uint256 reward = calculateReward(_poolId, msg.sender);
        reward += userStake.rewardDebt;

        // Обнуление стейка
        userStake.amount = 0;
        userStake.rewardDebt = 0;
        userStake.lastClaimTime = block.timestamp;

        pool.totalStaked -= stakedAmount;
        totalRewardsDistributed += reward;

        // Перевод средств
        uint256 totalAmount = stakedAmount + reward;
        require(address(this).balance >= totalAmount, "Insufficient contract balance");

        payable(msg.sender).transfer(totalAmount);

        emit Unstaked(_poolId, msg.sender, stakedAmount);
        emit RewardClaimed(_poolId, msg.sender, reward);
    }

    /**
     * @dev Расчет текущей награды
     * @param _poolId ID пула
     * @param _user Адрес пользователя
     */
    function calculateReward(uint256 _poolId, address _user)
        public
        view
        poolExists(_poolId)
        returns (uint256)
    {
        StakingPool storage pool = pools[_poolId];
        Stake storage userStake = stakes[_poolId][_user];

        if (userStake.amount == 0) {
            return 0;
        }

        uint256 stakingDuration = block.timestamp - userStake.lastClaimTime;

        // Расчет награды: (сумма * процент * время) / (100 * год в секундах)
        uint256 reward = (userStake.amount * pool.rewardRate * stakingDuration) /
            (100 * 365 days);

        return reward;
    }

    /**
     * @dev Получить полную информацию о стейке пользователя
     * @param _poolId ID пула
     * @param _user Адрес пользователя
     */
    function getStakeInfo(uint256 _poolId, address _user)
        external
        view
        poolExists(_poolId)
        returns (
            uint256 amount,
            uint256 startTime,
            uint256 lockEndTime,
            uint256 pendingReward,
            uint256 rewardDebt,
            bool canUnstake
        )
    {
        StakingPool storage pool = pools[_poolId];
        Stake storage userStake = stakes[_poolId][_user];

        uint256 pending = calculateReward(_poolId, _user);
        uint256 lockEnd = userStake.startTime + pool.lockPeriod;
        bool unlocked = block.timestamp >= lockEnd;

        return (
            userStake.amount,
            userStake.startTime,
            lockEnd,
            pending,
            userStake.rewardDebt,
            unlocked
        );
    }

    /**
     * @dev Получить информацию о пуле
     * @param _poolId ID пула
     */
    function getPoolInfo(uint256 _poolId)
        external
        view
        poolExists(_poolId)
        returns (
            uint256 rewardRate,
            uint256 minStakeAmount,
            uint256 lockPeriod,
            uint256 totalStaked,
            bool active
        )
    {
        StakingPool storage pool = pools[_poolId];
        return (
            pool.rewardRate,
            pool.minStakeAmount,
            pool.lockPeriod,
            pool.totalStaked,
            pool.active
        );
    }

    /**
     * @dev Получить все пулы пользователя
     * @param _user Адрес пользователя
     */
    function getUserPools(address _user) external view returns (uint256[] memory) {
        return userPools[_user];
    }

    /**
     * @dev Изменить статус пула
     * @param _poolId ID пула
     * @param _active Новый статус
     */
    function setPoolStatus(uint256 _poolId, bool _active)
        external
        onlyOwner
        poolExists(_poolId)
    {
        pools[_poolId].active = _active;
        emit PoolStatusChanged(_poolId, _active);
    }

    /**
     * @dev Изменить ставку награды
     * @param _poolId ID пула
     * @param _newRate Новая ставка
     */
    function updateRewardRate(uint256 _poolId, uint256 _newRate)
        external
        onlyOwner
        poolExists(_poolId)
    {
        require(_newRate > 0 && _newRate <= 1000, "Invalid reward rate");
        pools[_poolId].rewardRate = _newRate;
        emit RewardRateUpdated(_poolId, _newRate);
    }

    /**
     * @dev Пополнить контракт наградами
     */
    function fundRewards() external payable onlyOwner {
        require(msg.value > 0, "Amount must be positive");
    }

    /**
     * @dev Вывести средства контракта (экстренный случай)
     * @param _amount Сумма для вывода
     */
    function emergencyWithdraw(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(owner).transfer(_amount);
    }

    /**
     * @dev Получить баланс контракта
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Передача владения
     * @param _newOwner Новый владелец
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }
}
