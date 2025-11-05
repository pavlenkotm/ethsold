const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("Voting Contract", function () {
  let voting;
  let owner;
  let voter1;
  let voter2;
  let voter3;

  beforeEach(async function () {
    [owner, voter1, voter2, voter3] = await ethers.getSigners();

    const Voting = await ethers.getContractFactory("Voting");
    voting = await Voting.deploy();
    await voting.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await voting.owner()).to.equal(owner.address);
    });

    it("Should register owner as voter", async function () {
      expect(await voting.voters(owner.address)).to.be.true;
    });

    it("Should set default voting duration", async function () {
      expect(await voting.votingDuration()).to.equal(7 * 24 * 60 * 60);
    });
  });

  describe("Voter Registration", function () {
    it("Should allow owner to register voters", async function () {
      await voting.registerVoter(voter1.address);
      expect(await voting.voters(voter1.address)).to.be.true;
    });

    it("Should emit VoterRegistered event", async function () {
      await expect(voting.registerVoter(voter1.address))
        .to.emit(voting, "VoterRegistered")
        .withArgs(voter1.address);
    });

    it("Should not allow non-owner to register voters", async function () {
      await expect(
        voting.connect(voter1).registerVoter(voter2.address)
      ).to.be.revertedWith("Only owner can call this");
    });

    it("Should not allow registering same voter twice", async function () {
      await voting.registerVoter(voter1.address);
      await expect(
        voting.registerVoter(voter1.address)
      ).to.be.revertedWith("Voter already registered");
    });
  });

  describe("Proposal Creation", function () {
    beforeEach(async function () {
      await voting.registerVoter(voter1.address);
    });

    it("Should allow registered voter to create proposal", async function () {
      await voting.connect(voter1).createProposal("Test Proposal");
      const proposal = await voting.getProposal(0);
      expect(proposal.description).to.equal("Test Proposal");
    });

    it("Should emit ProposalCreated event", async function () {
      await expect(voting.connect(voter1).createProposal("Test"))
        .to.emit(voting, "ProposalCreated");
    });

    it("Should not allow non-voter to create proposal", async function () {
      await expect(
        voting.connect(voter2).createProposal("Test")
      ).to.be.revertedWith("Not a registered voter");
    });

    it("Should not allow empty description", async function () {
      await expect(
        voting.connect(voter1).createProposal("")
      ).to.be.revertedWith("Description cannot be empty");
    });

    it("Should increment proposal count", async function () {
      await voting.connect(voter1).createProposal("Proposal 1");
      await voting.connect(voter1).createProposal("Proposal 2");
      expect(await voting.proposalCount()).to.equal(2);
    });
  });

  describe("Voting", function () {
    beforeEach(async function () {
      await voting.registerVoter(voter1.address);
      await voting.registerVoter(voter2.address);
      await voting.connect(voter1).createProposal("Test Proposal");
    });

    it("Should allow voting for proposal", async function () {
      await voting.connect(voter1).vote(0, true);
      const proposal = await voting.getProposal(0);
      expect(proposal.votesFor).to.equal(1);
    });

    it("Should allow voting against proposal", async function () {
      await voting.connect(voter1).vote(0, false);
      const proposal = await voting.getProposal(0);
      expect(proposal.votesAgainst).to.equal(1);
    });

    it("Should emit Voted event", async function () {
      await expect(voting.connect(voter1).vote(0, true))
        .to.emit(voting, "Voted")
        .withArgs(0, voter1.address, true);
    });

    it("Should not allow voting twice", async function () {
      await voting.connect(voter1).vote(0, true);
      await expect(
        voting.connect(voter1).vote(0, false)
      ).to.be.revertedWith("Already voted");
    });

    it("Should not allow non-voter to vote", async function () {
      await expect(
        voting.connect(voter3).vote(0, true)
      ).to.be.revertedWith("Not a registered voter");
    });

    it("Should not allow voting after deadline", async function () {
      await time.increase(8 * 24 * 60 * 60); // 8 days
      await expect(
        voting.connect(voter1).vote(0, true)
      ).to.be.revertedWith("Voting period has ended");
    });
  });

  describe("Proposal Execution", function () {
    beforeEach(async function () {
      await voting.registerVoter(voter1.address);
      await voting.connect(voter1).createProposal("Test Proposal");
    });

    it("Should not allow execution before deadline", async function () {
      await expect(
        voting.executeProposal(0)
      ).to.be.revertedWith("Voting still in progress");
    });

    it("Should allow execution after deadline", async function () {
      await time.increase(8 * 24 * 60 * 60);
      await voting.executeProposal(0);
      const proposal = await voting.getProposal(0);
      expect(proposal.executed).to.be.true;
    });

    it("Should emit ProposalExecuted event", async function () {
      await time.increase(8 * 24 * 60 * 60);
      await expect(voting.executeProposal(0))
        .to.emit(voting, "ProposalExecuted")
        .withArgs(0);
    });
  });
});
