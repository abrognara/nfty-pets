const hre = require("hardhat");

async function main() {
  const TransferPets = await hre.ethers.getContractFactory("Greeter");
  const transferPets = await TransferPets.deploy("Hello, Hardhat!");

  await transferPets.deployed();

  console.log("TransferPets deployed to:", transferPets.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });