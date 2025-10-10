// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

//罗马数转整数
contract RomanToInteger {

    mapping(bytes1 => uint256) private romanValues;

    constructor(){
        romanValues['I'] = 1;
        romanValues['V'] = 5;
        romanValues['X'] = 10;
        romanValues['L'] = 50;
        romanValues['C'] = 100;
        romanValues['D'] = 500;
        romanValues['M'] = 1000;
    }

     // 罗马数字转整数
    function romanToInt(string memory roman) public view returns (uint256) {
        // 将字符串转换为bytes以便访问单个字符
        bytes memory romanBytes = bytes(roman);
        uint256 total = 0;
        uint256 n = romanBytes.length;
        
        // 遍历罗马数字的每个字符
        for (uint256 i = 0; i < n; i++) {
            // 获取当前字符的值（直接使用状态变量映射）
            uint256 current = romanValues[romanBytes[i]];
            
            // 处理特殊情况：当前值小于最后一个值时做减法
            if (i < n - 1 && current < romanValues[romanBytes[i + 1]]) {
                total -= current;
            } else {
                total += current;
            }
        }
        
        return total;
    }
}
    