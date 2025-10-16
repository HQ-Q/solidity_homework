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

    // 账户余额
    mapping(address => uint256) private _balances;

    // 授权信息
    mapping(address => mapping(address => uint256)) private _allowances;

    // 转账事件
    event Transfer(address from, address to, uint256 amount);

    // 授权事件
    event Approval(address owner, address spender, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) {
        totalSupply = _initialSupply * 10**uint256(decimals); // 初始化总供应量（正确处理小数位）
        name = _name;
        symbol = _symbol;
        _balances[msg.sender] = totalSupply; // 部署者获得初始代币
        owner = msg.sender;
    }

    // 转账函数
    function transfer(address recipient, uint256 amount)
        public
        virtual
        returns (bool)
    {
        require(recipient != address(0), "Invalid recipient address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // 授权函数名应为approve（标准ERC20）
    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "Invalid address");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 授权转账
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(from != address(0), "Invalid address");
        require(to != address(0), "Invalid address");
        require(_balances[from] >= amount, "Insufficient balance");
        require(_allowances[from][msg.sender] >= amount, "Allowance exceeded");
        
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    /**
     * @dev 增发代币功能，仅所有者可调用
     * 修复：添加小数位处理（amount需传入实际数量，函数内部自动乘以10^decimals）
     */
    function mint(address to, uint256 amount) public {
        require(msg.sender == owner, "Only owner can mint");
        require(to != address(0), "Invalid address");
        
        uint256 mintAmount = amount * 10**uint256(decimals); // 处理小数位
        totalSupply += mintAmount;
        _balances[to] += mintAmount;
        emit Transfer(address(0), to, mintAmount);
    }

    // 余额查询函数名应为balanceOf（标准ERC20）
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
}
