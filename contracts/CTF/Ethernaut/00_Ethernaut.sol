// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts-v4.7.3/access/Ownable.sol";

abstract contract Level is Ownable {
    function createInstance(address _player) public payable virtual returns (address);
    function validateInstance(address payable _instance, address _player) public virtual returns (bool);
}

contract Ethernaut is Ownable {
    // ----------------------------------
    // Owner interaction
    // ----------------------------------

    mapping(address player => bool isRegistered) private registeredLevels;

    // Only registered levels will be allowed to generate and validate level instances.
    function registerLevel(Level _level) public onlyOwner {
        registeredLevels[address(_level)] = true;
    }

    // ----------------------------------
    // Get/submit level instances
    // ----------------------------------

    struct EmittedInstanceData {
        address player;
        Level level;
        bool completed;
    }

    mapping(address instance => EmittedInstanceData instanceData) private emittedInstances;

    event LevelInstanceCreatedLog(address indexed player, address instance);
    event LevelCompletedLog(address indexed player, Level level);

    function createLevelInstance(Level _level) public payable returns (address) {
        // Ensure level is registered.
        require(registeredLevels[address(_level)], "level is not registered");

        // Get level factory to create an instance.
        address instance = _level.createInstance{ value: msg.value }(msg.sender);

        // Store emitted instance relationship with player and level.
        emittedInstances[instance] = EmittedInstanceData(msg.sender, _level, false);

        // Retrieve created instance via logs.
        emit LevelInstanceCreatedLog(msg.sender, instance);

        return instance; // Return data - not possible to read emitted events via solidity
    }

    function submitLevelInstance(address payable _instance) public returns (bool) {
        // Get player and level.
        EmittedInstanceData storage data = emittedInstances[_instance];
        require(data.player == msg.sender, "Caller is not player"); // instance was emitted for this player
        require(data.completed == false, "Exploit is not attack completed."); // not already submitted

        // Have the level check the instance.
        if (data.level.validateInstance(_instance, msg.sender)) {
            // Register instance as completed.
            data.completed = true;

            // Notify success via logs.
            emit LevelCompletedLog(msg.sender, data.level);

            return true; // Return data - not possible to read emitted events
        }

        return false; // Return data - not possible to read emitted events via solidity
    }
}
