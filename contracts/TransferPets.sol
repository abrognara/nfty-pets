//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TransferPets is ERC1155, Ownable {
    uint256 tokenCounter;

    struct PuppyData {
        uint256 priceEth;
        uint256[] transferWithIds;
    }

    mapping(uint256 => PuppyData) puppyIdsToData;

    constructor()
        public
        ERC1155(
            "https://bafybeibwchbcw5jciwaugtk2tot2azuk4sydsfqmz45er5vxudc2faapce.ipfs.dweb.link/{id}.json"
        )
    {
        // _mint(msg.sender, 1, 1, ""); // goldendoodle male
        // _mint(msg.sender, 2, 1, ""); // goldendoodle female
        // _mint(msg.sender, 3, 1, ""); // french bulldog male
        // tokenCounter = 3;

        uint256[] memory ids = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);
        tokenCounter = 1;
        for (uint256 i = 0; i < 3; i++) {
            ids[i] = tokenCounter++;
            amounts[i] = 1;
        }
        _mintBatch(msg.sender, ids, amounts, "");
    }

    function mintToOwner() public onlyOwner returns (uint256) {
        tokenCounter++;
        _mint(msg.sender, tokenCounter, 1, "");
        return tokenCounter;
    }

    // mint batch to owner?

    function buyPuppies(uint256[] calldata _ids, uint256[] calldata _amounts)
        public
        payable
    {
        // * check buyer has enough eth to purchase (msg.value)
        uint256 totalPriceEth;
        for (uint256 i = 0; i < _ids.length; i++) {
            PuppyData memory puppyData = puppyIdsToData[_ids[i]];
            totalPriceEth += puppyData.priceEth;
        }
        require(msg.value >= totalPriceEth, "Not enough eth sent");
        // * check brother and sister are sold together
        // * transfer eth from buyer to contract (or directly to owner?)
        // * transfer the NFT to msg.sender
        safeBatchTransferFrom(owner, msg.sender, _ids, _amounts, "");
    }
}
