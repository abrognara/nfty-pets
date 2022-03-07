//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract TransferPets is ERC1155 {
    address owner;

    constructor() public ERC1155("<ipfs uri here>") {
        owner = msg.sender;
        // _mint(msg.sender, puppyId, 1, "");
        // mint all in constructor or make a minting function for new puppies?
    }

    function buyPuppies(uint256[] calldata _ids, uint256[] calldata _amounts)
        public
    {
        safeBatchTransferFrom(owner, msg.sender, _ids, _amounts, "");
    }
}
