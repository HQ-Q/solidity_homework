// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

//银行接口
interface IBank {
    
    function deposit()external payable ;

    function withdraw(uint256 amount)external ;

    function getBalance(address account)external view returns (uint256);
}

//实现银行接口
contract Bank is IBank{
    mapping ( address => uint256) private balances;

    function deposit()external payable override {
        require(msg.value > 0, "deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount)external{
        require(balances[msg.sender]>0,"Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function getBalance(address account)external view returns (uint256){
        return balances[account];
    }
}

// 使用银行接口的合约

contract UseBank {
    IBank bank;
    constructor(address bankAddress) {
        bank = IBank(bankAddress);
    }

    function deposit()external payable {
        bank.deposit{value:msg.value}();
    }

    function withdraw(uint256 amount)external{
        bank.withdraw(amount);
    }

    function getBalance(address account)external view returns (uint256){
        return bank.getBalance(account);
    }
}