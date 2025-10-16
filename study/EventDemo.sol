// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract EventDemo{
    event Add(uint256 indexed a, uint256 indexed b, uint256 result); // 定义一个事件
    event Sub(uint256 indexed a, uint256 indexed b, uint256 result); // 定义一个事件


    function add(uint256 a, uint256 b) public  returns (uint256){
        emit Add(a, b, a + b);
        return a+b;
    }

    function sub(uint256 a, uint256 b) public  returns (uint256){
        emit Sub(a, b, a + b);
        return a+b;
    }
}