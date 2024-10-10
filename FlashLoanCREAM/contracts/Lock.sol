// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {IERC3156FlashLender} from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyFlashLoan is IERC3156FlashBorrower {
    IERC3156FlashLender public lender;

    constructor(address lenderAddress) {
        lender = IERC3156FlashLender(lenderAddress);
    }

    function executeFlashLoan(address token, uint256 amount, bytes calldata data) external {
        uint256 fee = lender.flashFee(token, amount);
        uint256 repayment = amount + fee;

        // Initiate the flash loan
        lender.flashLoan(this, token, amount, data);

        // Ensure the contract has enough balance to repay the loan
        require(IERC20(token).balanceOf(address(this)) >= repayment, "Insufficient balance to repay loan");

        // Repay the loan
        IERC20(token).transfer(address(lender), repayment);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        // Your custom logic here

        // Return the keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
