// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { Level } from "./00_Ethernaut.sol";

contract Fallout {
    using Math for uint256;

    mapping(address account => uint256 balance) private allocations;
    address payable public owner;

    function Fal1out() public payable {
        owner = payable(msg.sender); // Type issues must be payable address
        allocations[owner] = msg.value;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function allocate() public payable {
        (, allocations[msg.sender]) = allocations[msg.sender].tryAdd(msg.value);
    }

    function sendAllocation(address payable allocator) public {
        require(allocations[allocator] > 0, "not have enough balance");
        allocator.transfer(allocations[allocator]);
    }

    function collectAllocations() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance); // Type issues must be payable address
    }

    function allocatorBalance(address allocator) public view returns (uint256) {
        return allocations[allocator];
    }
}

contract FalloutFactory is Level {
    function createInstance(address _player) public payable override returns (address) {
        _player;
        Fallout instance = new Fallout();
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) public view override returns (bool) {
        Fallout instance = Fallout(_instance);
        return instance.owner() == _player;
    }
}
