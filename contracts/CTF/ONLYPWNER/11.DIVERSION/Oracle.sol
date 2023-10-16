// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IOracle } from "./interfaces/IOracle.sol";

/// @dev For now, this is just an admin oracle.
/// @dev At some point, this will be made more decentralized.
contract Oracle is IOracle {
    address public owner;
    uint256 public vulToWethPrice;

    constructor() {
        owner = msg.sender;
    }

    /// @dev In practice, this will be called by the owner of the contract
    /// @dev and pinned to the WETH-VUL pair on Uniswap.
    function setVulToWethPrice(uint256 _price) external {
        require(msg.sender == owner, "Oracle: Only owner can set price");
        vulToWethPrice = _price;
    }
}
