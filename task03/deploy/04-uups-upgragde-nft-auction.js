const { ethers, upgrades } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { save, get } = deployments;
    const { deployer } = await getNamedAccounts();

    console.log("040404----Upgrading NFTAuction via upgradeProxy...");

    // 获取已存在的代理地址（由 deploy/02-deploy-nft-auction.js 保存为 NftAuctionProxy）
    const nftAuctionDeployment = await deployments.get("NftAuctionProxy");
    const proxyAddress = nftAuctionDeployment.address;
    console.log("040404----existing proxy address:", proxyAddress);

    // 获取 V2 合约工厂并对已有 proxy 执行升级
    const NFTAuctionV2 = await ethers.getContractFactory("NFTAuctionV2");
    console.log("040404----Upgrading to NFTAuctionV2...");
    const nftAuctionProxyV2 = await upgrades.upgradeProxy(proxyAddress, NFTAuctionV2);

    // 等待部署（兼容 ethers v5/v6 返回对象）
    try {
        if (typeof nftAuctionProxyV2.waitForDeployment === "function") {
            await nftAuctionProxyV2.waitForDeployment();
        } else if (typeof nftAuctionProxyV2.deployed === "function") {
            await nftAuctionProxyV2.deployed();
        }
    } catch (e) {
        console.warn("040404----warning waiting for upgraded proxy deployment:", e.message || e);
    }

    const implementationAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
    console.log(`040404----upgraded implementation address: ${implementationAddress}`);

    // 将升级后的 proxy 信息保存到 deployments（覆盖原记录）
    await save(
        "NftAuctionProxy",
        {
            abi: NFTAuctionV2.interface.format("json"),
            address: proxyAddress,
        }
    );
};

module.exports.tags = ["uupsUpgradeNftAuction", "all"];
// Ensure the initial deployment runs before this upgrade script when using fixtures
module.exports.dependencies = ["depolyNftAuction"];