// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
//0xDA0bab807633f07f013f94DD0E6A4F96F8742B53
contract C {
    uint public num;
    address public sender;

    function setVars(uint256 _num) public payable {
        num = _num;
        sender = msg.sender;
    }
}
contract B {
    uint public num;
    address public sender;

    event callLog(address addr,bool success,bytes data);
    event delegatecallLog(address addr,bool success,bytes data);
    function callSetVars(address addr, uint256 _num) external payable {
        (bool success, bytes memory data) = addr.call(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
        emit callLog(addr,success,data);
    }

    function delegatecallSetVars(address addr, uint _num) external payable {
        (bool success, bytes memory data) = addr.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
        emit delegatecallLog(addr,success,data);
    }
}
