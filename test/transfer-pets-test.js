const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TransferPets", () => {
  it("Should do something", async () => {
    const TransferPets = await ethers.getContractFactory("TransferPets");
    const transferPets = await TransferPets.deploy();
    await transferPets.deployed();
  });
});
