const { ethers, upgrades } = require("hardhat");
const fs = require("fs");
const path = require("path");
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { save } = deployments;
    const { deployer } = await getNamedAccounts();
    // 获取合约工厂
    const NFTAuction = await ethers.getContractFactory("NFTAuction");
    console.log("020202---Deploying NFTAuction...");
    // 通过代理合约部署
    const nftAuctionProxy = await upgrades.deployProxy(NFTAuction, [], {
        initializer: 'initialize',
    });

    await nftAuctionProxy.waitForDeployment();
    const proxyAddress = await nftAuctionProxy.getAddress();
    console.log(`020202---代理合约地址: ${proxyAddress}`);

    // 获取实现合约地址
    const implementationAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
    console.log(`020202---实现合约地址: ${implementationAddress}`);

    // 将地址写入前端文件
    const storePath = path.resolve(__dirname, "./.cache/proxyNftAuction.json");

    fs.writeFileSync(
        storePath,
        JSON.stringify(
            {
                proxyAddress,
                implementationAddress,
                abi: NFTAuction.interface.format("json"),
            })
    );
    await save(
        "NftAuctionProxy",
        {
            abi: NFTAuction.interface.format("json"),
            address: proxyAddress,
        }
    );


}

module.exports.tags = ["depolyNftAuction", "all"];