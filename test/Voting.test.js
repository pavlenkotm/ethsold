const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Voting Contract", function () {
  let voting;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    const Voting = await ethers.getContractFactory("Voting");
    voting = await Voting.deploy();
    await voting.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await voting.owner()).to.equal(owner.address);
    });

    it("Should register owner as voter", async function () {
      expect(await voting.voters(owner.address)).to.equal(true);
    });
  });

  describe("Voter Registration", function () {
    it("Should allow owner to register voters", async function () {
      await voting.registerVoter(addr1.address);
      expect(await voting.voters(addr1.address)).to.equal(true);
    });

    it("Should not allow non-owner to register voters", async function () {
      await expect(
        voting.connect(addr1).registerVoter(addr2.address)
      ).to.be.revertedWith("Only owner can call this");
    });

    it("Should not allow registering same voter twice", async function () {
      await voting.registerVoter(addr1.address);
      await expect(
        voting.registerVoter(addr1.address)
      ).to.be.revertedWith("Voter already registered");
    });
  });

  describe("Proposal Creation", function () {
    beforeEach(async function () {
      await voting.registerVoter(addr1.address);
    });

    it("Should allow registered voter to create proposal", async function () {
      await expect(
        voting.connect(addr1).createProposal("Test Proposal")
      ).to.emit(voting, "ProposalCreated");
    });

    it("Should not allow non-voter to create proposal", async function () {
      await expect(
        voting.connect(addr2).createProposal("Test Proposal")
      ).to.be.revertedWith("Not a registered voter");
    });

    it("Should increment proposal count", async function () {
      await voting.connect(addr1).createProposal("Proposal 1");
      expect(await voting.proposalCount()).to.equal(1);

      await voting.connect(addr1).createProposal("Proposal 2");
      expect(await voting.proposalCount()).to.equal(2);
    });
  });

  describe("Voting", function () {
    beforeEach(async function () {
      await voting.registerVoter(addr1.address);
      await voting.registerVoter(addr2.address);
      await voting.createProposal("Test Proposal");
    });

    it("Should allow registered voter to vote", async function () {
      await expect(
        voting.connect(addr1).vote(0, true)
      ).to.emit(voting, "Voted");
    });

    it("Should not allow non-voter to vote", async function () {
      const [, , , addr3] = await ethers.getSigners();
      await expect(
        voting.connect(addr3).vote(0, true)
      ).to.be.revertedWith("Not a registered voter");
    });

    it("Should not allow voting twice", async function () {
      await voting.connect(addr1).vote(0, true);
      await expect(
        voting.connect(addr1).vote(0, true)
      ).to.be.revertedWith("Already voted");
    });

    it("Should count votes correctly", async function () {
      await voting.connect(addr1).vote(0, true);
      await voting.connect(addr2).vote(0, false);

      const proposal = await voting.getProposal(0);
      expect(proposal.votesFor).to.equal(1);
      expect(proposal.votesAgainst).to.equal(1);
    });
  });

  describe("Proposal Execution", function () {
    beforeEach(async function () {
      await voting.registerVoter(addr1.address);
      await voting.createProposal("Test Proposal");
      await voting.connect(addr1).vote(0, true);
    });

    it("Should not allow execution before deadline", async function () {
      await expect(
        voting.executeProposal(0)
      ).to.be.revertedWith("Voting still in progress");
    });

    it("Should allow execution after deadline", async function () {
      // Увеличиваем время на 8 дней
      await ethers.provider.send("evm_increaseTime", [8 * 24 * 60 * 60]);
      await ethers.provider.send("evm_mine");

      await expect(
        voting.executeProposal(0)
      ).to.emit(voting, "ProposalExecuted");
    });
  });
});
