const { ethers, deployments, upgrades } = require("hardhat");

const { expect } = require("chai");
describe("Upgrade Test", function () {
    it("full upgrade flow", async function () {
        const [signer, buyer] = await ethers.getSigners()
        //部署NFT合约
        const MyNFT = await ethers.getContractFactory("MyNFT");
        const nft = await MyNFT.deploy();
        await nft.waitForDeployment();
        const nftAddress = await nft.getAddress();
        console.log("test01----nftAddress::", nftAddress);

        // mint 10个 NFT
        for (let i = 0; i < 10; i++) {
            await nft.safeMint(signer.address, "https://example.com/nft/" + i);
        }
        //调用标签depolyNftAuction脚本部署拍卖合约
        await deployments.fixture(["depolyNftAuction"]);
        const nftAuctionProxy = await deployments.get("NftAuctionProxy");
        console.log("test01----代理合约地址----::", nftAuctionProxy.address);
        const nftAuction = await ethers.getContractAt(
            "NFTAuction",
            nftAuctionProxy.address
        );
        // 先授权NFT给拍卖合约
        console.log("test01----正在授权NFT给拍卖合约...");
        await nft.approve(nftAuctionProxy.address, 0);
        console.log("test01----NFT授权完成");

        console.log("test01----创建拍卖...");
        const tx = await nftAuction.createAuction(
            nftAddress,
            0,
            1761914125,//开始时间
            1762000525,//结束时间
            ethers.parseEther("1"), //最低出价 1 ETH
        );
        // await tx.wait();
        // console.log("拍卖已创建，交易哈希:", tx.hash);
        const auction = await nftAuction.auctions(0);
        console.log("test01----创建拍卖成功:", auction);

        const implAddress1 = await upgrades.erc1967.getImplementationAddress(
            nftAuctionProxy.address
        );

        //调用标签upgradeNftAuction脚本升级拍卖合约
        await deployments.fixture(["upgradeNftAuction"]);
        const implAddress2 = await upgrades.erc1967.getImplementationAddress(
            nftAuctionProxy.address
        );

        //4.验证拍卖数据未丢失
        const auction2 = await nftAuction.auctions(0);
        console.log("test01----升级后读取拍卖成功:", auction2);
        console.log("test01----实现合约1地址:", implAddress1);
        console.log("test01----实现合约2地址:", implAddress2);

        const nftAuctionV2 = await ethers.getContractAt(
            "NFTAuctionV2",
            nftAuctionProxy.address
        );
       const result = await nftAuctionV2.newFunctionV2();
       console.log("test01----调用升级后合约的新函数结果：", result);
       expect(auction2.startTime).to.equal(auction.startTime);
    });
});