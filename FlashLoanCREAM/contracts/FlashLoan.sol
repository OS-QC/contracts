// SPDX-License-Identifier: MIT
pragma solidity >=0.8.27;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {IERC3156FlashLender} from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";

contract FlashLoanArbitrageCream is IERC3156FlashBorrower {
    address payable owner;
    IERC3156FlashLender public lender;

    event ContractDeployed(address owner);

    constructor(address _lender) {
        owner = payable(msg.sender);
        lender = IERC3156FlashLender(_lender);
        emit ContractDeployed(owner);
    }

    function executeOperation(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        // Decodificar los parámetros
        (address[] memory exchanges, bytes[] memory data) = abi.decode(params, (address[], bytes[]));

        // Ejecutar la lógica de arbitraje
        for (uint256 i = 0; i < exchanges.length; i++) {
            (bool success, ) = exchanges[i].call(data[i]);
            require(success, "Arbitrage operation failed");
        }

        // Rembolso del préstamo
        uint256 amountOwed = amount + fee;
        IERC20(token).approve(address(lender), amountOwed);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function requestFlashLoan(address _token, uint256 _amount, bytes memory _params) public {
        address receiverAddress = address(this);
        bytes memory data = _params;

        lender.flashLoan(
            IERC3156FlashBorrower(receiverAddress),
            _token,
            _amount,
            data
        );
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    receive() external payable {}
}
