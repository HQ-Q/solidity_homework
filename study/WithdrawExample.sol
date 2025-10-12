// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract WithdrawExample {
    address public immutable owner;
    
    // 记录用户余额
    mapping(address => uint256) public userBalances;
    
    // 事件
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed recipient, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // 接收ETH
    receive() external payable {
        userBalances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    // 充值
    function deposit() external payable {
        userBalances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    // 用户提现自己的余额（推荐模式）
    function withdraw() external {
        uint256 amount = userBalances[msg.sender];
        require(amount > 0, "No balance to withdraw");
        
        // 先清零余额再转账，防止重入攻击
        userBalances[msg.sender] = 0;
        
        // 使用call进行转账并检查结果
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawn(msg.sender, amount);
    }

    // 管理员将合约全部余额提现到指定地址
    function adminWithdrawAll(address payable recipient) external {
        require(msg.sender == owner, "Not owner");
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        
        (bool success, ) = recipient.call{value: balance}("");
        require(success, "Transfer failed");
        
        emit EmergencyWithdraw(recipient, balance);
    }

    // 查看合约余额
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}