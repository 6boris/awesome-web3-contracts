// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library MerkleProof {
    function verifyProof(bytes32 leaf, bytes32 root, bytes32[] memory proof) external pure returns (bool) {
        bytes32 currentHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            currentHash = _hash(currentHash, proof[i]);
        }
        return currentHash == root;
    }

    function _hash(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}

interface IDistributor {
    function withdraw(bytes calldata params, bytes32[] calldata proof) external;
    function root() external view returns (bytes32);
    function hasClaimed(address account) external view returns (bool);
}

contract Distributor is IDistributor {
    bytes32 public root;
    mapping(address => bool) public hasClaimed;

    constructor(bytes32 _root) payable {
        root = _root;
    }

    function withdraw(bytes calldata params, bytes32[] calldata proof) external {
        require(params.length == 64, "invalid params");

        bytes32 leaf = keccak256(params);
        require(MerkleProof.verifyProof(leaf, root, proof), "invalid proof");

        (address recipient, uint72 amount, uint184 validUntil) = decodeParams(params);

        require(!hasClaimed[recipient], "already claimed");
        require(validUntil >= block.timestamp, "expired");

        hasClaimed[recipient] = true;
        (bool success,) = recipient.call{ value: amount }("");
        require(success, "failed to send ether");
    }

    function decodeParams(bytes memory params) private pure returns (address, uint72, uint184) {
        bytes32 first;
        bytes32 second;

        assembly {
            first := mload(add(params, 0x20))
            second := mload(add(params, 0x40))
        }

        address recipient = address(uint160(uint256(first)));
        uint72 amount = uint72(uint256(second) >> 184);
        uint184 validUntil = uint184(uint256(second) >> 72);

        return (recipient, amount, validUntil);
    }
}
