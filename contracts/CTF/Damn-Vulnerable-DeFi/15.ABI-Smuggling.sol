// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@solady/utils/SafeTransferLib.sol";
import { Address } from "@openzeppelin/contracts-v4.7.1/utils/Address.sol";
import { IERC20 } from "@openzeppelin/contracts-v4.7.1/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts-v4.7.1/security/ReentrancyGuard.sol";

/**
 * @title AuthorizedExecutor
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

abstract contract AuthorizedExecutor is ReentrancyGuard {
    using Address for address;

    bool public initialized;

    // action identifier => allowed
    mapping(bytes32 => bool) public permissions;

    error NotAllowed();
    error AlreadyInitialized();

    event Initialized(address who, bytes32[] ids);

    /**
     * @notice Allows first caller to set permissions for a set of action identifiers
     * @param ids array of action identifiers
     */
    function setPermissions(bytes32[] memory ids) external {
        if (initialized) {
            revert AlreadyInitialized();
        }

        for (uint256 i = 0; i < ids.length;) {
            unchecked {
                permissions[ids[i]] = true;
                ++i;
            }
        }
        initialized = true;

        emit Initialized(msg.sender, ids);
    }

    /**
     * @notice Performs an arbitrary function call on a target contract, if the caller is authorized to do so.
     * @param target account where the action will be executed
     * @param actionData abi-encoded calldata to execute on the target
     */
    function execute(address target, bytes calldata actionData) external nonReentrant returns (bytes memory) {
        // Read the 4-bytes selector at the beginning of `actionData`
        bytes4 selector;
        uint256 calldataOffset = 4 + 32 * 3; // calldata position where `actionData` begins
        assembly {
            selector := calldataload(calldataOffset)
        }

        if (!permissions[getActionId(selector, msg.sender, target)]) {
            revert NotAllowed();
        }

        _beforeFunctionCall(target, actionData);

        return target.functionCall(actionData);
    }

    function _beforeFunctionCall(address target, bytes memory actionData) internal virtual;

    function getActionId(bytes4 selector, address executor, address target) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(selector, executor, target));
    }
}

/**
 * @title SelfAuthorizedVault
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SelfAuthorizedVault is AuthorizedExecutor {
    uint256 public constant WITHDRAWAL_LIMIT = 1 ether;
    uint256 public constant WAITING_PERIOD = 15 days;

    uint256 private _lastWithdrawalTimestamp = block.timestamp;

    error TargetNotAllowed();
    error CallerNotAllowed();
    error InvalidWithdrawalAmount();
    error WithdrawalWaitingPeriodNotEnded();

    modifier onlyThis() {
        if (msg.sender != address(this)) {
            revert CallerNotAllowed();
        }
        _;
    }

    /**
     * @notice Allows to send a limited amount of tokens to a recipient every now and then
     * @param token address of the token to withdraw
     * @param recipient address of the tokens' recipient
     * @param amount amount of tokens to be transferred
     */
    function withdraw(address token, address recipient, uint256 amount) external onlyThis {
        if (amount > WITHDRAWAL_LIMIT) {
            revert InvalidWithdrawalAmount();
        }

        if (block.timestamp <= _lastWithdrawalTimestamp + WAITING_PERIOD) {
            revert WithdrawalWaitingPeriodNotEnded();
        }

        _lastWithdrawalTimestamp = block.timestamp;

        SafeTransferLib.safeTransfer(token, recipient, amount);
    }

    function sweepFunds(address receiver, IERC20 token) external onlyThis {
        SafeTransferLib.safeTransfer(address(token), receiver, token.balanceOf(address(this)));
    }

    function getLastWithdrawalTimestamp() external view returns (uint256) {
        return _lastWithdrawalTimestamp;
    }

    function _beforeFunctionCall(address target, bytes memory) internal view override {
        if (target != address(this)) {
            revert TargetNotAllowed();
        }
    }
}
