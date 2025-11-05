const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("Crowdfunding Contract", function () {
  let crowdfunding;
  let owner;
  let creator;
  let backer1;
  let backer2;

  beforeEach(async function () {
    [owner, creator, backer1, backer2] = await ethers.getSigners();

    const Crowdfunding = await ethers.getContractFactory("Crowdfunding");
    crowdfunding = await Crowdfunding.deploy();
    await crowdfunding.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right platform owner", async function () {
      expect(await crowdfunding.platformOwner()).to.equal(owner.address);
    });

    it("Should set default platform fee", async function () {
      expect(await crowdfunding.platformFee()).to.equal(2);
    });
  });

  describe("Project Creation", function () {
    it("Should allow creating a project", async function () {
      const goalAmount = ethers.parseEther("10");
      await crowdfunding.connect(creator).createProject(
        "Test Project",
        "Test Description",
        goalAmount,
        30
      );

      const project = await crowdfunding.getProject(0);
      expect(project.title).to.equal("Test Project");
      expect(project.goalAmount).to.equal(goalAmount);
    });

    it("Should emit ProjectCreated event", async function () {
      const goalAmount = ethers.parseEther("10");
      await expect(
        crowdfunding.connect(creator).createProject(
          "Test",
          "Description",
          goalAmount,
          30
        )
      ).to.emit(crowdfunding, "ProjectCreated");
    });

    it("Should not allow empty title", async function () {
      await expect(
        crowdfunding.connect(creator).createProject(
          "",
          "Description",
          ethers.parseEther("10"),
          30
        )
      ).to.be.revertedWith("Title cannot be empty");
    });

    it("Should not allow zero goal amount", async function () {
      await expect(
        crowdfunding.connect(creator).createProject(
          "Test",
          "Description",
          0,
          30
        )
      ).to.be.revertedWith("Goal amount must be positive");
    });

    it("Should not allow duration over 90 days", async function () {
      await expect(
        crowdfunding.connect(creator).createProject(
          "Test",
          "Description",
          ethers.parseEther("10"),
          91
        )
      ).to.be.revertedWith("Duration must be 1-90 days");
    });
  });

  describe("Contributions", function () {
    beforeEach(async function () {
      await crowdfunding.connect(creator).createProject(
        "Test Project",
        "Test Description",
        ethers.parseEther("10"),
        30
      );
    });

    it("Should allow contributing to project", async function () {
      const amount = ethers.parseEther("5");
      await crowdfunding.connect(backer1).contribute(0, { value: amount });

      const project = await crowdfunding.getProject(0);
      expect(project.raisedAmount).to.equal(amount);
    });

    it("Should emit ContributionMade event", async function () {
      const amount = ethers.parseEther("5");
      await expect(
        crowdfunding.connect(backer1).contribute(0, { value: amount })
      )
        .to.emit(crowdfunding, "ContributionMade")
        .withArgs(0, backer1.address, amount);
    });

    it("Should track individual contributions", async function () {
      const amount = ethers.parseEther("3");
      await crowdfunding.connect(backer1).contribute(0, { value: amount });

      const contribution = await crowdfunding.getContribution(0, backer1.address);
      expect(contribution).to.equal(amount);
    });

    it("Should not allow zero contribution", async function () {
      await expect(
        crowdfunding.connect(backer1).contribute(0, { value: 0 })
      ).to.be.revertedWith("Contribution must be positive");
    });

    it("Should not allow creator to contribute to own project", async function () {
      await expect(
        crowdfunding.connect(creator).contribute(0, { value: ethers.parseEther("1") })
      ).to.be.revertedWith("Creator cannot contribute to own project");
    });

    it("Should mark project as completed when goal reached", async function () {
      await crowdfunding.connect(backer1).contribute(0, { value: ethers.parseEther("10") });

      const project = await crowdfunding.getProject(0);
      expect(project.completed).to.be.true;
    });

    it("Should not allow contribution after deadline", async function () {
      await time.increase(31 * 24 * 60 * 60); // 31 days

      await expect(
        crowdfunding.connect(backer1).contribute(0, { value: ethers.parseEther("1") })
      ).to.be.revertedWith("Project deadline has passed");
    });
  });

  describe("Fund Withdrawal", function () {
    beforeEach(async function () {
      await crowdfunding.connect(creator).createProject(
        "Test Project",
        "Test Description",
        ethers.parseEther("10"),
        30
      );
      await crowdfunding.connect(backer1).contribute(0, { value: ethers.parseEther("10") });
    });

    it("Should allow creator to withdraw when goal reached", async function () {
      const initialBalance = await ethers.provider.getBalance(creator.address);

      const tx = await crowdfunding.connect(creator).withdrawFunds(0);
      const receipt = await tx.wait();
      const gasUsed = receipt.gasUsed * receipt.gasPrice;

      const finalBalance = await ethers.provider.getBalance(creator.address);
      const expectedAmount = ethers.parseEther("9.8"); // 10 ETH - 2% fee

      expect(finalBalance).to.be.closeTo(
        initialBalance + expectedAmount - gasUsed,
        ethers.parseEther("0.01")
      );
    });

    it("Should emit FundsWithdrawn event", async function () {
      await expect(crowdfunding.connect(creator).withdrawFunds(0))
        .to.emit(crowdfunding, "FundsWithdrawn");
    });

    it("Should not allow withdrawal if goal not reached", async function () {
      await crowdfunding.connect(creator).createProject(
        "Test 2",
        "Description",
        ethers.parseEther("20"),
        30
      );
      await crowdfunding.connect(backer1).contribute(1, { value: ethers.parseEther("5") });

      await time.increase(31 * 24 * 60 * 60);

      await expect(
        crowdfunding.connect(creator).withdrawFunds(1)
      ).to.be.revertedWith("Goal not reached");
    });

    it("Should not allow non-creator to withdraw", async function () {
      await expect(
        crowdfunding.connect(backer1).withdrawFunds(0)
      ).to.be.revertedWith("Only creator can call this");
    });
  });

  describe("Refunds", function () {
    beforeEach(async function () {
      await crowdfunding.connect(creator).createProject(
        "Test Project",
        "Test Description",
        ethers.parseEther("10"),
        30
      );
      await crowdfunding.connect(backer1).contribute(0, { value: ethers.parseEther("5") });
    });

    it("Should allow refund when goal not reached", async function () {
      await time.increase(31 * 24 * 60 * 60);

      const initialBalance = await ethers.provider.getBalance(backer1.address);
      const tx = await crowdfunding.connect(backer1).refund(0);
      const receipt = await tx.wait();
      const gasUsed = receipt.gasUsed * receipt.gasPrice;

      const finalBalance = await ethers.provider.getBalance(backer1.address);
      expect(finalBalance).to.be.closeTo(
        initialBalance + ethers.parseEther("5") - gasUsed,
        ethers.parseEther("0.01")
      );
    });

    it("Should emit RefundIssued event", async function () {
      await time.increase(31 * 24 * 60 * 60);

      await expect(crowdfunding.connect(backer1).refund(0))
        .to.emit(crowdfunding, "RefundIssued");
    });

    it("Should not allow refund if goal was reached", async function () {
      await crowdfunding.connect(backer2).contribute(0, { value: ethers.parseEther("5") });
      await time.increase(31 * 24 * 60 * 60);

      await expect(
        crowdfunding.connect(backer1).refund(0)
      ).to.be.revertedWith("Goal was reached, refund not available");
    });

    it("Should not allow refund before deadline", async function () {
      await expect(
        crowdfunding.connect(backer1).refund(0)
      ).to.be.revertedWith("Project still in progress");
    });
  });

  describe("Platform Fee", function () {
    it("Should allow owner to change platform fee", async function () {
      await crowdfunding.connect(owner).setPlatformFee(5);
      expect(await crowdfunding.platformFee()).to.equal(5);
    });

    it("Should not allow non-owner to change fee", async function () {
      await expect(
        crowdfunding.connect(backer1).setPlatformFee(5)
      ).to.be.revertedWith("Only platform owner");
    });

    it("Should not allow fee over 10%", async function () {
      await expect(
        crowdfunding.connect(owner).setPlatformFee(11)
      ).to.be.revertedWith("Fee cannot exceed 10%");
    });
  });
});
