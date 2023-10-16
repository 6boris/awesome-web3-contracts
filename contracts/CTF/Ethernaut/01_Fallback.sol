// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { Level } from "./00_Ethernaut.sol";

contract Fallback {
    using Math for uint256;

    mapping(address account => uint256 balance) public contributions;
    address payable public owner;

    constructor() payable {
        owner = payable(msg.sender);
        contributions[msg.sender] = 1000 * (1 ether);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function contribute() public payable {
        require(msg.value < 0.001 ether, "msg.value must be < 0.001"); // Add message with require
        contributions[msg.sender] += msg.value;
        if (contributions[msg.sender] > contributions[owner]) {
            owner = payable(msg.sender); // Type issues must be payable address
        }
    }

    function getContribution() public view returns (uint256) {
        return contributions[msg.sender];
    }

    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    function _fallback() private {
        // naming has switched to fallback
        require(msg.value > 0 && contributions[msg.sender] > 0, "Not have made a contribution"); // Add message with
            // require
        owner = payable(msg.sender); // Type issues must be payable address
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }
}

contract FallbackFactory is Level {
    function createInstance(address _player) public payable override returns (address) {
        _player;
        Fallback instance = new Fallback();
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) public view override returns (bool) {
        Fallback instance = Fallback(_instance);
        return instance.owner() == _player && address(instance).balance == 0;
    }
}
