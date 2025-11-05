const hre = require("hardhat");

async function main() {
  console.log("=================================");
  console.log("Voting Contract Example Usage");
  console.log("=================================\n");

  // Get signers
  const [owner, voter1, voter2, voter3] = await hre.ethers.getSigners();
  console.log("Owner:", owner.address);
  console.log("Voter1:", voter1.address);
  console.log("Voter2:", voter2.address);
  console.log("Voter3:", voter3.address, "\n");

  // Deploy contract
  console.log("Deploying Voting contract...");
  const Voting = await hre.ethers.getContractFactory("Voting");
  const voting = await Voting.deploy();
  await voting.waitForDeployment();
  const address = await voting.getAddress();
  console.log("✓ Voting deployed to:", address, "\n");

  // Register voters
  console.log("Registering voters...");
  await voting.connect(owner).registerVoter(voter1.address);
  console.log("✓ Voter1 registered");

  await voting.connect(owner).registerVoter(voter2.address);
  console.log("✓ Voter2 registered");

  await voting.connect(owner).registerVoter(voter3.address);
  console.log("✓ Voter3 registered\n");

  // Create proposal
  console.log("Creating proposal...");
  const proposalDescription = "Should we upgrade the smart contract to v2.0?";
  await voting.connect(voter1).createProposal(proposalDescription);
  console.log("✓ Proposal created:", proposalDescription, "\n");

  // Vote on proposal
  console.log("Voting on proposal...");
  await voting.connect(voter1).vote(0, true);
  console.log("✓ Voter1 voted: For");

  await voting.connect(voter2).vote(0, true);
  console.log("✓ Voter2 voted: For");

  await voting.connect(voter3).vote(0, false);
  console.log("✓ Voter3 voted: Against\n");

  // Get proposal results
  console.log("Getting proposal results...");
  const proposal = await voting.getProposal(0);
  console.log("Proposal ID:", proposal.id.toString());
  console.log("Description:", proposal.description);
  console.log("Votes For:", proposal.votesFor.toString());
  console.log("Votes Against:", proposal.votesAgainst.toString());
  console.log("Is Active:", proposal.isActive);
  console.log("Executed:", proposal.executed, "\n");

  console.log("=================================");
  console.log("Example completed successfully!");
  console.log("=================================");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
