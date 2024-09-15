//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 *seller of the NFT deploys the contract with a starting price
 *auction last for 7 days
 *price of the NFT decreases over time
 *participants can buy the NFT can depositing ETH greater than the current price computed by the SC
 *aution ends as soon as a buyer buys it
 */
contract DutchAuction {
    error AuctionEnded();
    error AddressZero();

    using Math for uint256;
    using Math for uint40;

    IERC721 immutable NFT;
    address payable immutable SELLER;
    uint256 immutable NFT_ID;
    uint256 startingPrice;
    uint40 immutable END_DATE;
    uint40 immutable START_DATE;
    bool public auctionOpen;

    constructor(address _nftAddress, uint256 _startingPrice, uint256 _nftId) {
        if (_nftAddress == address(0)) revert AddressZero();
        require(_startingPrice != 0, "price cant be 0");

        END_DATE = uint40(block.timestamp + 7 days);
        START_DATE = uint40(block.timestamp);
        NFT = IERC721(_nftAddress);
        NFT_ID = _nftId;
        startingPrice = _startingPrice;
        SELLER = payable(msg.sender);
        transferNft(msg.sender, address(this));
        auctionOpen = true;
    }

    function buyNft(uint _amount) external payable {
        if (block.timestamp > END_DATE) revert AuctionEnded();
        if (!auctionOpen) revert AuctionEnded();
        if (msg.sender == address(0)) revert AddressZero();

        uint256 _currentPrice = getPrice();

        require(_amount > _currentPrice, "amount too low");

        SELLER.transfer(_amount);
        auctionOpen = false;
        transferNft(address(this), msg.sender);
    }

    //reduce the price by 1% every day
    function getPrice() private view returns (uint256) {
        if (block.timestamp > END_DATE) revert AuctionEnded();
        if (!auctionOpen) revert AuctionEnded();

        uint256 _price = startingPrice;

        uint40 _timeGone = END_DATE - uint40(block.timestamp);
        uint40 _daysGone = uint40(Math.ceilDiv(_timeGone, 1 days));

        uint256 _onePercentPrice = (_price * 1) / 100;
        uint256 _priceGone = _daysGone - _onePercentPrice;

        return _price - _priceGone;
    }

    function transferNft(address _from, address _to) internal {
        NFT.safeTransferFrom(_from, _to, NFT_ID);
    }
}
