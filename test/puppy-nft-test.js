const { expect } = require("chai");
const { ethers } = require("hardhat");

describe('PuppyNFT', () => {
    it('Should mint one token to the owner', async () => {
        const [owner] = await ethers.getSigners();

        const PuppyMarketplace = await ethers.getContractFactory('PuppyMarketplace');
        const puppyMarketplace = await PuppyMarketplace.deploy();
        await puppyMarketplace.deployed();
        const marketplaceAddress = puppyMarketplace.address;

        const PuppyNFT = await ethers.getContractFactory('PuppyNFT');
        const puppyNFT = await PuppyNFT.deploy(marketplaceAddress);
        await puppyNFT.deployed();

        await puppyNFT.mintToOwner();
        expect(await puppyNFT.balanceOf(owner.address, 1)).to.equal(1);

        await puppyNFT.batchMintToOwner(2);
        const balances = await puppyNFT.balanceOfBatch([owner.address, owner.address, owner.address], [2, 3, 4]);
        expect(balances[0]).to.equal(1);
        expect(balances[1]).to.equal(1);
        expect(balances[2]).to.equal(0);
    });
});