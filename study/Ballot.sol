// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Ballot
 * @dev 一个高效的投票合约，支持直接投票和委托投票功能
 * @custom:security-contact security@example.com
 */
contract Ballot {
    // --- 自定义错误 ---
    // 使用自定义错误代替字符串错误信息，可显著节省gas
    error OnlyChairperson();       // 仅主席可执行
    error AlreadyVoted();          // 已投票
    error SelfDelegation();        // 不能委托给自己
    error InvalidProposal();       // 提案ID无效
    error NoVotingRights();        // 没有投票权
    error DelegateCycle();         // 委托链中出现循环

    // --- 结构体 ---
    /**
     * @dev 投票者信息结构体
     * @param weight 投票权重
     * @param voted 是否已投票
     * @param vote 投票给哪个提案
     * @param delegate 委托对象
     */
    struct Voter {
        uint96 weight;     // 使用uint96节省gas（存储打包优化）
        bool voted;
        uint8 vote;
        address delegate;
    }

    /**
     * @dev 提案信息结构体
     * @param voteCount 获得的票数
     */
    struct Proposal {
        uint256 voteCount;
    }

    // --- 状态变量 ---
    address public immutable chairperson; // 主席地址，不可变
    mapping(address => Voter) public voters; // 投票者信息映射
    Proposal[] public proposals; // 提案数组

    // --- 事件 ---
    event VoterAdded(address indexed voter);
    event Voted(address indexed voter, uint8 indexed proposalId, uint96 weight);
    event Delegated(address indexed from, address indexed to, uint96 weight);

    /**
     * @dev 构造函数
     * @param _numProposals 提案数量
     */
    constructor(uint8 _numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1; // 主席默认有1票权重
        //初始化提案数组
        for (uint i = 0; i < _numProposals; i++) {
            Proposal memory p = Proposal({
                voteCount: 0
            });
            proposals.push(p);
        }
    }

    /**
     * @dev 主席授予投票权
     * @param voter 被授权的地址
     */
    function giveRightToVote(address voter) public  {
        if (msg.sender != chairperson) revert OnlyChairperson();
        Voter storage v = voters[voter];
        // 已授权则直接返回避免重复授权
        if (v.weight > 0){
            
        } 
        v.weight = 1;
        emit VoterAdded(voter);
    }

    /**
     * @dev 委托投票
     * @param to 委托对象
     */
    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        if (sender.voted) revert AlreadyVoted();
        if (to == msg.sender) revert SelfDelegation();
        if (sender.weight == 0) revert NoVotingRights();

        // 处理委托链，找到最终的委托对象
        while (voters[to].delegate != address(0)) {
            address prev = to;
            to = voters[to].delegate;
            if (to == msg.sender) {
                revert DelegateCycle();
            }
            if (to == prev) break;  // 防止自循环
        }

        sender.voted = true;
        sender.delegate = to;

        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // 如果委托对象已投票，直接增加对应提案的票数
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // 如果委托对象未投票，增加其投票权重
            delegate_.weight += sender.weight;
        }
        emit Delegated(msg.sender, to, sender.weight);
    }

    /**
     * @dev 直接投票
     * @param toProposal 提案ID
     */
    function vote(uint8 toProposal) external {
        //不能越界
        if (toProposal >= proposals.length) revert InvalidProposal();
        
        Voter storage sender = voters[msg.sender];
        if (sender.voted) revert AlreadyVoted();
        if (sender.weight == 0) revert NoVotingRights();

        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;
        
        emit Voted(msg.sender, toProposal, sender.weight);
    }

    /**
     * @dev 获取获胜提案
     * @return 获胜提案ID和票数
     */
    function winningProposal() external view returns (uint8, uint256) {
        uint8 winningProposal_ = 0;
        uint256 currentVotes = 0;
        
        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > currentVotes) {
                currentVotes = proposals[i].voteCount;
                winningProposal_ = uint8(i);
            }
        }
        
        return (winningProposal_, currentVotes);
    }
}