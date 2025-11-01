// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract B{

    uint256 public x;
    address public sender;
    uint256 public value;
    bytes public data;

    function setVars(uint256 _num)external payable {
        x = _num;
        sender = msg.sender;
        value = msg.value;
        data = msg.data;
    }
}


contract A{
    uint256 public x;
    address public sender;
    uint256 public value;
    bytes public data;

    function setVars(address _contractAddress,uint256 _num)public  payable returns (bool){
      (bool success,)=  _contractAddress.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
       return success;
    }

    function callSetVars(address _contractAddress,uint256 _num)public  payable returns (bool){
        (bool success,)=  _contractAddress.call{value:msg.value}(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
       return success;
    }


}