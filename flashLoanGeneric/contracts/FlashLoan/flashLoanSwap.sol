// SPDX-License-Identifier: MIT
pragma solidity >=0.8.27;

import { IERC20 } from "../../../USDTFlash/contracts/IERC20.sol";
import { USDTFlash } from "../../../USDTFlash/contracts/USDTFlash.sol";

interface swapme {
    function setTokenIn(address _tokenIn) external;
    function setTokenOut(address _tokenOut) external;
    function setPoolFee(uint24 _poolFee) external;
    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut);
}

interface IDex {
    function borrow(uint256 amount, address collateral) external;
    function repay(uint256 amount, address collateral) external;
}

contract GenericFlashLoan {
    IERC20 public immutable usdtToken;
    USDTFlash public immutable usdtFlashToken;
    address public tokenIn;
    address public tokenOut;
    uint256 public poolFee;
    uint256 public swapAmount;
    uint256 public numOperations;
    address private immutable owner;
    address public meswapContractAddress;
    address public dexAddress;

    event Received(address sender, uint256 amount);
    event LoanRequested(address indexed borrower, uint256 amount);
    event LoanRepaid(address indexed borrower, uint256 amount);
    event SwapExecuted(address indexed tokenIn, address indexed tokenOut, uint256 amount);

    constructor(
        address _usdtTokenAddress,
        address _usdtFlashTokenAddress,
        address _dexAddress,
        address _tokenIn,
        address _tokenOut,
        uint256 _poolFee,
        uint256 _swapAmount,
        uint256 _numOperations
    ) {
        owner = msg.sender;
        usdtToken = IERC20(_usdtTokenAddress);
        usdtFlashToken = USDTFlash(_usdtFlashTokenAddress);
        dexAddress = _dexAddress;
        tokenIn = _tokenIn;
        tokenOut = _tokenOut;
        poolFee = _poolFee;
        swapAmount = _swapAmount;
        numOperations = _numOperations;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    function setMeSwap(address _meswapContractAddress) external onlyOwner {
        meswapContractAddress = _meswapContractAddress;
    }

    function setTokenIn(address _tokenIn) external onlyOwner {
        tokenIn = _tokenIn;
    }

    function setTokenOut(address _tokenOut) external onlyOwner {
        tokenOut = _tokenOut;
    }

    function setPoolFee(uint256 _poolFee) external onlyOwner {
        poolFee = _poolFee;
    }

    function setSwapAmount(uint256 _swapAmount) external onlyOwner {
        swapAmount = _swapAmount;
    }

    function setNumOperations(uint256 _numOperations) external onlyOwner {
        numOperations = _numOperations;
    }

    function depositCollateral(uint256 amount) external {
        require(usdtFlashToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }

    function withdrawCollateral(uint256 amount) external onlyOwner {
        require(usdtFlashToken.transfer(msg.sender, amount), "Transfer failed");
    }

    function requestFlashLoan(uint256 amount) external onlyOwner {
        IDex(dexAddress).borrow(amount, address(usdtFlashToken));
        emit LoanRequested(msg.sender, amount);
    }

    function repayFlashLoan(uint256 amount) external onlyOwner {
        IDex(dexAddress).repay(amount, address(usdtFlashToken));
        emit LoanRepaid(msg.sender, amount);
    }

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory
    ) external {
        for (uint256 i = 0; i < tokens.length; ++i) {
            IERC20 token = tokens[i];
            uint256 amount = amounts[i];
            uint256 feeAmount = feeAmounts[i];

            for (uint256 j = 0; j < numOperations; j++) {
                executeSwap(tokenIn, tokenOut, swapAmount);
                executeSwap(tokenOut, tokenIn, swapAmount);
            }

            swapToUSDT(amount + feeAmount);

            token.transfer(msg.sender, amount + feeAmount);
        }
    }

    function executeSwap(address _tokenIn, address _tokenOut, uint256 _amount) internal {
        swapme meswap = swapme(meswapContractAddress);
        meswap.setTokenIn(_tokenIn);
        meswap.setTokenOut(_tokenOut);
        meswap.setPoolFee(uint24(poolFee));
        meswap.swapExactInputSingle(_amount);
        emit SwapExecuted(_tokenIn, _tokenOut, _amount);
    }

    function swapToUSDT(uint256 amount) internal {
        swapme meswap = swapme(meswapContractAddress);
        meswap.setTokenIn(tokenOut);
        meswap.setTokenOut(address(usdtToken));
        meswap.setPoolFee(uint24(poolFee));
        meswap.swapExactInputSingle(amount);
        emit SwapExecuted(tokenOut, address(usdtToken), amount);
    }

    function getTokenBalance(address tokenAddress, address account) public view returns (uint256) {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(account);
    }

    function mintIfNeeded(uint256 amount) internal {
        uint256 currentSupply = usdtFlashToken.totalSupply();
        uint256 maxSupply = usdtFlashToken.maxSupply();
        require(currentSupply + amount <= maxSupply, "Minting would exceed max supply");
        usdtFlashToken.mint(amount);
    }

    function withdrawGains() external onlyOwner {
        uint256 balance = usdtFlashToken.balanceOf(address(this));
        require(balance > 0, "No USDT Flash available to withdraw");
        mintIfNeeded(balance);
        usdtFlashToken.transfer(owner, balance);
    }
    
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
