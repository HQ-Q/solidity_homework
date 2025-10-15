// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/utils/Address.sol";
contract ModiferDemo{
    address private owner;    

    // 定义modifier
    modifier onlyOwner {
        require(msg.sender == owner); // 检查调用者是否为owner地址
        _; // 如果是的话，继续运行函数主体；否则报错并revert交易
    }

    constructor(){
        owner = msg.sender;
    }

    function getOwner() public view returns (address){
        return owner;
    }

    function changeOwner(address newOwner)public onlyOwner{
        owner = newOwner;
    }


    function isContract(address addr)public view returns(bool){
        return Address.isContract(addr);
    }


}