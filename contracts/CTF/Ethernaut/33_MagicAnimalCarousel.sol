// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import { Level } from "./00_Ethernaut.sol";

contract MagicAnimalCarousel {
    uint16 public constant MAX_CAPACITY = type(uint16).max;
    uint256 constant ANIMAL_MASK = uint256(type(uint80).max) << 160 + 16;
    uint256 constant NEXT_ID_MASK = uint256(type(uint16).max) << 160;
    uint256 constant OWNER_MASK = uint256(type(uint160).max);

    uint256 public currentCrateId;
    mapping(uint256 crateId => uint256 animalInside) public carousel;

    error AnimalNameTooLong();

    constructor() {
        carousel[0] ^= 1 << 160;
    }

    function setAnimalAndSpin(string calldata animal) external {
        uint256 encodedAnimal = encodeAnimalName(animal) >> 16;
        uint256 nextCrateId = (carousel[currentCrateId] & NEXT_ID_MASK) >> 160;

        require(encodedAnimal <= uint256(type(uint80).max), AnimalNameTooLong());
        carousel[nextCrateId] = (carousel[nextCrateId] & ~NEXT_ID_MASK) ^ (encodedAnimal << 160 + 16)
            | ((nextCrateId + 1) % MAX_CAPACITY) << 160 | uint160(msg.sender);

        currentCrateId = nextCrateId;
    }

    function changeAnimal(string calldata animal, uint256 crateId) external {
        address owner = address(uint160(carousel[crateId] & OWNER_MASK));
        if (owner != address(0)) {
            require(msg.sender == owner);
        }
        uint256 encodedAnimal = encodeAnimalName(animal);
        if (encodedAnimal != 0) {
            // Replace animal
            carousel[crateId] = (encodedAnimal << 160) | (carousel[crateId] & NEXT_ID_MASK) | uint160(msg.sender);
        } else {
            // If no animal specified keep same animal but clear owner slot
            carousel[crateId] = (carousel[crateId] & (ANIMAL_MASK | NEXT_ID_MASK));
        }
    }

    function encodeAnimalName(string calldata animalName) public pure returns (uint256) {
        require(bytes(animalName).length <= 12, AnimalNameTooLong());
        return uint256(bytes32(abi.encodePacked(animalName)) >> 160);
    }
}

contract MagicAnimalCarouselFactory is Level {
    function createInstance(address _player) public payable override returns (address) {
        _player;
        MagicAnimalCarousel magicAnimalCarousel = new MagicAnimalCarousel();
        return address(magicAnimalCarousel);
    }

    function validateInstance(address payable _instance, address _player) public override returns (bool) {
        _player;
        MagicAnimalCarousel instance = MagicAnimalCarousel(_instance);
        // Store a goat in the box
        string memory goat = "Goat";
        instance.setAnimalAndSpin(goat);

        // Goat should be mutated
        uint256 currentCrateId = instance.currentCrateId();
        uint256 animalInBox = instance.carousel(currentCrateId) >> 176;
        uint256 goatEnc = uint256(bytes32(abi.encodePacked(goat))) >> 176;
        return animalInBox != goatEnc;
    }
}
