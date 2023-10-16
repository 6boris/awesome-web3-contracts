// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPetition {
    function initialize() external;
    function signSupport(Signature calldata signature) external;
    function signReject(Signature calldata signature) external;
    function finishPetition() external;
    function owner() external view returns (address);
    function isFinished() external view returns (bool);
    function supportDigest() external view returns (bytes32);
    function rejectDigest() external view returns (bytes32);

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct StoragePointer {
        uint256 value;
    }

    event Signed(address indexed signer, bool isSupport);
}

contract Petition is IPetition {
    address public override owner;
    bool public isFinished;

    bytes32 public override supportDigest;
    bytes32 public override rejectDigest;

    function initialize() external override {
        require(owner == address(0), "Already initialized");
        owner = msg.sender;

        string memory toSignSupport = "I support the cause!";
        bytes32 hashSupport = keccak256(abi.encodePacked(toSignSupport));
        supportDigest = toEthSignedMessageHash(hashSupport);

        string memory toSignReject = "I reject the cause!";
        bytes32 hashReject = keccak256(abi.encodePacked(toSignReject));
        rejectDigest = toEthSignedMessageHash(hashReject);
    }

    function signSupport(Signature calldata signature) external override {
        require(!isFinished, "Petition is finished");
        address signer = ecrecover(supportDigest, signature.v, signature.r, signature.s);
        writeStatus(signer, true);
    }

    function signReject(Signature calldata signature) external override {
        require(!isFinished, "Petition is finished");
        address signer = ecrecover(rejectDigest, signature.v, signature.r, signature.s);
        writeStatus(signer, false);
    }

    function finishPetition() external override {
        require(msg.sender == owner, "Only owner can finish petition");
        isFinished = true;
    }

    function writeStatus(address signer, bool isSupport) private {
        StoragePointer storage pointer;
        bytes32 slot = bytes32(uint256(uint160(signer)));
        assembly {
            pointer.slot := slot
        }

        if (isSupport) {
            pointer.value = 1;
        } else {
            pointer.value = 0;
        }

        emit Signed(signer, isSupport);
    }

    function toEthSignedMessageHash(bytes32 hash) private pure returns (bytes32 result) {
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            result := keccak256(0x00, 0x3c)
        }
    }
}
