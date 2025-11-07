// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DAO
 * @dev Децентрализованная автономная организация с управлением через голосование
 */
contract DAO {
    // Типы предложений
    enum ProposalType {
        AddMember,
        RemoveMember,
        Transfer,
        ChangeQuorum,
        Custom
    }

    // Статус предложения
    enum ProposalStatus {
        Active,
        Executed,
        Rejected,
        Cancelled
    }

    // Структура предложения
    struct Proposal {
        uint256 id;
        ProposalType proposalType;
        address proposer;
        string description;
        address target;
        uint256 amount;
        bytes data;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        ProposalStatus status;
        mapping(address => bool) hasVoted;
        mapping(address => bool) voteChoice;
    }

    // Переменные состояния
    uint256 public proposalCounter;
    uint256 public memberCount;
    uint256 public quorumPercentage = 51; // 51% кворум
    uint256 public votingDuration = 3 days;
    uint256 public proposalDeposit = 0.01 ether;

    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public members;
    mapping(address => uint256) public memberSince;
    mapping(address => uint256[]) public memberProposals;

    address[] public memberList;

    // События
    event MemberAdded(address indexed member);
    event MemberRemoved(address indexed member);

    event ProposalCreated(
        uint256 indexed proposalId,
        ProposalType proposalType,
        address indexed proposer,
        string description
    );

    event Voted(
        uint256 indexed proposalId,
        address indexed voter,
        bool support
    );

    event ProposalExecuted(uint256 indexed proposalId);
    event ProposalRejected(uint256 indexed proposalId);
    event ProposalCancelled(uint256 indexed proposalId);

    event FundsReceived(address indexed from, uint256 amount);
    event FundsTransferred(address indexed to, uint256 amount);

    // Модификаторы
    modifier onlyMember() {
        require(members[msg.sender], "Only members can call this");
        _;
    }

    modifier proposalExists(uint256 _proposalId) {
        require(_proposalId < proposalCounter, "Proposal does not exist");
        _;
    }

    modifier proposalActive(uint256 _proposalId) {
        require(
            proposals[_proposalId].status == ProposalStatus.Active,
            "Proposal not active"
        );
        _;
    }

    constructor() {
        // Создатель становится первым членом
        members[msg.sender] = true;
        memberSince[msg.sender] = block.timestamp;
        memberList.push(msg.sender);
        memberCount = 1;

        emit MemberAdded(msg.sender);
    }

    // Получение средств
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }

    /**
     * @dev Создание предложения о добавлении члена
     * @param _member Адрес кандидата
     * @param _description Описание предложения
     */
    function proposeMemberAddition(address _member, string memory _description)
        external
        payable
        onlyMember
        returns (uint256)
    {
        require(!members[_member], "Already a member");
        require(msg.value >= proposalDeposit, "Insufficient deposit");

        return _createProposal(
            ProposalType.AddMember,
            _description,
            _member,
            0,
            ""
        );
    }

    /**
     * @dev Создание предложения об удалении члена
     * @param _member Адрес члена
     * @param _description Описание предложения
     */
    function proposeMemberRemoval(address _member, string memory _description)
        external
        payable
        onlyMember
        returns (uint256)
    {
        require(members[_member], "Not a member");
        require(_member != msg.sender, "Cannot remove yourself");

        return _createProposal(
            ProposalType.RemoveMember,
            _description,
            _member,
            0,
            ""
        );
    }

    /**
     * @dev Создание предложения о переводе средств
     * @param _to Адрес получателя
     * @param _amount Сумма перевода
     * @param _description Описание предложения
     */
    function proposeTransfer(
        address _to,
        uint256 _amount,
        string memory _description
    ) external payable onlyMember returns (uint256) {
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Amount must be positive");
        require(address(this).balance >= _amount, "Insufficient DAO balance");

        return _createProposal(
            ProposalType.Transfer,
            _description,
            _to,
            _amount,
            ""
        );
    }

    /**
     * @dev Создание предложения об изменении кворума
     * @param _newQuorum Новый процент кворума
     * @param _description Описание предложения
     */
    function proposeQuorumChange(uint256 _newQuorum, string memory _description)
        external
        payable
        onlyMember
        returns (uint256)
    {
        require(_newQuorum > 0 && _newQuorum <= 100, "Invalid quorum");

        return _createProposal(
            ProposalType.ChangeQuorum,
            _description,
            address(0),
            _newQuorum,
            ""
        );
    }

    /**
     * @dev Создание кастомного предложения
     * @param _description Описание предложения
     * @param _target Целевой адрес
     * @param _data Данные для вызова
     */
    function proposeCustom(
        string memory _description,
        address _target,
        bytes memory _data
    ) external payable onlyMember returns (uint256) {
        require(_target != address(0), "Invalid target");

        return _createProposal(
            ProposalType.Custom,
            _description,
            _target,
            0,
            _data
        );
    }

    /**
     * @dev Внутренняя функция создания предложения
     */
    function _createProposal(
        ProposalType _type,
        string memory _description,
        address _target,
        uint256 _amount,
        bytes memory _data
    ) private returns (uint256) {
        uint256 proposalId = proposalCounter;
        Proposal storage proposal = proposals[proposalId];

        proposal.id = proposalId;
        proposal.proposalType = _type;
        proposal.proposer = msg.sender;
        proposal.description = _description;
        proposal.target = _target;
        proposal.amount = _amount;
        proposal.data = _data;
        proposal.votesFor = 0;
        proposal.votesAgainst = 0;
        proposal.deadline = block.timestamp + votingDuration;
        proposal.status = ProposalStatus.Active;

        memberProposals[msg.sender].push(proposalId);
        proposalCounter++;

        emit ProposalCreated(proposalId, _type, msg.sender, _description);

        return proposalId;
    }

    /**
     * @dev Голосование за предложение
     * @param _proposalId ID предложения
     * @param _support true - за, false - против
     */
    function vote(uint256 _proposalId, bool _support)
        external
        onlyMember
        proposalExists(_proposalId)
        proposalActive(_proposalId)
    {
        Proposal storage proposal = proposals[_proposalId];

        require(block.timestamp < proposal.deadline, "Voting ended");
        require(!proposal.hasVoted[msg.sender], "Already voted");

        proposal.hasVoted[msg.sender] = true;
        proposal.voteChoice[msg.sender] = _support;

        if (_support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        emit Voted(_proposalId, msg.sender, _support);

        // Автоматическое исполнение если все проголосовали
        if (proposal.votesFor + proposal.votesAgainst >= memberCount) {
            _finalizeProposal(_proposalId);
        }
    }

    /**
     * @dev Завершение голосования и исполнение предложения
     * @param _proposalId ID предложения
     */
    function executeProposal(uint256 _proposalId)
        external
        proposalExists(_proposalId)
        proposalActive(_proposalId)
    {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp >= proposal.deadline, "Voting still active");

        _finalizeProposal(_proposalId);
    }

    /**
     * @dev Внутренняя функция завершения предложения
     */
    function _finalizeProposal(uint256 _proposalId) private {
        Proposal storage proposal = proposals[_proposalId];

        uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
        uint256 quorumVotes = (memberCount * quorumPercentage) / 100;

        // Проверка кворума
        if (totalVotes < quorumVotes) {
            proposal.status = ProposalStatus.Rejected;
            emit ProposalRejected(_proposalId);
            return;
        }

        // Проверка большинства
        if (proposal.votesFor <= proposal.votesAgainst) {
            proposal.status = ProposalStatus.Rejected;
            emit ProposalRejected(_proposalId);
            return;
        }

        // Исполнение предложения
        bool success = _executeProposalAction(_proposalId);

        if (success) {
            proposal.status = ProposalStatus.Executed;
            emit ProposalExecuted(_proposalId);
        } else {
            proposal.status = ProposalStatus.Rejected;
            emit ProposalRejected(_proposalId);
        }
    }

    /**
     * @dev Исполнение действия предложения
     */
    function _executeProposalAction(uint256 _proposalId)
        private
        returns (bool)
    {
        Proposal storage proposal = proposals[_proposalId];

        if (proposal.proposalType == ProposalType.AddMember) {
            return _addMember(proposal.target);
        } else if (proposal.proposalType == ProposalType.RemoveMember) {
            return _removeMember(proposal.target);
        } else if (proposal.proposalType == ProposalType.Transfer) {
            return _transferFunds(proposal.target, proposal.amount);
        } else if (proposal.proposalType == ProposalType.ChangeQuorum) {
            quorumPercentage = proposal.amount;
            return true;
        } else if (proposal.proposalType == ProposalType.Custom) {
            (bool success, ) = proposal.target.call(proposal.data);
            return success;
        }

        return false;
    }

    /**
     * @dev Добавление нового члена
     */
    function _addMember(address _member) private returns (bool) {
        if (!members[_member]) {
            members[_member] = true;
            memberSince[_member] = block.timestamp;
            memberList.push(_member);
            memberCount++;
            emit MemberAdded(_member);
            return true;
        }
        return false;
    }

    /**
     * @dev Удаление члена
     */
    function _removeMember(address _member) private returns (bool) {
        if (members[_member] && memberCount > 1) {
            members[_member] = false;
            memberCount--;

            // Удаление из массива
            for (uint256 i = 0; i < memberList.length; i++) {
                if (memberList[i] == _member) {
                    memberList[i] = memberList[memberList.length - 1];
                    memberList.pop();
                    break;
                }
            }

            emit MemberRemoved(_member);
            return true;
        }
        return false;
    }

    /**
     * @dev Перевод средств
     */
    function _transferFunds(address _to, uint256 _amount)
        private
        returns (bool)
    {
        if (address(this).balance >= _amount) {
            payable(_to).transfer(_amount);
            emit FundsTransferred(_to, _amount);
            return true;
        }
        return false;
    }

    /**
     * @dev Получить информацию о предложении
     */
    function getProposal(uint256 _proposalId)
        external
        view
        proposalExists(_proposalId)
        returns (
            ProposalType proposalType,
            address proposer,
            string memory description,
            address target,
            uint256 amount,
            uint256 votesFor,
            uint256 votesAgainst,
            uint256 deadline,
            ProposalStatus status
        )
    {
        Proposal storage proposal = proposals[_proposalId];
        return (
            proposal.proposalType,
            proposal.proposer,
            proposal.description,
            proposal.target,
            proposal.amount,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.deadline,
            proposal.status
        );
    }

    /**
     * @dev Проверить, голосовал ли член
     */
    function hasVoted(uint256 _proposalId, address _member)
        external
        view
        proposalExists(_proposalId)
        returns (bool)
    {
        return proposals[_proposalId].hasVoted[_member];
    }

    /**
     * @dev Получить выбор голоса члена
     */
    function getVoteChoice(uint256 _proposalId, address _member)
        external
        view
        proposalExists(_proposalId)
        returns (bool)
    {
        return proposals[_proposalId].voteChoice[_member];
    }

    /**
     * @dev Получить баланс DAO
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Получить список всех членов
     */
    function getMembers() external view returns (address[] memory) {
        return memberList;
    }
}
