// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// ----------------------------------------------------------------------------
// Lib: Safe Math
// ----------------------------------------------------------------------------
contract SafeMath {

    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


contract StandardERC20 is IERC20, SafeMath {
    // state variables
    mapping (address => uint256) private _balances;
    
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _totalSupply;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address private owner;
    
    constructor () public {
        owner=msg.sender;
        _name = "Tasha Token";
        _symbol = "TSH";
        _decimals = 18; // 1 ether  = 10^18 wei
        _totalSupply = 1000000000000000000000;
        _balances[owner] = safeAdd(_balances[owner],_totalSupply);
        
    }
    
    modifier onlyOwner {
        require(msg.sender == owner,"Only owner can call this function.");
        _;
    }
    
    function name() public view returns (string memory) {
        return _name;
    }
    
    function symbol() public view  returns (string memory){
        return _symbol;
    }
    
    function decimals() public view returns(uint8) {
        return _decimals;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient,amount );
        return true;
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public override view returns(uint256) {
        return _allowances[owner][spender];
    } 
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns(bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, safeSub(_allowances[sender][msg.sender], amount));
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(recipient != address(0),"ERC20: transfer from zero transfer");
        require(sender != address(0),"ERC20: transfer from zero transfer");
        
        require(_balances[sender] >= amount, "ERC20: sender does not have enough amount");
        
        _balances[sender] = safeSub(_balances[sender], amount);
        _balances[recipient] = safeAdd(_balances[recipient],amount);
        emit Transfer(sender, recipient, amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
      require(spender != address(0),"ERC20: transfer from zero transfer");
      require(owner != address(0),"ERC20: transfer from zero transfer");
        
      require(_balances[owner] >= amount, "ERC20: owner does not have enough amount");
      _allowances[owner][spender] = amount;
      emit Approval(owner, spender, amount);
    }
    
    function burn(address _fromAccount, uint _amount) onlyOwner public{
        require(_fromAccount != address(0),"ERC20: transfer from zero transfer");
        require(_amount <= _balances[_fromAccount], "ERC20: owner does not have enough tokens");
        _balances[_fromAccount]= safeSub(_balances[_fromAccount],_amount);
        _totalSupply = safeSub(_totalSupply,_amount);
        emit Transfer(_fromAccount, address(0), _amount);
    }
    
    function mint(address _toAccount, uint _amount) onlyOwner public{
        require(_toAccount != address(0),"ERC20: transfer to zero transfer");
        require(_amount < 1e60);
        _balances[_toAccount] = safeAdd(_balances[_toAccount],_amount);
        _totalSupply= safeAdd(_totalSupply,_amount);
        emit Transfer(address(0), _toAccount, _amount);
    }
}