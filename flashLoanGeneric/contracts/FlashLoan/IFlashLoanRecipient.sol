// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../USDTFlash/contracts/IERC20.sol";

interface IFlashLoanRecipient {
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external;
}
