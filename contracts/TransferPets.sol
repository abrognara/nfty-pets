//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TransferPets is ERC1155, Ownable {
    uint256 tokenCounter;

    struct PuppyData {
        uint256 priceWei;
        uint256[] transferWithIds;
    }

    struct PuppyMarketItem {
        address payable seller;
        address payable owner;
        bool sold;
        uint256 price;
        uint256[] transferWithIds;
    }

    mapping(uint256 => PuppyData) puppyIdsToData;
    mapping(uint256 => PuppyMarketItem) tokenIdToMarketItem;

    constructor()
        public
        ERC1155(
            "https://bafybeibwchbcw5jciwaugtk2tot2azuk4sydsfqmz45er5vxudc2faapce.ipfs.dweb.link/{id}.json"
        )
    {
        tokenCounter = 1;
        uint256[] memory transferWithIds1 = new uint256[](1);
        transferWithIds1[0] = 2;
        uint256[] memory transferWithIds2 = new uint256[](1);
        transferWithIds1[0] = 1;
        mintToOwner(10000000, transferWithIds1); // goldendoodle boy
        mintToOwner(10000000, transferWithIds2); // goldendoodle girl
        mintToOwner(10000000, new uint256[](0)); // french bulldog boy
    }

    function mintToOwner(uint256 _priceWei, uint256[] memory _transferWithIds)
        public
        onlyOwner
        returns (uint256)
    {
        uint256 tokenId = tokenCounter++;
        _mint(msg.sender, tokenId, 1, "");
        puppyIdsToData[tokenId] = PuppyData({
            priceWei: _priceWei,
            transferWithIds: _transferWithIds
        });
        return tokenId;
    }

    function createPuppyListing(
        address _nftContract,
        uint256 _tokenId,
        uint256 _price,
        uint256[] memory _transferWithIds
    ) public {
        tokenIdToMarketItem[_tokenId] = PuppyMarketItem({
            seller: payable(msg.sender),
            owner: payable(0),
            price: _price,
            sold: false,
            transferWithIds: _transferWithIds
        });
    }

    function buyPuppy(uint256 _puppyId) public payable {
        require(balanceOf(owner(), _puppyId) > 0, "This puppy is not in stock");
        PuppyData memory puppyData = puppyIdsToData[_puppyId];
        require(msg.value == puppyData.priceWei, "Incorrect balance");
        // check brother and sister sold together
        safeTransferFrom(owner(), msg.sender, _puppyId, 1, "");
    }

    // mint batch to owner?

    // function buyPuppies(uint256[] calldata _ids, uint256[] calldata _amounts)
    //     public
    //     payable
    // {
    //     // * check buyer has enough eth to purchase (msg.value)
    //     uint256 totalPriceEth;
    //     for (uint256 i = 0; i < _ids.length; i++) {
    //         PuppyData memory puppyData = puppyIdsToData[_ids[i]];
    //         totalPriceEth += puppyData.priceEth;
    //     }
    //     require(msg.value >= totalPriceEth, "Not enough eth sent");
    //     // * check brother and sister are sold together
    //     // * transfer eth from buyer to contract (or directly to owner?)
    //     // * transfer the NFT to msg.sender
    //     safeBatchTransferFrom(owner, msg.sender, _ids, _amounts, "");
    // }
}
