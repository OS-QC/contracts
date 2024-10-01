// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity >=0.8.27;

/**
 * @dev Standard ERC-20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-20 tokens.
 */
interface ITRC20Errors {

    error TRC20InsufficientBalance(address sender, uint256 balance, uint256 needed);


    error TRC20InvalidSender(address sender);


    error TRC20InvalidReceiver(address receiver);


    error TRC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);


    error TRC20InvalidApprover(address approver);


    error TRC20InvalidSpender(address spender);
}