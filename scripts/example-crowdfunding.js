const hre = require("hardhat");

async function main() {
  console.log("=================================");
  console.log("Crowdfunding Contract Example Usage");
  console.log("=================================\n");

  // Get signers
  const [owner, creator, backer1, backer2, backer3] = await hre.ethers.getSigners();
  console.log("Owner:", owner.address);
  console.log("Creator:", creator.address);
  console.log("Backer1:", backer1.address);
  console.log("Backer2:", backer2.address);
  console.log("Backer3:", backer3.address, "\n");

  // Deploy contract
  console.log("Deploying Crowdfunding contract...");
  const Crowdfunding = await hre.ethers.getContractFactory("Crowdfunding");
  const crowdfunding = await Crowdfunding.deploy();
  await crowdfunding.waitForDeployment();
  const address = await crowdfunding.getAddress();
  console.log("✓ Crowdfunding deployed to:", address, "\n");

  // Create project
  console.log("Creating project...");
  const goalAmount = hre.ethers.parseEther("10"); // 10 ETH goal
  await crowdfunding.connect(creator).createProject(
    "Build a Decentralized App",
    "We are building an amazing dApp that will revolutionize the blockchain space",
    goalAmount,
    30 // 30 days
  );
  console.log("✓ Project created");
  console.log("  Goal:", hre.ethers.formatEther(goalAmount), "ETH");
  console.log("  Duration: 30 days\n");

  // Get project info
  const project = await crowdfunding.getProject(0);
  console.log("Project Details:");
  console.log("  ID:", project.id.toString());
  console.log("  Title:", project.title);
  console.log("  Description:", project.description);
  console.log("  Goal:", hre.ethers.formatEther(project.goalAmount), "ETH");
  console.log("  Raised:", hre.ethers.formatEther(project.raisedAmount), "ETH");
  console.log("  Is Active:", project.isActive, "\n");

  // Backers contribute
  console.log("Backers contributing...");
  await crowdfunding.connect(backer1).contribute(0, { value: hre.ethers.parseEther("3") });
  console.log("✓ Backer1 contributed: 3 ETH");

  await crowdfunding.connect(backer2).contribute(0, { value: hre.ethers.parseEther("4") });
  console.log("✓ Backer2 contributed: 4 ETH");

  await crowdfunding.connect(backer3).contribute(0, { value: hre.ethers.parseEther("5") });
  console.log("✓ Backer3 contributed: 5 ETH\n");

  // Get updated project info
  const updatedProject = await crowdfunding.getProject(0);
  console.log("Updated Project Info:");
  console.log("  Raised:", hre.ethers.formatEther(updatedProject.raisedAmount), "ETH");
  console.log("  Percentage Funded:", updatedProject.percentageFunded.toString() + "%");
  console.log("  Goal Reached:", updatedProject.completed);
  console.log("  Funds Withdrawn:", updatedProject.fundsWithdrawn, "\n");

  // Get individual contributions
  const contrib1 = await crowdfunding.getContribution(0, backer1.address);
  const contrib2 = await crowdfunding.getContribution(0, backer2.address);
  const contrib3 = await crowdfunding.getContribution(0, backer3.address);

  console.log("Individual Contributions:");
  console.log("  Backer1:", hre.ethers.formatEther(contrib1), "ETH");
  console.log("  Backer2:", hre.ethers.formatEther(contrib2), "ETH");
  console.log("  Backer3:", hre.ethers.formatEther(contrib3), "ETH\n");

  console.log("=================================");
  console.log("Example completed successfully!");
  console.log("Note: Goal reached! Creator can withdraw funds.");
  console.log("=================================");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
