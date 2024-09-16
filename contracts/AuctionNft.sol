// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract AuctionNft is ERC721, ERC721URIStorage, Ownable {
    constructor() ERC721("auctionNft", "AUC") Ownable(msg.sender) {}

    function mintNFT(
        address _recipient,
        string memory _tokenURI,
        uint40 _tokenId
    ) public onlyOwner {
        _safeMint(_recipient, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
