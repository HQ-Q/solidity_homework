// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
interface ProxyInterface {
    function inc()external ;
    function dec()external ;
}

contract Proxy{
    address public implementation;
    uint256 public x;

    function setImplementation(address _implementation)external{
        implementation=_implementation;
    }

   
    //当proxy的客户端以某种方式把proxy当做具体业务功能来使用就会触发fallback (proxy不存在的函数都会转发到此)
    fallback() external {
       (bool success, ) = implementation.delegatecall(msg.data);
       if (!success) {
            revert("delegate call failed");
       }
    }

}

//v1版本
contract V1{
    address public implementation;
    uint256 public x;
    function inc()external{
        x+=1;
    }
}

//v2版本 合约升级
contract V2{
    address public implementation;
    uint256 public x;
    function inc()external{
        x+=2;
    }

    function dec()external {
        x-=1;
    }
}