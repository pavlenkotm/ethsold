// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Voting
 * @dev Децентрализованная система голосования с возможностью создания предложений
 */
contract Voting {
    // Структура предложения для голосования
    struct Proposal {
        uint256 id;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        address proposer;
        bool executed;
        mapping(address => bool) hasVoted;
    }

    // Переменные состояния
    address public owner;
    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public voters;
    uint256 public votingDuration = 7 days;

    // События
    event ProposalCreated(
        uint256 indexed proposalId,
        string description,
        address proposer,
        uint256 deadline
    );

    event Voted(
        uint256 indexed proposalId,
        address indexed voter,
        bool support
    );

    event ProposalExecuted(uint256 indexed proposalId);
    event VoterRegistered(address indexed voter);

    // Модификаторы
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier onlyRegisteredVoter() {
        require(voters[msg.sender], "Not a registered voter");
        _;
    }

    modifier proposalExists(uint256 _proposalId) {
        require(_proposalId < proposalCount, "Proposal does not exist");
        _;
    }

    constructor() {
        owner = msg.sender;
        voters[msg.sender] = true; // Владелец автоматически становится избирателем
    }

    /**
     * @dev Регистрация нового избирателя
     * @param _voter Адрес избирателя
     */
    function registerVoter(address _voter) external onlyOwner {
        require(!voters[_voter], "Voter already registered");
        voters[_voter] = true;
        emit VoterRegistered(_voter);
    }

    /**
     * @dev Создание нового предложения
     * @param _description Описание предложения
     */
    function createProposal(string memory _description) external onlyRegisteredVoter {
        require(bytes(_description).length > 0, "Description cannot be empty");

        uint256 proposalId = proposalCount;
        Proposal storage newProposal = proposals[proposalId];

        newProposal.id = proposalId;
        newProposal.description = _description;
        newProposal.votesFor = 0;
        newProposal.votesAgainst = 0;
        newProposal.deadline = block.timestamp + votingDuration;
        newProposal.proposer = msg.sender;
        newProposal.executed = false;

        proposalCount++;

        emit ProposalCreated(
            proposalId,
            _description,
            msg.sender,
            newProposal.deadline
        );
    }

    /**
     * @dev Голосование за или против предложения
     * @param _proposalId ID предложения
     * @param _support true - за, false - против
     */
    function vote(uint256 _proposalId, bool _support)
        external
        onlyRegisteredVoter
        proposalExists(_proposalId)
    {
        Proposal storage proposal = proposals[_proposalId];

        require(block.timestamp < proposal.deadline, "Voting period has ended");
        require(!proposal.hasVoted[msg.sender], "Already voted");
        require(!proposal.executed, "Proposal already executed");

        proposal.hasVoted[msg.sender] = true;

        if (_support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        emit Voted(_proposalId, msg.sender, _support);
    }

    /**
     * @dev Получение информации о предложении
     * @param _proposalId ID предложения
     */
    function getProposal(uint256 _proposalId)
        external
        view
        proposalExists(_proposalId)
        returns (
            uint256 id,
            string memory description,
            uint256 votesFor,
            uint256 votesAgainst,
            uint256 deadline,
            address proposer,
            bool executed,
            bool isActive
        )
    {
        Proposal storage proposal = proposals[_proposalId];
        return (
            proposal.id,
            proposal.description,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.deadline,
            proposal.proposer,
            proposal.executed,
            block.timestamp < proposal.deadline
        );
    }

    /**
     * @dev Проверка, голосовал ли адрес
     * @param _proposalId ID предложения
     * @param _voter Адрес избирателя
     */
    function hasVoted(uint256 _proposalId, address _voter)
        external
        view
        proposalExists(_proposalId)
        returns (bool)
    {
        return proposals[_proposalId].hasVoted[_voter];
    }

    /**
     * @dev Исполнение предложения (закрытие голосования)
     * @param _proposalId ID предложения
     */
    function executeProposal(uint256 _proposalId)
        external
        proposalExists(_proposalId)
    {
        Proposal storage proposal = proposals[_proposalId];

        require(block.timestamp >= proposal.deadline, "Voting still in progress");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;
        emit ProposalExecuted(_proposalId);
    }

    /**
     * @dev Изменение длительности голосования
     * @param _newDuration Новая длительность в секундах
     */
    function setVotingDuration(uint256 _newDuration) external onlyOwner {
        require(_newDuration > 0, "Duration must be positive");
        votingDuration = _newDuration;
    }
}
