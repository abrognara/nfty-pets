//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PuppyMarketplace is Ownable, ERC1155Holder {
    using Counters for Counters.Counter;
    Counters.Counter private _itemsListed;
    Counters.Counter private _itemsSold;

    struct PuppyMarketItem {
        address payable seller;
        address payable owner;
        bool sold;
        uint256 price;
    }

    mapping(uint256 => PuppyMarketItem) tokenIdToMarketItem;

    mapping(uint256 => uint256[]) transferWithIds;

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
            price: _price
        });

        // load transferWithIds with ids
        transferWithIds[_tokenId] = _transferWithIds;

        ERC1155(_nftContractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            1,
            ""
        );
        _itemsListed.increment();
    }

    function createPuppyListingBatch(uint256[] memory _tokenIds, uint256[] memory _prices, uint256[][] memory _transferWithIds, address _nftContractAddress) public onlyOwner {
        uint256[] memory amounts = new uint256[](_tokenIds.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            tokenIdToMarketItem[_tokenIds[i]] = PuppyMarketItem({
                seller: payable(msg.sender), // or owner()
                owner: payable(0),
                sold: false,
                price: _prices[i]
            });
            transferWithIds[_tokenIds[i]] = _transferWithIds[i];
            amounts[i] = 1;
            _itemsListed.increment();
        }
        ERC1155(_nftContractAddress).safeBatchTransferFrom(msg.sender, address(this), _tokenIds, amounts, "");
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

        require(transferWithIds[_tokenId].length == 0, "This puppy must be purchased with 1 or more other puppies.");

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
        _itemsSold.increment();
    }

    function sellPuppiesBatch(uint256[] memory _tokenIds, address _nftContractAddress) public payable {
        uint256[] memory amounts = new uint256[](_tokenIds.length);
        uint256 totalPrice;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            totalPrice += tokenIdToMarketItem[_tokenIds[i]].price;
            amounts[i] = 1;
        }
        require(
            msg.value == totalPrice,
            "Amount sent does not match the total price of all listings. Please resend the correct amount."
        );
        require(_checkTokensTransferredTogether(_tokenIds), "One or more puppies must be purchased with other puppies.");

        ERC1155(_nftContractAddress).safeBatchTransferFrom(address(this), msg.sender, _tokenIds, amounts, "");

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            // to handle different sellers, transfer tokens to each seller (future consideration)
            tokenIdToMarketItem[_tokenIds[i]].seller.transfer(tokenIdToMarketItem[_tokenIds[i]].price);
            tokenIdToMarketItem[_tokenIds[i]].owner = payable(msg.sender);
            tokenIdToMarketItem[_tokenIds[i]].sold = true;
            _itemsSold.increment();
        }
    }

    function getPuppyIdsSoldTogether(uint256 _tokenId) public view returns (uint256[] memory) {
        return transferWithIds[_tokenId];
    }

    function setPuppyIdsSoldTogether(uint256 _tokenId, uint256[] memory _transferWithIds) public {
        require(_tokenId <= _itemsListed.current(), "Cannot modify a token that doesn't yet exist");
        transferWithIds[_tokenId] = _transferWithIds;
    }

    function _checkTokensTransferredTogether(uint256[] memory _tokenIds) private view returns (bool) {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            // if tokenId has no transfer req's, skip
            if (transferWithIds[_tokenIds[i]].length == 0) continue;
            // get transfer req's (ids) and make sure they exist in _tokenId's
            uint256[] memory ids = transferWithIds[_tokenIds[i]];
            for (uint256 j = 0; j < ids.length; j++) {
                if (!_arrayContains(ids[j], _tokenIds)) {
                    return false;
                }
            }
        }
        return true;
    }

    function _arrayContains(uint256 value, uint256[] memory array) private pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) return true;
        }
        return false;
    }

}
