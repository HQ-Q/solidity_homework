
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}


contract ERC20 is IERC20{
    function    balanceOf(address account) external view  returns (uint256){
        return  0;
    }
    
    function transfer(address to, uint256 amount) external returns (bool){
        return false;
    }
}