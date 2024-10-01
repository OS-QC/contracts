// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity >=0.8.27;

/**
 * @dev Standard ERC-20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-20 tokens.
 */
interface IERC20Errors {

    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);


    error ERC20InvalidSender(address sender);


    error ERC20InvalidReceiver(address receiver);


    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);


    error ERC20InvalidApprover(address approver);


    error ERC20InvalidSpender(address spender);
}