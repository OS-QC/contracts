// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

import { ITRC20 } from "./ITRC20.sol";


interface ITRC20Metadata is ITRC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}