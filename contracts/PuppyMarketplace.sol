//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract PuppyMarketplace is Ownable {
    struct PuppyMarketItem {
        address payable seller;
        address payable owner;
        bool sold;
        uint256 price;
        uint256[] transferWithIds;
    }

    mapping(uint256 => PuppyMarketItem) tokenIdToMarketItem;

    function createPuppyListing(
        uint256 _tokenId,
        uint256 _price,
        uint256[] memory _transferWithIds,
        address _nftContractAddress
    ) public onlyOwner {
        tokenIdToMarketItem[_tokenId] = PuppyMarketItem({
            seller: payable(msg.sender), // or owner()
            owner: payable(0),
            sold: false,
            price: _price,
            transferWithIds: _transferWithIds
        });
        ERC1155(_nftContractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            1,
            ""
        );
    }

    function sellPuppy(uint256 _tokenId, address _nftContractAddress)
        public
        payable
    {
        uint256 price = tokenIdToMarketItem[_tokenId].price;
        require(
            msg.value == price,
            "Amount sent does not match the listing price. Please resend the correct amount."
        );

        tokenIdToMarketItem[_tokenId].seller.transfer(msg.value);
        ERC1155(_nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId,
            1,
            ""
        );
        tokenIdToMarketItem[_tokenId].owner = payable(msg.sender);
        tokenIdToMarketItem[_tokenId].sold = true;
    }
}
