// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
contract OtherContract {
    uint256 private _x = 0; // 状态变量_x
    // 收到eth的事件，记录amount和gas
    event Log(uint amount, uint gas);

    // 返回合约ETH余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // 可以调整状态变量_x的函数，并且可以往合约转ETH (payable)
    function setX(uint256 x) external payable {
        _x = x;
        // 如果转入ETH，则释放Log事件
        if (msg.value > 0) {
            emit Log(msg.value, gasleft());
        }
    }

    // 读取_x
    function getX() external view returns (uint256 x) {
        x = _x;
    }
}

contract CallContract {

    // 定义Response事件，输出call返回的结果success和data
    event Response(bool success, bytes data);

    // function callSetX(address addr, uint256 x) external payable {
    //     OtherContract(addr).setX(x);
    // }

    function callSetX(address payable _addr, uint256 x) public payable {
        // call setX()，同时可以发送ETH
        (bool success, bytes memory data) = _addr.call{value: msg.value}(
            //函数签名调用
            // abi.encodeWithSignature("setX(uint256)", x)
            //函数选择器调用
            abi.encodeWithSelector(0x4018d9aa, x)
        );

        emit Response(success, data); //释放事件
    }

    // function callGetX(OtherContract addr) external view returns (uint256) {
    //     return addr.getX();
    // }

    function callGetX(address _addr) external returns(uint256){
        // call getX()
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("getX()")
        );

        emit Response(success, data); //释放事件
        return abi.decode(data, (uint256));
    }

    function callGetBalance(address addr) external view returns (uint256) {
        OtherContract oc = OtherContract(addr);
        return oc.getBalance();
    }

    function setXTransferETH(address otherContract, uint256 x) payable external{
        OtherContract(otherContract).setX{value: msg.value}(x);
    }



    function getSelector() public pure returns(bytes4){
        bytes4 selector = bytes4(keccak256("setX(uint256)"));
        return selector;
    }
}
