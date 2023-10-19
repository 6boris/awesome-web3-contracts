// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20Snapshot, ERC20 } from "@openzeppelin/contracts-v4.7.1/token/ERC20/extensions/ERC20Snapshot.sol";

/**
 * @title DamnValuableTokenSnapshot
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract DamnValuableTokenSnapshot is ERC20Snapshot {
    uint256 private _lastSnapshotId;

    constructor(uint256 initialSupply) ERC20("DamnValuableToken", "DVT") {
        _mint(msg.sender, initialSupply);
    }

    // @audit-issue no access control, anyone can take a snapshot
    function snapshot() public returns (uint256 lastSnapshotId) {
        lastSnapshotId = _snapshot();
        _lastSnapshotId = lastSnapshotId;
    }

    function getBalanceAtLastSnapshot(address account) external view returns (uint256) {
        return balanceOfAt(account, _lastSnapshotId);
    }

    function getTotalSupplyAtLastSnapshot() external view returns (uint256) {
        return totalSupplyAt(_lastSnapshotId);
    }
}
