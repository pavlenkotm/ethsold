// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Voting
 * @dev Decentralized voting system with proposal creation capability
 * @notice Allows registered voters to create and vote on proposals
 */
contract Voting {
    // Proposal structure for voting
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

    // State variables
    address public owner;
    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public voters;
    uint256 public votingDuration = 7 days;

    // Events
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

    // Modifiers
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
        voters[msg.sender] = true; // Owner automatically becomes a voter
    }

    /**
     * @dev Register a new voter
     * @param _voter Voter address
     */
    function registerVoter(address _voter) external onlyOwner {
        require(!voters[_voter], "Voter already registered");
        voters[_voter] = true;
        emit VoterRegistered(_voter);
    }

    /**
     * @dev Create a new proposal
     * @param _description Proposal description
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
     * @dev Vote for or against a proposal
     * @param _proposalId Proposal ID
     * @param _support true - for, false - against
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
     * @dev Get proposal information
     * @param _proposalId Proposal ID
     * @return id Proposal ID
     * @return description Proposal description
     * @return votesFor Number of votes in favor
     * @return votesAgainst Number of votes against
     * @return deadline Voting deadline timestamp
     * @return proposer Address of the proposer
     * @return executed Whether the proposal has been executed
     * @return isActive Whether the proposal is still active
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
     * @dev Check if an address has voted
     * @param _proposalId Proposal ID
     * @param _voter Voter address
     * @return True if the voter has voted on this proposal
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
     * @dev Execute proposal (close voting)
     * @param _proposalId Proposal ID
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
     * @dev Change voting duration
     * @param _newDuration New duration in seconds
     */
    function setVotingDuration(uint256 _newDuration) external onlyOwner {
        require(_newDuration > 0, "Duration must be positive");
        votingDuration = _newDuration;
    }
}
