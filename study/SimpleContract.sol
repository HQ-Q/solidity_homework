// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleContract {
    address  public  owner;

    // 构造函数，设置合约拥有者
    constructor() {
        owner = msg.sender;
    }

    
    function deposit() public payable {}

    // 合约拥有者可以销毁合约
    function destroy() public {
        require(msg.sender == owner, "You are not the owner");
        selfdestruct(payable(owner));
        
    }
}