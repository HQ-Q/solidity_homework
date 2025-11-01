// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Logic {
    address public logicAddress; // 没用上，但是这里占位是为了防止存储冲突
    uint256 public count;

    function incrementCounter() public {
        count += 1;
    }

    function getCount() public view returns (uint256) {
        return count;
    }
}

contract Proxy {
    address public logicAddress;
    uint256 public count;

    constructor(address _logic) {
        logicAddress = _logic;
    }

    // 确保只有可信的地址可以更新逻辑合约地址
    function upgradeLogic(address _newLogic) public {
        logicAddress = _newLogic;
    }

    fallback() external payable {
        _fallback(logicAddress);
    }

    receive() external payable {
        _fallback(logicAddress);
    }

    function _fallback(address logic) internal {
        // 通过 delegatecall 调用逻辑合约的函数，并返回数据
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), logic, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
