// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Simple{

    uint myData;

    function setData(uint newData) public {

        myData = newData;
    
    }

    function getData() public view returns ( uint ) {
        return myData;
    }
}