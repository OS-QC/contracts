// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;


interface ITRC20Errors {

    error TRC20InsufficientBalance(address sender, uint256 balance, uint256 needed);


    error TRC20InvalidSender(address sender);


    error TRC20InvalidReceiver(address receiver);


    error TRC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);


    error TRC20InvalidApprover(address approver);


    error TRC20InvalidSpender(address spender);
}