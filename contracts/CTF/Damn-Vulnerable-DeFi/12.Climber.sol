// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { SafeTransferLib } from "@solady/utils/SafeTransferLib.sol";
import { AccessControl } from "@openzeppelin/contracts-v4.7.3/access/AccessControl.sol";
import { Address } from "@openzeppelin/contracts-v4.7.3/utils/Address.sol";
import { IERC20 } from "@openzeppelin/contracts-v4.7.3/token/ERC20/IERC20.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable-v4.7.3/proxy/utils/Initializable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable-v4.7.3/access/OwnableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable-v4.7.3/proxy/utils/UUPSUpgradeable.sol";

/* ########################## */
/* ### TIMELOCK CONSTANTS ### */
/* ########################## */

// keccak256("ADMIN_ROLE");
bytes32 constant ADMIN_ROLE = 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775;

// keccak256("PROPOSER_ROLE");
bytes32 constant PROPOSER_ROLE = 0xb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1;

uint256 constant MAX_TARGETS = 256;
uint256 constant MIN_TARGETS = 0;
uint256 constant MAX_DELAY = 14 days;

/* ####################### */
/* ### VAULT CONSTANTS ### */
/* ####################### */

uint256 constant WITHDRAWAL_LIMIT = 1 ether;
uint256 constant WAITING_PERIOD = 15 days;

error CallerNotTimelock();
error NewDelayAboveMax();
error NotReadyForExecution(bytes32 operationId);
error InvalidTargetsCount();
error InvalidDataElementsCount();
error InvalidValuesCount();
error OperationAlreadyKnown(bytes32 operationId);
error CallerNotSweeper();
error InvalidWithdrawalAmount();
error InvalidWithdrawalTime();

/**
 * @title ClimberTimelockBase
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
abstract contract ClimberTimelockBase is AccessControl {
    // Possible states for an operation in this timelock contract
    enum OperationState {
        Unknown,
        Scheduled,
        ReadyForExecution,
        Executed
    }

    // Operation data tracked in this contract
    struct Operation {
        uint64 readyAtTimestamp; // timestamp at which the operation will be ready for execution
        bool known; // whether the operation is registered in the timelock
        bool executed; // whether the operation has been executed
    }

    // Operations are tracked by their bytes32 identifier
    mapping(bytes32 => Operation) public operations;

    uint64 public delay;

    function getOperationState(bytes32 id) public view returns (OperationState state) {
        Operation memory op = operations[id];

        if (op.known) {
            if (op.executed) {
                state = OperationState.Executed;
            } else if (block.timestamp < op.readyAtTimestamp) {
                state = OperationState.Scheduled;
                // @audit-info block.timestamp >= op.readyAtTimestamp
            } else {
                state = OperationState.ReadyForExecution;
            }
        } else {
            state = OperationState.Unknown;
        }
    }

    function getOperationId(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    )
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(targets, values, dataElements, salt));
    }

    receive() external payable { }
}

contract ClimberTimelock is ClimberTimelockBase {
    using Address for address;

    /**
     * @notice Initial setup for roles and timelock delay.
     * @param admin address of the account that will hold the ADMIN_ROLE role
     * @param proposer address of the account that will hold the PROPOSER_ROLE role
     */
    constructor(address admin, address proposer) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(PROPOSER_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, admin);
        _setupRole(ADMIN_ROLE, address(this)); // self administration
        _setupRole(PROPOSER_ROLE, proposer);

        delay = 1 hours;
    }

    function schedule(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    )
        external
        onlyRole(PROPOSER_ROLE)
    {
        if (targets.length == MIN_TARGETS || targets.length >= MAX_TARGETS) {
            revert InvalidTargetsCount();
        }

        if (targets.length != values.length) {
            revert InvalidValuesCount();
        }

        if (targets.length != dataElements.length) {
            revert InvalidDataElementsCount();
        }

        bytes32 id = getOperationId(targets, values, dataElements, salt);

        if (getOperationState(id) != OperationState.Unknown) {
            revert OperationAlreadyKnown(id);
        }

        operations[id].readyAtTimestamp = uint64(block.timestamp) + delay;
        operations[id].known = true;
    }

    /**
     * Anyone can execute what's been scheduled via `schedule`
     */
    function execute(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    )
        external
        payable
    {
        if (targets.length <= MIN_TARGETS) {
            revert InvalidTargetsCount();
        }

        if (targets.length != values.length) {
            revert InvalidValuesCount();
        }

        if (targets.length != dataElements.length) {
            revert InvalidDataElementsCount();
        }

        bytes32 id = getOperationId(targets, values, dataElements, salt);

        for (uint8 i = 0; i < targets.length;) {
            targets[i].functionCallWithValue(dataElements[i], values[i]);
            unchecked {
                ++i;
            }
        }

        if (getOperationState(id) != OperationState.ReadyForExecution) {
            revert NotReadyForExecution(id);
        }

        operations[id].executed = true;
    }

    function updateDelay(uint64 newDelay) external {
        if (msg.sender != address(this)) {
            revert CallerNotTimelock();
        }

        if (newDelay > MAX_DELAY) {
            revert NewDelayAboveMax();
        }

        delay = newDelay;
    }
}

/**
 * @title ClimberVault
 * @dev To be deployed behind a proxy following the UUPS pattern. Upgrades are to be triggered by the owner.
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract ClimberVault is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    uint256 private _lastWithdrawalTimestamp;
    address private _sweeper;

    modifier onlySweeper() {
        if (msg.sender != _sweeper) {
            revert CallerNotSweeper();
        }
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, address proposer, address sweeper) external initializer {
        // Initialize inheritance chain
        __Ownable_init();
        __UUPSUpgradeable_init();

        // Deploy timelock and transfer ownership to it
        transferOwnership(address(new ClimberTimelock(admin, proposer)));

        _setSweeper(sweeper);
        _updateLastWithdrawalTimestamp(block.timestamp);
    }

    // Allows the owner to send a limited amount of tokens to a recipient every now and then
    function withdraw(address token, address recipient, uint256 amount) external onlyOwner {
        if (amount > WITHDRAWAL_LIMIT) {
            revert InvalidWithdrawalAmount();
        }

        if (block.timestamp <= _lastWithdrawalTimestamp + WAITING_PERIOD) {
            revert InvalidWithdrawalTime();
        }

        _updateLastWithdrawalTimestamp(block.timestamp);

        SafeTransferLib.safeTransfer(token, recipient, amount);
    }

    // Allows trusted sweeper account to retrieve any tokens
    function sweepFunds(address token) external onlySweeper {
        SafeTransferLib.safeTransfer(token, _sweeper, IERC20(token).balanceOf(address(this)));
    }

    function getSweeper() external view returns (address) {
        return _sweeper;
    }

    function _setSweeper(address newSweeper) private {
        _sweeper = newSweeper;
    }

    function getLastWithdrawalTimestamp() external view returns (uint256) {
        return _lastWithdrawalTimestamp;
    }

    function _updateLastWithdrawalTimestamp(uint256 timestamp) private {
        _lastWithdrawalTimestamp = timestamp;
    }

    // By marking this internal function with `onlyOwner`, we only allow the owner account to authorize an upgrade
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner { }
}
