const { expect } = require("chai");
const { ethers } = require("hardhat");

describe('PuppyMarketplace', () => {
    it('Should mint', async () => {
        const PuppyMarketplace = await ethers.getContractFactory('PuppyMarketplace');
        const puppyMarketplace = await PuppyMarketplace.deploy();
        await puppyMarketplace.deployed();
        const marketplaceAddress = puppyMarketplace.address;

        const PuppyNFT = await ethers.getContractFactory('PuppyNFT');
        const puppyNFT = await PuppyNFT.deploy(marketplaceAddress);
        await puppyNFT.deployed();
        const nftAddress = puppyNFT.address;
    });
});