// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
contract MyERC20Token{

    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public decimals;
    mapping(address => uint256) public balanceOf;


    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value,"Insufficient Balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }

    function mint()public payable {
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;
    }

    fallback() external payable { 
        mint();
    }


}