// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {NFTAuction} from "./NFTAuction.sol";
contract NftAuctionFactory{
    address[] public  auctions;

    event AuctionDeployed(address auctionAddress);

    function createAuction(
        address _nftContract,
        uint256 _nftTokenId,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _startPrice
    ) public {
        NFTAuction auction = new NFTAuction();
        auction.initialize();
        auction.createAuction(
            _nftContract,
            _nftTokenId,
            _startTime,
            _endTime,
            _startPrice
        );
        auctions.push(address(auction));
        emit AuctionDeployed(address(auction));
    }

    function getAuctions() public view returns (address[] memory) {
        return auctions;
    }
}