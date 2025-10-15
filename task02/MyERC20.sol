
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract MyERC20 {
    // 代币名称
    string public name;
    // 代币符号
    string public symbol;
    // 小数位数
    uint8 public decimals = 18;
    // 代币总供应量
    uint256 public totalSupply;

    // 合约所有者
    address public owner;

    //账户余额
    mapping(address => uint256) private _balances;

    //授权信息
    mapping(address => mapping(address => uint256)) private _allowances;

    //转账事件
    event Transfer(address from, address to, uint256 amount);

    //授权事件
    event Approval(address owner, address spender, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) {
        totalSupply = _initialSupply * 10**uint256(decimals); //初始化总供应量
        name = _name; //初始化代币名称
        symbol = _symbol; //初始化代币符号
        _balances[msg.sender] = totalSupply; //初始化合约所有者的余额
        owner = msg.sender;
    }

    //转账函数
    function transfer(address recipient, uint256 amount)
        public
        virtual
        returns (bool)
    {
        require(recipient != address(0), "Invalid recipient address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        require((_balances[recipient] + amount) > amount, "Overflow");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    //授权
    function approval(address spender, uint256 amount)public returns(bool){
        require(address(0)!=spender,"Invaild address");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }


    //授权转账
    function transferFrom(address from,address to,uint256 amount)public returns(bool){
        require(from != address(0), "Invaild address");
        require(to != address(0), "Invaild address");
        require(_balances[from] >= amount, "insufficient balance");
        require(_allowances[from][msg.sender] >= amount, "allowance exceeded");
        
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    /**
     * @dev 增发代币功能，仅所有者可调用
     * @param to 接收增发代币的地址
     * @param amount 增发数量
     */
    function mint(address to, uint256 amount) public {
        require(msg.sender == owner, "only owner can mint");
        require(to != address(0), "Invaild address");
        
        totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }


    //查询账户余额
    function balancesOf(address from)public view returns(uint256){
        return _balances[from];
    }


}
