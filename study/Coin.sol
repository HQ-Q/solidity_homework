// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
contract Coin{
    //筑币者
    address public minter;
    mapping (address=>uint256) public balances;
    //事件
    event Sent(address from,address to,uint256 amount);
    constructor(){
        minter = msg.sender;
    }

    //发币
    function mint(address receiver ,uint256 amout)public {
        //只有合约的所有者可以发币
        require(receiver==minter,"Only minter can mint");
        balances[receiver] += amout;
    }

    //转币
    function send(address receiver ,uint256 amout)public {
        require(amout<=balances[msg.sender]);
        balances[msg.sender] -= amout;
        balances[receiver] += amout;
        emit Sent(msg.sender,receiver,amout);
    }
}