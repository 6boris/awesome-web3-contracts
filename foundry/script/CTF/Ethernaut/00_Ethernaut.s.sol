// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.9.0;

import { Script } from "@dev/forge-std/Script.sol";

abstract contract EthernautScript is Script {
    /// @dev Included to enable compilation of the script without a $MNEMONIC environment variable.
    string internal constant TEST_MNEMONIC = "test test test test test test test test test test test junk";

    /// @dev Needed for the deterministic deployments.
    bytes32 internal constant ZERO_SALT = bytes32(0);

    /// @dev The address of the transaction broadcaster.
    address internal broadcaster;

    /// @dev Used to derive the broadcaster's address if $ETH_FROM is not defined.
    string internal mnemonic;
    uint256 internal mnemonicAccountIndex;

    /// @dev Initializes the transaction broadcaster like this:
    ///
    /// - If $ETH_FROM is defined, use it.
    /// - Otherwise, derive the broadcaster address from $MNEMONIC.
    /// - If $MNEMONIC is not defined, default to a test mnemonic.
    ///
    /// The use case for $ETH_FROM is to specify the broadcaster key and its address via the command line.
    constructor() {
        address from = vm.envOr({ name: "ETH_FROM", defaultValue: address(0) });
        if (from != address(0)) {
            broadcaster = from;
        } else {
            mnemonic = vm.envOr({ name: "MNEMONIC_DEV", defaultValue: TEST_MNEMONIC });
            mnemonicAccountIndex = vm.envOr({ name: "MNEMONIC_ACCOUNT_INDEX", defaultValue: uint256(0) });
            // uint256 privateKey = vm.deriveKey(mnemonic, uint32(mnemonicAccountIndex));
            broadcaster = vm.addr(vm.deriveKey(mnemonic, uint32(mnemonicAccountIndex)));
        }
    }

    modifier broadcast() {
        vm.startBroadcast(0x7Dd8A1d5C63DB4fDF4C1A303566601158B6EbBA6);
        _;
        vm.stopBroadcast();
    }
}
