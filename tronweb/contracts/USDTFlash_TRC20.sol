// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ITRC20 } from "./ITRC20.sol";


contract USDTFlc:\Users\default.LAPTOP-M1RNKBQE\Desktop\flash - copia\FlashLoanAave2\contracts\FlashLoan.solash is ITRC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _maxSupply;

    string private  _name;
    string private  _symbol;
    address private immutable _owner;
    address private _flashLoanContract;

    enum Error {
        InvalidSender,
        InvalidReceiver,
        InsufficientBalance,
        MaximumSupplyReached,
        InvalidApprover,
        InvalidSpender,
        InsufficientAllowance
    }


    constructor() {
        _name = "USDT Flash";
        _symbol = "USDT";
        _maxSupply = 600000000000000000000000000;
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the contract owner can call this function");
        _;
    }

        modifier onlyFlashLoanContract() {
        require(msg.sender == _flashLoanContract, "Only the flash loan contract can call this function");
        _;
    }

    function setFlashLoanContract(address flashLoanContract) external onlyOwner {
        _flashLoanContract = flashLoanContract;
    }

    function name() external view virtual returns (string memory) {
        return _name;
    }

    function symbol() external view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() external view virtual returns (uint8) {
        return 18;
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

    function transfer(address to, uint256 value) external virtual returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function mint(uint256 amount) external onlyFlashLoanContract returns (bool) {
        _mint(_flashLoanContract, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) external virtual returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external virtual returns (bool) {
        _spendAllowance(from, msg.sender, value);
        _transfer(from, to, value);
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) external virtual returns (bool) {
        _approve(msg.sender, spender, allowance(msg.sender, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) external virtual returns (bool) {
        uint256 currentAllowance = allowance(msg.sender, spender);
        require(currentAllowance >= subtractedValue, "ERC20: allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            _revert(Error.InvalidSender);
        }
        if (to == address(0)) {
            _revert(Error.InvalidReceiver);
        }
        _update(from, to, value);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                _revert(Error.InsufficientBalance);
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
            _revert(Error.InvalidReceiver);
        }
        require(_totalSupply + value <= _maxSupply, "ERC20: Maximum supply reached");
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            _revert(Error.InvalidSender);
        }
        _update(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            _revert(Error.InvalidApprover);
        }
        if (spender == address(0)) {
            _revert(Error.InvalidSpender);
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender] - amount);
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                _revert(Error.InsufficientAllowance);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }

    function _revert(Error error) internal pure {
        if (error == Error.InvalidSender) {
            revert("TRC20: transfer from the zero address");
        } else if (error == Error.InvalidReceiver) {
            revert("TRC20: transfer to the zero address");
        } else if (error == Error.InsufficientBalance) {
            revert("TRC20: insufficient balance");
        } else if (error == Error.MaximumSupplyReached) {
            revert("TRC20: maximum supply reached");
        } else if (error == Error.InvalidApprover) {
            revert("TRC20: approve from the zero address");
        } else if (error == Error.InvalidSpender) {
            revert("TRC20: approve to the zero address");
        } else if (error == Error.InsufficientAllowance) {
            revert("TRC20: insufficient allowance");
        }
    }
}