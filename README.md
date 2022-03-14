# NFTyPets Assignment

In this project I minted three ERC-1155 NFTs to represent puppies, and sold them to two different owners. I created PuppyNFT.sol to mint the assets and PuppyMarketplace.sol to handle transferring the asssets in exchange for eth. 

First I uploaded assets (image, metadata) to IPFS for each puppy. I followed OpenSea standards for the metadata format and uploaded each file as an id. This id would need to match the id generated in the contract when minting:
  Joey, goldendoodle boy, id = 1
  Lucy, goldendoodle girl, id = 2
  Trevor, french bulldog boy, id = 3

Next, the owner can mint three NFTs to represent each puppy. I decided to restrict minting abilities to only the owner of the pet store so they could control minting based on the supply of puppies. Selling the NFTs is handled by the marketplace contract, which will keep track of NFT listings and facilitate the exchange of eth for assets. I also restricted listing NFTs to only the owner so that they can control what puppies are listed based on their supply and availabiliy. Finally, any buyer can buy the NFTs from the contract.

Deployment Steps
  owner	0x1efe1b27ddb1ef694f2a6760cab8dcc3d2e74309
  Buyer 1	0x906ae3e33099aB4975B262d89EeE319bf9F1be46
  Buyer 2	0x1216E093Cd7018c82D2E8d8e58c3eBd7bD358a2A
  
	Deploy PuppyMarketplace.sol: https://ropsten.etherscan.io/tx/0x62e8ceea72330c6952c6103c15a33ce7043d2d7c471358f424b90e52a8d66040
	Deploy PuppyNFT.sol: https://ropsten.etherscan.io/tx/0x2d4abf6ba6a2a6f08730fbfa48993a5d80ad689cec0e26c22807a706f3bc6746
	Mint three NFT's to owner: https://ropsten.etherscan.io/tx/0x8c19c18d0af0782f20504355c9b7fc67fd403bf0abb1354489bfb50cac3b4028
	List three puppy NFT's: https://ropsten.etherscan.io/tx/0x773aaaa6d6c4272bdae212658efb99d0471a2952c8c4c2e6effff95ff7d0e1e8
	Buyer 1 buys Goldendoodle puppies (ids = 1, 2): https://ropsten.etherscan.io/tx/0x2b78c58260bb292ab45480877f984d107609a38049929032e28e32755a878ceb
	Buyer 2 buys French Bulldog puppy (id = 3): https://ropsten.etherscan.io/tx/0x3771cda6b09f7b030e4238efec6990dd7ce71d87616759f9b0e38176cfa9840c
  ![image](https://user-images.githubusercontent.com/23068170/158097445-6190e5d3-a200-4b5c-992e-a9461f06f51f.png)

Future Considerations
	1. I got an integer overflow error when calling batch list function:
    transact to PuppyMarketplace.createPuppyListingBatch errored: Error encoding arguments: Error: overflow (fault="overflow", operation="BigNumber.from", value=19901289603566310, code=NUMERIC_FAULT, version=bignumber/5.5.0)
  
  So I added price in gwei instead of wei, but when I called the buy function it was expecting an amount in wei. My takeaways here are to better understand how to represent denominations, and how to know what denomination someone will buy in. Is it always wei?
  
	2. Re-entrancy attack: make sure the contract is secure and resistant to attacks such as a re-entrancy attack.
	3. We can make the marketplace decentralized to allow anyone to list and buy/sell puppies
		a. We should create a listing cost
		b. The seller field in market item struct can be any seller
	4. The marketplace can handle listing NFTs from any type of NFT contract. Right now it only handles ERC-1155 contracts.
		a. We can also decouple the NFT contract from the marketplace contract by using an itemId counter as the key to keep track of market items, and add tokenId as a field in the market item struct to save the reference to its contract
	5. The seller can list an NFT for an amount in any currency (i.e. USD) and the marketpalce can handle converting to an amount in eth with the help of a price feed from an oracle such as Chainlink. This is necesary since the price of eth is always changing.
	6. The marketplace should have functions to get all sold puppies or in-stock puppies
