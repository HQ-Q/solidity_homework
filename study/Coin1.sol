// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
contract Coin1{
    mapping (address=>uint256) public balances;
   
   //合约发布时币的总量就是固定的
    constructor(uint256 totalCoin){
        balances[msg.sender] = totalCoin;
    }


   //send coin
   function send(address receiver, uint256 amount)public returns (bool){
        require(balances[msg.sender]>=amount, "insufficient balance");
        //校验加法后不会溢出
        require(balances[receiver]+amount>=balances[receiver], "overflow");
        balances[msg.sender]-=amount;
        balances[receiver]+=amount;
        return true;
    }   
}