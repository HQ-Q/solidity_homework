// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract ReverseString{

    //反转一个字符串。输入 "abcde"，输出 "edcba"
    function reverseString(string memory str) public pure returns (string memory){
        // 将字符串转换为bytes类型以进行索引操作
        bytes memory strBytes = bytes(str);
        // 获取字符串长度
        uint length = strBytes.length;
        // 从两端向中间交换字符实现反转
        for (uint i = 0; i < length / 2; i++) {
            // 临时存储当前字符
            bytes1 temp = strBytes[i];
            // 交换对称位置的字符
            strBytes[i] = strBytes[length - 1 - i];
            strBytes[length - 1 - i] = temp;
        }
        // 将bytes转换回string并返回
        return string(strBytes);
    }


}