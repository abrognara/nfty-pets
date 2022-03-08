//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract TransferPets is ERC1155 {
    address owner;

    struct PuppyData {
        uint256 priceEth;
        uint256[] transferWithIds;
    }

    mapping(uint256 => PuppyData) puppyIdsToData;

    constructor() public ERC1155("<ipfs uri here>") {
        owner = msg.sender;
        // _mint(msg.sender, puppyId, 1, "");
        // mint all in constructor or make a minting function for new puppies?
    }

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
