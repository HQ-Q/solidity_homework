
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract MergeSortedArray{


    function merge(int[] memory nums1,  int[] memory nums2) public pure returns(int[] memory) {  
        uint256 n = nums1.length;
        uint256 m = nums2.length;
        uint256 totalLength = m + n;
        int[] memory result = new int[](totalLength);
        uint256 i = 0; // nums1的指针
        uint256 j = 0; // nums2的指针
        uint256 k = 0; // 结果数组的指针
        
        // 同时遍历两个数组，按顺序放入结果数组
        while (i < nums1.length && j < nums2.length) {
            if (nums1[i] <= nums2[j]) {
                result[k] = nums1[i];
                i++;
            } else {
                result[k] = nums2[j];
                j++;
            }
            k++;
        }
        
        // 处理nums1剩余的元素
        while (i < nums1.length) {
            result[k] = nums1[i];
            i++;
            k++;
        }
        
        // 处理nums2剩余的元素
        while (j < nums2.length) {
            result[k] = nums2[j];
            j++;
            k++;
        }
        
        return result;
    }

}