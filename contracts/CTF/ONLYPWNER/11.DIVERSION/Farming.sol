// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IOracle } from "./interfaces/IOracle.sol";
import { IWETH } from "./interfaces/IWETH.sol";
import { IFarming } from "./interfaces/IFarming.sol";
import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { IMintableERC20 } from "./interfaces/IMintableERC20.sol";
import { IUniswapV2Router02 } from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Farming is ReentrancyGuard, IFarming {
    IWETH public WETH;
    IMintableERC20 public VUL;
    IOracle public ORACLE;
    IUniswapV2Router02 public UNISWAPV2_ROUTER02;

    mapping(address => uint256) public shares;
    uint256 public totalShares = 0;

    uint256 lastAccumulateTimestamp;
    uint256 yieldVulPerSecond;

    constructor(address _vul, address _weth, address _oracle, address _router, uint256 _yieldVulPerSecond) {
        VUL = IMintableERC20(_vul);
        WETH = IWETH(_weth);
        ORACLE = IOracle(_oracle);
        UNISWAPV2_ROUTER02 = IUniswapV2Router02(_router);
        yieldVulPerSecond = _yieldVulPerSecond;
        lastAccumulateTimestamp = block.timestamp;
    }

    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "Farming: Amount must be greater than 0");

        // TODO: Allow users to specify the path here too?
        accumulateYield(getDefaultPath());

        uint256 currentBalance = WETH.balanceOf(address(this));
        uint256 currentShares = totalShares;

        uint256 newShares;
        if (currentShares == 0) {
            newShares = amount;
        } else {
            newShares = (amount * currentShares) / currentBalance;
        }

        shares[msg.sender] += newShares;
        totalShares += newShares;

        // This should be fine since we are hardcoded to WETH.
        WETH.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 sharesAmount) external nonReentrant {
        require(sharesAmount > 0, "Farming: Amount must be greater than 0");

        accumulateYield(getDefaultPath());

        uint256 currentBalance = WETH.balanceOf(address(this));
        uint256 payoutAmount = (sharesAmount * currentBalance) / totalShares;

        shares[msg.sender] -= sharesAmount;
        totalShares -= sharesAmount;

        WETH.transfer(msg.sender, payoutAmount);
    }

    function accumulateYield(address[] memory path) public {
        uint256 secs = block.timestamp - lastAccumulateTimestamp;
        uint256 yield = secs * yieldVulPerSecond;

        if (yield == 0) {
            // Save some gas if there is no yield to accumulate.
            return;
        }

        lastAccumulateTimestamp = block.timestamp;

        VUL.mint(address(this), yield);
        swapYieldToWeth(path);
    }

    function swapYieldToWeth(address[] memory path) private {
        require(path.length > 1, "Farming: Path must have at least 2 elements");
        require(path[0] == address(VUL), "Farming: Path must start with VUL");
        require(path[path.length - 1] == address(WETH), "Farming: Path must end with WETH");

        uint256 amount = VUL.balanceOf(address(this));
        // We are fine with any path as long as it has a better price.
        // The oracle is pinned to the VUL-WETH pair, so if another path works
        // based on the below formula, it is guaranteed that the price is better.
        uint256 expectedWethAmount = (ORACLE.vulToWethPrice() * amount) / 1e18;

        VUL.approve(address(UNISWAPV2_ROUTER02), amount);
        UNISWAPV2_ROUTER02.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount, expectedWethAmount, path, address(this), block.timestamp
        );
    }

    function getDefaultPath() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = address(VUL);
        path[1] = address(WETH);
        return path;
    }
}
