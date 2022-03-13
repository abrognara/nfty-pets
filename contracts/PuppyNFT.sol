//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PuppyNFT is ERC1155, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address marketplaceAddress;

    constructor(address _marketplaceAddress)
        public
        ERC1155(
            "https://bafybeibwchbcw5jciwaugtk2tot2azuk4sydsfqmz45er5vxudc2faapce.ipfs.dweb.link/{id}.json"
        )
    {
        marketplaceAddress = _marketplaceAddress;
    }

    function mintToOwner() public onlyOwner returns (uint256) {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _mint(msg.sender, tokenId, 1, "");
        setApprovalForAll(marketplaceAddress, true);
        return tokenId;
    }

    function batchMintToOwner(uint256 _nTokens) public onlyOwner returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](_nTokens);
        uint256[] memory amounts = new uint256[](_nTokens);
        for (uint256 i = 0; i < _nTokens; i++) {
            _tokenIds.increment();
            uint256 curId = _tokenIds.current();
            ids[i] = curId;
            amounts[i] = 1;
        }
        _mintBatch(msg.sender, ids, amounts, "");
        return ids;
    }
}
