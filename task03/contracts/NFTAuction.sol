// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MyNFT} from "./MyNFT.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol"; // UUPS核心合约
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol"; // 升级权限控制
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol"; // ERC721 Receiver (upgradeable)
// NFT拍卖合约：继承 UUPSUpgradeable + OwnableUpgradeable
contract NFTAuction is 
    Initializable, 
    UUPSUpgradeable, // 核心：启用UUPS升级模式
    OwnableUpgradeable, // 核心：控制升级权限（仅所有者可升级）
    IERC721ReceiverUpgradeable 
{
    // 合约创建事件
    event AuctionCreated(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 startTime,
        uint256 endTime,
        uint256 startPrice
    );
    // 出价事件
    event BidPlaced(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 bidAmount
    );
    // 领取资金事件
    event FundsClaimed(
        uint256 indexed auctionId,
        address indexed seller,
        uint256 amount
    );
    // 领取NFT事件
    event NFTClaimed(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 tokenId
    );
    // 流拍后卖家领取NFT事件
    event NFTReclaimed(
        uint256 indexed auctionId,
        address indexed seller,
        uint256 tokenId
    );
    // 记录接收ETH的事件
    event ReceivedEth(address indexed sender, uint256 amount);

    // 结构体（无修改）
    struct Auction {
        address nftContract;
        uint256 nftTokenId;
        address seller;
        uint256 startTime;
        uint256 endTime;
        uint256 startPrice;
        uint256 highestBid;
        address highestBidder;
        bool hasBeenClaimed;
    }

    // 状态变量（无修改，仅确保通过initialize初始化）
    mapping(uint256 => Auction) public auctions;
    uint256 private nextAuctionId;

    /// @custom:oz-upgrades-unsafe-allow constructor
    // 核心：禁用构造函数初始化，改用initialize
    constructor() {
        _disableInitializers();
    }

    // 核心：初始化函数（需调用所有父类的init）
    function initialize() public initializer {
        // __Initializable_init(); // 初始化Initializable（可选，部分版本自动调用）
        __Ownable_init(); // 初始化OwnableUpgradeable（设置部署者为初始所有者）
        __UUPSUpgradeable_init(); // 初始化UUPSUpgradeable

        nextAuctionId = 0; 
    }

    // 创建拍卖
    function createAuction(
        address _nftContract,
        uint256 _nftTokenId,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _startPrice
    ) public returns (uint256) {
        require(_startPrice > 0, "Start price must be greater than zero");
        require(_endTime > _startTime, "End time must be greater than start time");
        MyNFT nft = MyNFT(_nftContract);
        require(nft.ownerOf(_nftTokenId) == msg.sender, "Your does not own the NFT");

        nft.safeTransferFrom(msg.sender, address(this), _nftTokenId);

        uint256 auctionId = nextAuctionId++;
        auctions[auctionId] = Auction({
            nftContract: _nftContract,
            nftTokenId: _nftTokenId,
            seller: msg.sender,
            startTime: _startTime,
            endTime: _endTime,
            startPrice: _startPrice,
            highestBid: 0,
            highestBidder: address(0),
            hasBeenClaimed: false
        });
        emit AuctionCreated(_nftContract, _nftTokenId, msg.sender, _startTime, _endTime, _startPrice);
        return auctionId;
    }

    // 买家出价
    function placeBid(uint256 _auctionId) public payable {
        Auction storage auction = auctions[_auctionId];
        uint256 currentTime = block.timestamp;
        require(currentTime >= auction.startTime, "Auction has not started yet");
        require(currentTime < auction.endTime, "Auction has already ended");
        require(msg.value >= auction.startPrice, "Bid must be at least the starting price");
        require(msg.value > auction.highestBid, "There already is a higher or equal bid");

        if (auction.highestBidder != address(0)) {
            (bool success, ) = auction.highestBidder.call{value: auction.highestBid}("");
            require(success, "Transfer failed.");
        }

        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
        emit BidPlaced(_auctionId, msg.sender, msg.value);
    }

    // 领取资金（无修改）
    function claimFunds(uint256 _auctionId) public {
        Auction storage auction = auctions[_auctionId];
        uint256 currentTime = block.timestamp;
        require(currentTime >= auction.endTime, "Auction has not ended yet");
        require(!auction.hasBeenClaimed, "Funds have already been claimed");
        require(msg.sender == auction.seller, "Only the seller can claim the funds");

        auction.hasBeenClaimed = true;
        (bool success, ) = auction.seller.call{value: auction.highestBid}("");
        require(success, "Transfer failed.");
        emit FundsClaimed(_auctionId, auction.seller, auction.highestBid);
    }

    // 买家领取NFT
    function claimNFT(uint256 _auctionId) public {
        Auction storage auction = auctions[_auctionId];
        uint256 currentTime = block.timestamp;
        require(currentTime >= auction.endTime, "Auction has not ended yet");
        require(msg.sender == auction.highestBidder, "Only the highest bidder can claim the NFT");

        MyNFT nft = MyNFT(auction.nftContract);
        nft.safeTransferFrom(address(this), auction.highestBidder, auction.nftTokenId);
        emit NFTClaimed(_auctionId, auction.highestBidder, auction.nftTokenId);
    }

    // 流拍后卖家领取NFT
    function reclaimNFT(uint256 _auctionId) public {
        Auction storage auction = auctions[_auctionId];
        uint256 currentTime = block.timestamp;
        require(currentTime >= auction.endTime, "Auction has not ended yet");
        require(auction.highestBidder == address(0), "Auction did not fail, cannot reclaim NFT");
        require(msg.sender == auction.seller, "Only the seller can reclaim the NFT");

        MyNFT nft = MyNFT(auction.nftContract);
        nft.safeTransferFrom(address(this), auction.seller, auction.nftTokenId);
        emit NFTReclaimed(_auctionId, auction.seller, auction.nftTokenId);
    }

    // 接收ETH的回退函数
    receive() external payable {
        emit ReceivedEth(msg.sender, msg.value); // 新增：触发事件，便于调试
    }

    // IERC721Receiver接口实现
    function onERC721Received(
        address ,
        address ,
        uint256 ,
        bytes calldata 
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // 核心：UUPS升级授权（仅所有者可执行升级）
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {
        // 空实现即可，仅通过onlyOwner修饰符控制权限
    }
}