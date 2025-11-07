const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SimpleToken", function () {
    let simpleToken;
    let owner;
    let addr1;
    let addr2;

    const INITIAL_SUPPLY = ethers.parseEther("1000000");

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        const SimpleToken = await ethers.getContractFactory("SimpleToken");
        simpleToken = await SimpleToken.deploy(
            "Test Token",
            "TEST",
            18,
            1000000
        );
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await simpleToken.owner()).to.equal(owner.address);
        });

        it("Should assign the total supply to the owner", async function () {
            const ownerBalance = await simpleToken.balanceOf(owner.address);
            expect(await simpleToken.totalSupply()).to.equal(ownerBalance);
        });

        it("Should have correct name and symbol", async function () {
            expect(await simpleToken.name()).to.equal("Test Token");
            expect(await simpleToken.symbol()).to.equal("TEST");
        });

        it("Should have correct decimals", async function () {
            expect(await simpleToken.decimals()).to.equal(18);
        });
    });

    describe("Transactions", function () {
        it("Should transfer tokens between accounts", async function () {
            const transferAmount = ethers.parseEther("100");

            await simpleToken.transfer(addr1.address, transferAmount);
            expect(await simpleToken.balanceOf(addr1.address)).to.equal(transferAmount);

            await simpleToken.connect(addr1).transfer(addr2.address, ethers.parseEther("50"));
            expect(await simpleToken.balanceOf(addr2.address)).to.equal(ethers.parseEther("50"));
        });

        it("Should fail if sender doesn't have enough tokens", async function () {
            const initialOwnerBalance = await simpleToken.balanceOf(owner.address);

            await expect(
                simpleToken.connect(addr1).transfer(owner.address, 1)
            ).to.be.reverted;

            expect(await simpleToken.balanceOf(owner.address)).to.equal(initialOwnerBalance);
        });

        it("Should update balances after transfers", async function () {
            const initialOwnerBalance = await simpleToken.balanceOf(owner.address);
            const transferAmount = ethers.parseEther("100");

            await simpleToken.transfer(addr1.address, transferAmount);
            await simpleToken.transfer(addr2.address, transferAmount);

            const finalOwnerBalance = await simpleToken.balanceOf(owner.address);
            expect(finalOwnerBalance).to.equal(
                initialOwnerBalance - transferAmount * 2n
            );

            expect(await simpleToken.balanceOf(addr1.address)).to.equal(transferAmount);
            expect(await simpleToken.balanceOf(addr2.address)).to.equal(transferAmount);
        });
    });

    describe("Allowances", function () {
        it("Should approve tokens for delegated transfer", async function () {
            const approveAmount = ethers.parseEther("100");

            await simpleToken.approve(addr1.address, approveAmount);
            expect(await simpleToken.allowance(owner.address, addr1.address))
                .to.equal(approveAmount);
        });

        it("Should allow delegated transfer", async function () {
            const approveAmount = ethers.parseEther("100");
            const transferAmount = ethers.parseEther("50");

            await simpleToken.approve(addr1.address, approveAmount);
            await simpleToken.connect(addr1).transferFrom(
                owner.address,
                addr2.address,
                transferAmount
            );

            expect(await simpleToken.balanceOf(addr2.address)).to.equal(transferAmount);
            expect(await simpleToken.allowance(owner.address, addr1.address))
                .to.equal(approveAmount - transferAmount);
        });

        it("Should fail if allowance is exceeded", async function () {
            const approveAmount = ethers.parseEther("100");

            await simpleToken.approve(addr1.address, approveAmount);
            await expect(
                simpleToken.connect(addr1).transferFrom(
                    owner.address,
                    addr2.address,
                    ethers.parseEther("200")
                )
            ).to.be.reverted;
        });
    });

    describe("Minting", function () {
        it("Should allow owner to mint new tokens", async function () {
            const mintAmount = ethers.parseEther("1000");
            const initialSupply = await simpleToken.totalSupply();

            await simpleToken.mint(addr1.address, mintAmount);

            expect(await simpleToken.balanceOf(addr1.address)).to.equal(mintAmount);
            expect(await simpleToken.totalSupply()).to.equal(initialSupply + mintAmount);
        });

        it("Should fail if non-owner tries to mint", async function () {
            await expect(
                simpleToken.connect(addr1).mint(addr2.address, ethers.parseEther("100"))
            ).to.be.reverted;
        });
    });

    describe("Burning", function () {
        it("Should allow burning tokens", async function () {
            const burnAmount = ethers.parseEther("100");
            const initialSupply = await simpleToken.totalSupply();
            const initialBalance = await simpleToken.balanceOf(owner.address);

            await simpleToken.burn(burnAmount);

            expect(await simpleToken.balanceOf(owner.address))
                .to.equal(initialBalance - burnAmount);
            expect(await simpleToken.totalSupply())
                .to.equal(initialSupply - burnAmount);
        });

        it("Should fail if trying to burn more than balance", async function () {
            await expect(
                simpleToken.connect(addr1).burn(ethers.parseEther("100"))
            ).to.be.reverted;
        });
    });
});
