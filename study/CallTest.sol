// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter { 
    uint public counter;
    address public sender;

    function count() public {
        counter += 1;
        sender = msg.sender;
    }
}

contract CallTest { 
    // uint public counter;
    // address public sender;

    event CallLog(address caller, bool success,bytes data);


    function lowCallCount(address addr) public {
    //  (Counter(c)).count();
        bytes memory methodData =abi.encodeWithSignature("count()");
        (bool success, bytes memory data) =  addr.call(methodData);
        if (success) {
            emit CallLog(addr, success, data);
        }
    }

    // 只是调用代码，合约环境还是当前合约。
    function lowDelegatecallCount(address addr) public {
        bytes memory methodData = abi.encodeWithSignature("count()");
        (bool success, bytes memory data) = addr.delegatecall(methodData);
         if (success) {
            emit CallLog(addr, success, data);
        }
    }

}