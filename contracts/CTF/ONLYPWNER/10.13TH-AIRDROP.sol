// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAirdrop {
    function claim(address recipient) external;
    function addRecipient(address recipient) external payable;
    function balances(address who) external view returns (uint256);
}

contract Airdrop is IAirdrop {
    mapping(address => uint256) public balances;
    uint256 private savedContractBalance;
    bool private entered = false;

    constructor() { }

    // Only EOAs can interact with this contract for security reasons.
    modifier notContract(address who) {
        uint256 size;
        assembly {
            size := extcodesize(who)
        }
        require(size == 0, "Contracts not allowed");
        _;
    }

    // To be extra safe, we still use a reentrancy guard.
    modifier nonReentrant() {
        require(!entered, "ReentrancyGuard: reentrant call");
        entered = true;
        _;
        entered = false;
    }

    function claim(address recipient) external notContract(recipient) {
        savedContractBalance = address(this).balance;

        require(!entered, "ReentrancyGuard: reentrant call");
        entered = true;
        (bool success,) = msg.sender.call{ value: balances[msg.sender] }("");
        require(success, "Transfer failed.");
        // No reentrancy opportunity from here on.
        entered = false;

        updateUserBalance();
    }

    function addRecipient(address recipient) external payable nonReentrant notContract(recipient) {
        balances[recipient] += msg.value;
    }

    function updateUserBalance() internal {
        // This will get called quite often
        // so we implement the expensive logic in assembly.
        assembly {
            function checkFunds(originalUserBalance, originalContractBalance) -> newUserBalance {
                /// @dev In case we add fee-on-transfer tokens at some point
                let expectedBalance := sub(originalContractBalance, originalUserBalance)
                if iszero(gt(balance(address()), expectedBalance)) {
                    let diff := sub(expectedBalance, balance(address()))
                    newUserBalance := sub(newUserBalance, diff)
                    leave
                }

                return(0, 0)
            }

            mstore(0x0, caller())
            mstore(0x20, 0)
            // Get the balances mapping slot
            let slot := keccak256(0x0, 0x40)
            let originalContractBalance := sload(1)
            let originalUserBalance := sload(slot)

            // Optimistically set it to 0.
            sstore(slot, 0)

            let newUserBalance := checkFunds(originalUserBalance, originalContractBalance)

            // If we had a fee-on-transfer token, set the correct balance.
            // (Not yet implemented)
            sstore(slot, newUserBalance)
        }
    }
}
