// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {MyNFT} from "./MyNFT.sol";
import {NFTAuction} from "./NFTAuction.sol";
//NFT拍卖合约 v2
contract NFTAuctionV2 is NFTAuction{
    function newFunctionV2() public pure returns (string memory) {
        return "This is a new function in NFTAuctionV2";
    }
}
