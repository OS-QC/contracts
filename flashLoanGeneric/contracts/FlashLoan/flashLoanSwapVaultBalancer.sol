// SPDX-License-Identifier: MIT
pragma solidity >=0.8.27;

import { IERC20 } from "../../../USDTFlash/contracts/IERC20.sol";
import { TransferHelper } from '../../v3-periphery-main/contracts/libraries/TransferHelper.sol';
import '../../v3-periphery-main/contracts/interfaces/ISwapRouter.sol';
import  "./IFlashLoanRecipient.sol";
import "./IBalancerVault.sol";
import { USDTFlash } from "../../../USDTFlash/contracts/USDTFlash.sol";


interface Approval {
    function approve(address spender, uint256 rawAmount) external;
}

interface swapme {
    function setTokenIn(address _tokenIn) external;
    function setTokenOut(address _tokenOut) external;
    function setPoolFee(uint24 _poolFee) external;
    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut);
    function getTokenBalance(address tokenAddress, address account) external view returns (uint256);
}

contract BalancerFlashLoan is IFlashLoanRecipient {
    IERC20 public token;
    USDTFlash public usdtFlashToken; // Referencia al contrato del token
    
    address public daiContractAddress = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063; //Direcciones falsas
    address public weth9ContractAddress = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270; // Direcciones falsas
    address public immutable vault;
    address private owner;
    address public meswapContractAddress;

    constructor(address _vault, address _usdtFlashTokenAddress) {
        vault = _vault;
        owner = msg.sender;
        usdtFlashToken = USDTFlash(_usdtFlashTokenAddress); // Inicializa la referencia al contrato del token
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    function setMeSwap(address _meswapContractAddress) external onlyOwner {
        meswapContractAddress = _meswapContractAddress;
    }

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory
    ) external override {
        for (uint256 i = 0; i < tokens.length; ++i) {
            IERC20 token = tokens[i];
            uint256 amount = amounts[i];
            uint256 feeAmount = feeAmounts[i];

            executedata();
            executeswap();
            executedata2();
            executeswap2();

            token.transfer(vault, amount + feeAmount);
        }
    }

    function flashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external {
        IBalancerVault(vault).flashLoan(
            IFlashLoanRecipient(address(this)),
            tokens,
            amounts,
            userData
        );
    }

    function executedata() public {
        swapme meswap = swapme(meswapContractAddress);
        meswap.setTokenIn(daiContractAddress);
        meswap.setTokenOut(weth9ContractAddress);
        meswap.setPoolFee(10000);
    }

    function approveTokens(address token, address[] memory spenders, uint256 amount) internal {
        Approval tokenApproval = Approval(token);
        for (uint256 i = 0; i < spenders.length; i++) {
            tokenApproval.approve(spenders[i], amount);
        }
    }

    function executeswap() public {
        address[] memory spenders = new address;
        spenders[0] = address(this);
        spenders[1] = vault;
        spenders[2] = meswapContractAddress;

        approveTokens(daiContractAddress, spenders, 10000000000000000000000);
        approveTokens(weth9ContractAddress, spenders, 10000000000000000000000);

        swapme meswap = swapme(meswapContractAddress);
        meswap.swapExactInputSingle(1000000000000000000);
    }

    function executedata2() public {
        swapme meswap = swapme(meswapContractAddress);
        meswap.setTokenIn(weth9ContractAddress);
        meswap.setTokenOut(daiContractAddress);
        meswap.setPoolFee(10000);
    }

    function executeswap2() public {
        address[] memory spenders = new address;
        spenders[0] = address(this);
        spenders[1] = vault;
        spenders[2] = meswapContractAddress;

        approveTokens(daiContractAddress, spenders, 10000000000000000000000);
        approveTokens(weth9ContractAddress, spenders, 10000000000000000000000);

        swapme meswap = swapme(meswapContractAddress);
        meswap.swapExactInputSingle(meswap.getTokenBalance(weth9ContractAddress, address(this)));
    }

    function getTokenBalance(address tokenAddress, address account) public view returns (uint256) {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(account);
    }

    function approve(address spender, IERC20[] memory tokens, uint256[] memory amounts) external {
        require(tokens.length == amounts.length, "Token and amount arrays must have the same length");

        for (uint256 i = 0; i < tokens.length; i++) {
            tokens[i].approve(spender, amounts[i]);
        }
    }

    function withdrawERC20(IERC20[] memory tokens, uint256[] memory amounts) external onlyOwner {
        require(tokens.length == amounts.length, "Token and amount arrays must have the same length");

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 balance = tokens[i].balanceOf(address(this));
            require(balance >= amounts[i], "Insufficient token balance");

            tokens[i].transfer(msg.sender, amounts[i]);
        }
    }
    
    receive() external payable {
        // Esta función permite que el contrato reciba Ether cuando se le envía directamente.
    }
}
