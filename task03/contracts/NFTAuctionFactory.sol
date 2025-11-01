// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {NFTAuction} from "./NFTAuction.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

// 简单 owner 实现以避免依赖不同版本的 Ownable
contract NftAuctionFactory {
    address public owner;
    address[] public auctions;
    // implementation 合约（NFTAuction）的地址，owner 可更新以实现升级路线
    address public implementation;

    event AuctionDeployed(address auctionAddress);
    event ImplementationUpdated(
        address oldImplementation,
        address newImplementation
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    UpgradeableBeacon public beacon;

    constructor(address _implementation) {
        owner = msg.sender;
        implementation = _implementation;
        // 部署 beacon，让 factory 成为 beacon 的拥有者（factory.owner 可调用 upgrade）
        // 把 factory 合约设为 beacon 的 owner（便于 factory 的 onlyOwner 调用 beacon.upgradeTo）
        beacon = new UpgradeableBeacon(_implementation, address(this));
    }

    /// @notice 由 factory owner 触发升级 beacon 的 implementation
    function setImplementation(address _implementation) external onlyOwner {
        require(_implementation != address(0), "invalid implementation");
        // 通过 beacon.upgradeTo 更新实现地址（只有 beacon 的 owner 可以调用，factory 当前为 beacon 所有者）
        beacon.upgradeTo(_implementation);
        emit ImplementationUpdated(implementation, _implementation);
        implementation = _implementation;
    }

    // 部署并初始化 proxy，转移 proxy 所有权给调用者，返回 proxy 地址 创建拍卖实例
    function createAuction() public returns (address) {
        require(implementation != address(0), "implementation not set");
        // 在构造 proxy 时把初始化数据传入，避免初始化窗口
        bytes memory initData = abi.encodeWithSelector(
            NFTAuction.initialize.selector
        );
        BeaconProxy proxy = new BeaconProxy(address(beacon), initData);

        NFTAuction auction = NFTAuction(payable(address(proxy)));
        // 初始化后，factory 作为 beacon 的 deployer/owner 应该能调用 transferOwnership
        // 把 proxy 的 Ownable 权限转给调用者，方便用户管理自己的拍卖实例（注意：Beacon 控制实现的升级）
        auction.transferOwnership(msg.sender);
        auctions.push(address(proxy));
        emit AuctionDeployed(address(proxy));
        return address(proxy);
    }

    function getAuctions() public view returns (address[] memory) {
        return auctions;
    }
}
