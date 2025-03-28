// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HigherOrder {
    address public commander;

    uint256 public treasury;

    function registerTreasury(uint8 treasury_slot) public {
        assembly {
            sstore(treasury_slot, calldataload(4))
        }
    }

    function claimLeadership() public {
        if (treasury > 255) commander = msg.sender;
        else revert("Only members of the Higher Order can become Commander");
    }
}
