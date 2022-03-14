const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe('PuppyMarketplace', () => {
    before(async () => {
        PuppyMarketplace = await ethers.getContractFactory('PuppyMarketplace');
        puppyMarketplace = await PuppyMarketplace.deploy();
        await puppyMarketplace.deployed();
        marketplaceAddress = puppyMarketplace.address;

        PuppyNFT = await ethers.getContractFactory('PuppyNFT');
        puppyNFT = await PuppyNFT.deploy(marketplaceAddress);
        await puppyNFT.deployed();
        nftAddress = puppyNFT.address;
        // mint three NFTs for tests
        await puppyNFT.batchMintToOwner(4);
        [owner, buyerA, buyerB] = await ethers.getSigners();
    });

    it('Should create a single listing or batch listing', async () => {
        await puppyMarketplace.createPuppyListing(1, 10, [2], nftAddress);
        await puppyMarketplace.createPuppyListingBatch([2,3], [8,25], [[1],[]], nftAddress);

        const listings = await puppyMarketplace.getAllPuppyListings();
        expect(listings.length).to.equal(3);
        expect(listings[0].seller).to.equal(owner.address);
    });

    it('Should not sell a puppy that must be sold with 1 or more other puppies', async () => {
        await expect(puppyMarketplace.connect(buyerA).sellPuppy(1, nftAddress, { value: 10 })).to.be.reverted;
    });

    it('Should sell a single puppy or many puppies in a batch transaction', async () => {
        await puppyMarketplace.connect(buyerA).sellPuppy(3, nftAddress, { value: 25 });
        let listings = await puppyMarketplace.getAllPuppyListings();
        expect(listings[2].sold).to.be.true;
        expect(listings[2].owner).to.equal(buyerA.address);

        await puppyMarketplace.connect(buyerB).sellPuppiesBatch([1,2], nftAddress, { value: 18 });
        listings = await puppyMarketplace.getAllPuppyListings();
        expect(listings[0].sold).to.be.true;
        expect(listings[1].sold).to.be.true;
        expect(listings[0].owner).to.equal(buyerB.address);
        expect(listings[1].owner).to.equal(buyerB.address);
    });

    it('Should allow the owner to modify puppies sold together and price of listings', async () => {
        await puppyMarketplace.createPuppyListing(4, 5, [], nftAddress);
        const listings = await puppyMarketplace.getAllPuppyListings();
        expect(listings.length).to.equal(4);

        await puppyMarketplace.setPuppyIdsSoldTogether(4, [1,2,3]);
        await puppyMarketplace.setPrice(4, 30);

        const puppyMarketItem = await puppyMarketplace.getPuppyMarketItem(4);
        const idsSoldTogether = await puppyMarketplace.getPuppyIdsSoldTogether(4);
        expect(idsSoldTogether.length).to.equal(3);
        expect(puppyMarketItem.price).to.equal(30);
    });
});