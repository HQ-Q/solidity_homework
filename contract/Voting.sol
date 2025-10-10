// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Voting{

    mapping ( address user => uint256 votes) public _votesReceived; 

    // 存储所有参与过的候选人地址，用于重置功能
    address[] private _candidates;

    // 用于检查候选人是否已在数组中，避免重复添加
    mapping(address => bool) private _isCandidate;


    address private  _owner;

    constructor(){
        _owner = msg.sender;
    }

    //向指定候选人投票
    function votes(address user) public {
        require(user != address(0),"Invalid address");
        //如果是新的候选人，添加到数组中
        if (!_isCandidate[user]){
            _candidates.push(user);
            _isCandidate[user] = true;
        }
        _votesReceived[user]++;
    }

    // 获取指定候选人的得票数
    function getVotes(address user)public view returns (uint256){
        return _votesReceived[user];
    }

    //重置所有候选人的得票数
    function resetVotes() public {
        // 检查调用者是否为合约所有者
        require(msg.sender == _owner, "Voting: only owner can reset votes");
        // 遍历所有候选人，重置得票数
        for (uint256 i = 0; i < _candidates.length; i++) {
            _votesReceived[_candidates[i]] = 0;
        }
    }

    // 获取所有候选人列表
    function getCandidates() public view returns (address[] memory) {
        return _candidates;
    }

    // 获取合约所有者
    function owner() public view returns (address) {
        return _owner;
    }
}

