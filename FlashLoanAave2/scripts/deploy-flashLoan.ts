const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const FlashLoan = await hre.ethers.getContractFactory("FlashLoan");
    console.log("Deploying FlashLoan contract...");
    const flashLoan = await FlashLoan.deploy(
        "0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A"
    );

    await flashLoan.deployed();
    console.log("FlashLoan deployed to:", flashLoan.address);
}

main().catch((error) => {
    console.error("Error deploying contract:", error);
    process.exitCode = 1;
});
