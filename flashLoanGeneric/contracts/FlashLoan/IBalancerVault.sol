// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IFlashLoanRecipient.sol";

interface IBalancerVault {
    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}
