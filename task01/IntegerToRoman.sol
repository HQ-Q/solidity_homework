// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract IntegerToRoman {
    // 整数转罗马数字
    function intToRoman(uint256 num) public pure returns (string memory) {
        // 定义罗马数字的数值和对应符号，按从大到小排序
        uint256[] memory values = new uint256[](13);
        bytes[] memory symbols = new bytes[](13);
        
        // 初始化数值数组
        values[0] = 1000;
        values[1] = 900;
        values[2] = 500;
        values[3] = 400;
        values[4] = 100;
        values[5] = 90;
        values[6] = 50;
        values[7] = 40;
        values[8] = 10;
        values[9] = 9;
        values[10] = 5;
        values[11] = 4;
        values[12] = 1;
        
        // 初始化对应的罗马数字符号
        symbols[0] = "M";
        symbols[1] = "CM";
        symbols[2] = "D";
        symbols[3] = "CD";
        symbols[4] = "C";
        symbols[5] = "XC";
        symbols[6] = "L";
        symbols[7] = "XL";
        symbols[8] = "X";
        symbols[9] = "IX";
        symbols[10] = "V";
        symbols[11] = "IV";
        symbols[12] = "I";
        
        // 创建bytes数组用于构建结果
        bytes memory result = new bytes(0);
        uint256 resultLength = 0;
        
        // 遍历所有数值，构建罗马数字
        for (uint256 i = 0; i < values.length; i++) {
            // 当当前数值小于等于剩余数值时，添加对应符号并减去该数值
            while (num >= values[i]) {
                // 计算新结果的长度
                uint256 newLength = resultLength + symbols[i].length;
                // 创建新的bytes数组
                bytes memory newResult = new bytes(newLength);
                
                // 复制原有结果
                for (uint256 j = 0; j < resultLength; j++) {
                    newResult[j] = result[j];
                }
                
                // 添加新的符号
                for (uint256 j = 0; j < symbols[i].length; j++) {
                    newResult[resultLength + j] = symbols[i][j];
                }
                
                // 更新结果和长度
                result = newResult;
                resultLength = newLength;
                
                // 减去对应的值
                num -= values[i];
            }
            
            // 如果数值已减为0，退出循环
            if (num == 0) {
                break;
            }
        }
        
        // 将bytes转换为string并返回
        return string(result);
    }
}
    