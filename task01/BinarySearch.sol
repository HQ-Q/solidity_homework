// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract BinarySearch {
    // 二分查找函数：在升序数组中查找目标值
    // 返回值：找到则返回索引（uint256），未找到则返回-1（通过int256类型实现）
    function binarySearch(int[] memory arr, int target) public pure returns (int256) {
        // 处理空数组情况
        if (arr.length == 0) {
            return -1; 
        }
        
        int256 left = 0;
        int256 right = int256(arr.length) - 1;
        
        // 二分查找主循环
        while (left <= right) {
            // 计算中间索引（避免溢出）
            int256 mid = left + (right - left) / 2;
            
            // 找到目标值，返回索引
            if (arr[uint256(mid)] == target) {
                return mid;
            }
            // 目标值在右侧，移动左指针
            else if (arr[uint256(mid)] < target) {
                left = mid + 1;
            }
            // 目标值在左侧，移动右指针
            else {
                right = mid - 1;
            }
        }
        
        // 循环结束仍未找到，返回-1
        return -1;
    }
}
    