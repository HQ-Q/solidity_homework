const fs = require("fs")
const path = require("path")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { save } = deployments;
    const { deployer } = await getNamedAccounts();
    console.log("030303----部署用户地址：", deployer)

    // 读取 .cache/proxyNftAuction.json文件
    const storePath = path.resolve(__dirname, "./.cache/proxyNftAuction.json");
    const storeData = fs.readFileSync(storePath, "utf-8");
    const { proxyAddress, implementationAddress, abi } = JSON.parse(storeData);
    console.log("030303----当前代理合约地址:", proxyAddress);
    console.log("030303----当前实现合约地址:", implementationAddress);

    const NFTAuctionV2 = await ethers.getContractFactory("NFTAuctionV2");

    // 执行升级
    console.log("030303----开始升级Upgrading NFTAuction to V2...");
    const nftAuctionProxyV2 = await upgrades.upgradeProxy(proxyAddress, NFTAuctionV2);
    await nftAuctionProxyV2.waitForDeployment();
    const proxyAddressV2 = await nftAuctionProxyV2.getAddress()
    console.log(`030303----升级后的代理合约地址: ${proxyAddressV2}`);
    //升级后实现合约地址
    const implementationAddressV2 = await upgrades.erc1967.getImplementationAddress(proxyAddressV2);
    console.log(`030303----升级后的实现合约地址: ${implementationAddressV2}`);

    await save(
        "NftAuctionProxy",
        {
            abi,
            address: proxyAddressV2,
        }
    );
}

module.exports.tags = ["upgradeNftAuction", "all"];
