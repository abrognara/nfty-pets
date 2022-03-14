const hre = require("hardhat");

async function main() {
  const PuppyMarketplace = await hre.ethers.getContractFactory('PuppyMarketplace');
  const puppyMarketplace = await PuppyMarketplace.deploy();
  await puppyMarketplace.deployed();
  console.log(`PuppyMarketplace deployed to ${puppyMarketplace.address}`);

  const PuppyNFT = await hre.ethers.getContractFactory('PuppyNFT');
  const puppyNFT = await PuppyNFT.deploy(puppyMarketplace.address);
  await puppyNFT.deployed();
  console.log(`PuppyNFT deployed to ${puppyNFT.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });