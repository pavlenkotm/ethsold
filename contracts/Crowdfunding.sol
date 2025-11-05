// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Crowdfunding
 * @dev Платформа для краудфандинга с автоматическим возвратом средств
 */
contract Crowdfunding {
    // Структура проекта
    struct Project {
        uint256 id;
        address payable creator;
        string title;
        string description;
        uint256 goalAmount;
        uint256 raisedAmount;
        uint256 deadline;
        bool completed;
        bool fundsWithdrawn;
        mapping(address => uint256) contributions;
    }

    // Переменные состояния
    uint256 public projectCount;
    mapping(uint256 => Project) public projects;
    uint256 public platformFee = 2; // 2% комиссия платформы
    address payable public platformOwner;

    // События
    event ProjectCreated(
        uint256 indexed projectId,
        address indexed creator,
        string title,
        uint256 goalAmount,
        uint256 deadline
    );

    event ContributionMade(
        uint256 indexed projectId,
        address indexed contributor,
        uint256 amount
    );

    event FundsWithdrawn(
        uint256 indexed projectId,
        address indexed creator,
        uint256 amount
    );

    event RefundIssued(
        uint256 indexed projectId,
        address indexed contributor,
        uint256 amount
    );

    event ProjectCompleted(uint256 indexed projectId);

    // Модификаторы
    modifier projectExists(uint256 _projectId) {
        require(_projectId < projectCount, "Project does not exist");
        _;
    }

    modifier onlyCreator(uint256 _projectId) {
        require(
            msg.sender == projects[_projectId].creator,
            "Only creator can call this"
        );
        _;
    }

    modifier projectNotCompleted(uint256 _projectId) {
        require(!projects[_projectId].completed, "Project already completed");
        _;
    }

    constructor() {
        platformOwner = payable(msg.sender);
    }

    /**
     * @dev Создание нового проекта для сбора средств
     * @param _title Название проекта
     * @param _description Описание проекта
     * @param _goalAmount Целевая сумма в wei
     * @param _durationDays Продолжительность в днях
     */
    function createProject(
        string memory _title,
        string memory _description,
        uint256 _goalAmount,
        uint256 _durationDays
    ) external {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(_goalAmount > 0, "Goal amount must be positive");
        require(_durationDays > 0 && _durationDays <= 90, "Duration must be 1-90 days");

        uint256 projectId = projectCount;
        Project storage newProject = projects[projectId];

        newProject.id = projectId;
        newProject.creator = payable(msg.sender);
        newProject.title = _title;
        newProject.description = _description;
        newProject.goalAmount = _goalAmount;
        newProject.raisedAmount = 0;
        newProject.deadline = block.timestamp + (_durationDays * 1 days);
        newProject.completed = false;
        newProject.fundsWithdrawn = false;

        projectCount++;

        emit ProjectCreated(
            projectId,
            msg.sender,
            _title,
            _goalAmount,
            newProject.deadline
        );
    }

    /**
     * @dev Внесение средств в проект
     * @param _projectId ID проекта
     */
    function contribute(uint256 _projectId)
        external
        payable
        projectExists(_projectId)
        projectNotCompleted(_projectId)
    {
        Project storage project = projects[_projectId];

        require(block.timestamp < project.deadline, "Project deadline has passed");
        require(msg.value > 0, "Contribution must be positive");
        require(
            msg.sender != project.creator,
            "Creator cannot contribute to own project"
        );

        project.contributions[msg.sender] += msg.value;
        project.raisedAmount += msg.value;

        emit ContributionMade(_projectId, msg.sender, msg.value);

        // Автоматическое завершение если цель достигнута
        if (project.raisedAmount >= project.goalAmount) {
            project.completed = true;
            emit ProjectCompleted(_projectId);
        }
    }

    /**
     * @dev Вывод средств создателем при успешном завершении
     * @param _projectId ID проекта
     */
    function withdrawFunds(uint256 _projectId)
        external
        projectExists(_projectId)
        onlyCreator(_projectId)
    {
        Project storage project = projects[_projectId];

        require(
            block.timestamp >= project.deadline || project.completed,
            "Project still in progress"
        );
        require(
            project.raisedAmount >= project.goalAmount,
            "Goal not reached"
        );
        require(!project.fundsWithdrawn, "Funds already withdrawn");

        project.fundsWithdrawn = true;
        project.completed = true;

        // Расчет комиссии платформы
        uint256 fee = (project.raisedAmount * platformFee) / 100;
        uint256 creatorAmount = project.raisedAmount - fee;

        // Перевод средств
        platformOwner.transfer(fee);
        project.creator.transfer(creatorAmount);

        emit FundsWithdrawn(_projectId, project.creator, creatorAmount);
        emit ProjectCompleted(_projectId);
    }

    /**
     * @dev Возврат средств если цель не достигнута
     * @param _projectId ID проекта
     */
    function refund(uint256 _projectId)
        external
        projectExists(_projectId)
    {
        Project storage project = projects[_projectId];

        require(block.timestamp >= project.deadline, "Project still in progress");
        require(
            project.raisedAmount < project.goalAmount,
            "Goal was reached, refund not available"
        );
        require(!project.fundsWithdrawn, "Funds already withdrawn");

        uint256 contributedAmount = project.contributions[msg.sender];
        require(contributedAmount > 0, "No contribution found");

        project.contributions[msg.sender] = 0;

        payable(msg.sender).transfer(contributedAmount);

        emit RefundIssued(_projectId, msg.sender, contributedAmount);
    }

    /**
     * @dev Получение информации о проекте
     * @param _projectId ID проекта
     */
    function getProject(uint256 _projectId)
        external
        view
        projectExists(_projectId)
        returns (
            uint256 id,
            address creator,
            string memory title,
            string memory description,
            uint256 goalAmount,
            uint256 raisedAmount,
            uint256 deadline,
            bool completed,
            bool fundsWithdrawn,
            bool isActive,
            uint256 percentageFunded
        )
    {
        Project storage project = projects[_projectId];
        uint256 percentage = project.goalAmount > 0
            ? (project.raisedAmount * 100) / project.goalAmount
            : 0;

        return (
            project.id,
            project.creator,
            project.title,
            project.description,
            project.goalAmount,
            project.raisedAmount,
            project.deadline,
            project.completed,
            project.fundsWithdrawn,
            block.timestamp < project.deadline && !project.completed,
            percentage
        );
    }

    /**
     * @dev Получение вклада конкретного адреса в проект
     * @param _projectId ID проекта
     * @param _contributor Адрес спонсора
     */
    function getContribution(uint256 _projectId, address _contributor)
        external
        view
        projectExists(_projectId)
        returns (uint256)
    {
        return projects[_projectId].contributions[_contributor];
    }

    /**
     * @dev Изменение комиссии платформы (только владелец)
     * @param _newFee Новая комиссия в процентах
     */
    function setPlatformFee(uint256 _newFee) external {
        require(msg.sender == platformOwner, "Only platform owner");
        require(_newFee <= 10, "Fee cannot exceed 10%");
        platformFee = _newFee;
    }

    /**
     * @dev Получение текущего времени (для тестирования)
     */
    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }
}
