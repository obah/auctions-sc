//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract DutchAuction is IERC721Receiver {
    error AuctionEnded();
    error AddressZero();

    using Math for uint256;
    using Math for uint40;

    IERC721 public immutable NFT;
    address payable public immutable SELLER;
    uint256 immutable NFT_ID;
    uint256 startingPrice;
    uint256 discountRate;
    uint40 public endDate;
    uint40 public startDate;
    bool public auctionOpen;

    constructor(address _nftAddress, uint256 _nftId) {
        if (_nftAddress == address(0)) revert AddressZero();

        SELLER = payable(msg.sender);
        NFT = IERC721(_nftAddress);
        NFT_ID = _nftId;
    }

    function startAuction(uint256 _startingPrice, uint _discountRate) external {
        //todo add only owner requirement
        if (msg.sender == address(0)) revert AddressZero();
        require(msg.sender == SELLER, "unathorized");
        require(_startingPrice != 0, "price cant be 0");

        startDate = uint40(block.timestamp);
        endDate = uint40(block.timestamp + 7 days);
        startingPrice = _startingPrice;

        transferNft(msg.sender, address(this));

        discountRate = _discountRate;

        auctionOpen = true;
    }

    function buyNft() external payable {
        if (block.timestamp > endDate) revert AuctionEnded();
        if (!auctionOpen) revert AuctionEnded();
        if (msg.sender == address(0)) revert AddressZero();

        uint256 _currentPrice = getPrice();

        require(msg.value > _currentPrice, "amount too low");

        (bool sent, ) = SELLER.call{value: msg.value}("");
        require(sent, "failed to send ETH");

        auctionOpen = false;
        transferNft(address(this), msg.sender);
    }

    //reduce the price by 1% every day
    function getPrice() private view returns (uint256) {
        if (block.timestamp > endDate) revert AuctionEnded();
        if (!auctionOpen) revert AuctionEnded();

        uint256 _price = startingPrice;

        uint40 _timeElapsed = endDate - uint40(block.timestamp);
        uint256 _discount = discountRate * _timeElapsed;

        return _price - _discount;
    }

    function transferNft(address _from, address _to) internal {
        NFT.safeTransferFrom(_from, _to, NFT_ID);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
