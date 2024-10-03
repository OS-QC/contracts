// SPDX-License-Identifier: MIT
pragma solidity >=0.8.27;

import { FlashLoanSimpleReceiverBase } from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import { IERC20 } from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
import { IPoolAddressesProvider } from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";

contract FlashLoanArbitrage is FlashLoanSimpleReceiverBase {
    address payable owner;

    event ContractDeployed(address owner);

    constructor(address _addressProvider) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider)) {
        owner = payable(msg.sender);
        emit ContractDeployed(owner);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {

        // Decodificar los parámetros
        (address[] memory exchanges, bytes[] memory data) = abi.decode(params, (address[], bytes[]));

        // Ejecutar la lógica de arbitraje
        for (uint256 i = 0; i < exchanges.length; i++) {
            (bool success, ) = exchanges[i].call(data[i]);
            require(success, "Arbitrage operation failed");
        }
        // Rembolso del prestamo
        uint256 amountOwned = amount + premium;
        IERC20(asset).approve(address(POOL), amountOwned);

        return true;
    }

    function requestFlashLoan(address _token, uint256 _amount) public {
        address receiverAddress = address(this);
        address asset = _token;
        uint amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
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
