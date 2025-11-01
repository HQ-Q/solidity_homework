// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {MyNFT} from "./MyNFT.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

//NFT拍卖合约
contract NFTAuction is Initializable, IERC721Receiver {

    

    //合约创建事件
    event AuctionCreated(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 startTime,
        uint256 endTime,
        uint256 startPrice
    );
    //出价事件
    event BidPlaced(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 bidAmount
    );

    //领取资金事件
    event FundsClaimed(
        uint256 indexed auctionId,
        address indexed seller,
        uint256 amount
    );

    //领取NFT事件
    event NFTClaimed(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 tokenId
    );

    //流拍后卖家领取NFT事件
    event NFTReclaimed(
        uint256 indexed auctionId,
        address indexed seller,
        uint256 tokenId
    );

     // 记录接收ETH的事件
    event ReceivedEth(address indexed sender, uint256 amount);

    //结构体
    struct Auction {
        address nftContract; // NFT合约地址
        uint256 nftTokenId; // NFT代币ID
        address seller; // 卖家
        uint256 startTime; // 开始时间
        uint256 endTime; // 结束时间
        uint256 startPrice; // 起始价格
        uint256 highestBid; // 最高出价（代币单位）
        address highestBidder; // 最高出价者
        bool hasBeenClaimed; // 资金是否已被领取
    }

    //拍卖集合
    mapping(uint256 => Auction) public auctions;
    //下一个拍卖id
    uint256 private nextAuctionId;
    
    function initialize() public initializer {
        nextAuctionId = 0;
    }


    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    //创建拍卖任何人都可以创建拍卖
    function createAuction(
        address _nftContract,
        uint256 _nftTokenId,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _startPrice
    ) public  returns (uint256) {
        //起拍价格不能为0
        require(_startPrice > 0, "Start price must be greater than zero");
        //结束时间必须大于开始时间
        require(
            _endTime > _startTime,
            "End time must be greater than start time"
        );
        MyNFT nft = MyNFT(_nftContract);
        //调用者必须拥有该NFT
        require(
            nft.ownerOf(_nftTokenId) == msg.sender,
            "Your does not own the NFT"
        );

        //将NFT转移到拍卖合约中
        nft.safeTransferFrom(msg.sender, address(this), _nftTokenId);

        uint256 auctionId = nextAuctionId++;
        auctions[auctionId] = Auction({
            nftContract: _nftContract,
            nftTokenId: _nftTokenId,
            seller: msg.sender,
            startTime: _startTime,
            endTime: _endTime,
            highestBid: 0,
            highestBidder: address(0),
            hasBeenClaimed: false,
            startPrice: _startPrice
        });
        emit AuctionCreated(
            _nftContract,
            _nftTokenId,
            msg.sender,
            _startTime,
            _endTime,
            _startPrice
        );
        return auctionId;
    }

    //买家出价
    function placeBid(uint256 _auctionId) public payable {
        Auction storage auction = auctions[_auctionId];
        uint256 currentTime = block.timestamp;
        require(
            currentTime >= auction.startTime,
            "Auction has not started yet"
        );
        require(currentTime < auction.endTime, "Auction has already ended");
        require(
            msg.value >= auction.startPrice,
            "Bid must be at least the starting price"
        );
        require(
            msg.value > auction.highestBid,
            "There already is a higher or equal bid"
        );
        //退还之前的最高出价者
        if (auction.highestBidder != address(0)) {
            (bool success, ) = auction.highestBidder.call{
                value: auction.highestBid
            }("");
            require(success, "Transfer failed.");
        }
        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
        emit BidPlaced(_auctionId, msg.sender, msg.value);
    }

    //领取资金(拍卖结束后)
    function claimFunds(uint256 _auctionId) public {
        Auction storage auction = auctions[_auctionId];
        uint256 currentTime = block.timestamp;
        require(currentTime >= auction.endTime, "Auction has not ended yet");
        require(!auction.hasBeenClaimed, "Funds have already been claimed");
        require(
            msg.sender == auction.seller,
            "Only the seller can claim the funds"
        );
        auction.hasBeenClaimed = true;
        //将资金转给卖家
        (bool success, ) = auction.seller.call{value: auction.highestBid}("");
        require(success, "Transfer failed.");
        emit FundsClaimed(_auctionId, auction.seller, auction.highestBid);
    }

    //买家领取NFT
    function claimNFT(uint256 _auctionId) public {
        Auction storage auction = auctions[_auctionId];
        uint256 currentTime = block.timestamp;
        require(currentTime >= auction.endTime, "Auction has not ended yet");
        require(
            msg.sender == auction.highestBidder,
            "Only the highest bidder can claim the NFT"
        );
        MyNFT nft = MyNFT(auction.nftContract);
        //将NFT转给最高出价者
        nft.safeTransferFrom(
            address(this),
            auction.highestBidder,
            auction.nftTokenId
        );
        emit NFTClaimed(_auctionId, auction.highestBidder, auction.nftTokenId);
    }

    //流拍后卖家领取NFT
    function reclaimNFT(uint256 _auctionId) public {
        Auction storage auction = auctions[_auctionId];
        uint256 currentTime = block.timestamp;
        require(currentTime >= auction.endTime, "Auction has not ended yet");
        require(
            auction.highestBidder == address(0),
            "Auction did not fail, cannot reclaim NFT"
        );
        require(
            msg.sender == auction.seller,
            "Only the seller can reclaim the NFT"
        );
        MyNFT nft = MyNFT(auction.nftContract);
        //将NFT转给卖家
        nft.safeTransferFrom(
            address(this),
            auction.seller,
            auction.nftTokenId
        );
        emit NFTReclaimed(_auctionId, auction.seller, auction.nftTokenId);
    }



    // 接收ETH的回退函数
    // 1. 处理退还之前出价者的ETH
    // 2. 作为合约接收ETH的后备函数
    receive() external payable {
        // 接收以太币的回退函数
        emit ReceivedEth(msg.sender, msg.value);
    }

   
}
