// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// https://onlypwner.xyz/challenges/3

interface IBridge {
    struct ValidatorInfo {
        uint256 deposit;
        address referrer;
        bytes32 tag;
    }

    function voteForNewRoot(bytes calldata vote) external;
    function registerValidator(address referrer, bytes32 tag) external payable;
    function addAdmin(address admin) external;
    function owner() external view returns (address);
    function admins(uint256) external view returns (address);
    function validators(address) external view returns (ValidatorInfo memory);
    function votedOn(bytes32, address) external view returns (bool);
    function votesFor(bytes32) external view returns (uint256);
    function stateRoot() external view returns (bytes32);

    event ValidatorRegistered(address indexed validator, bytes32 tag);
    event ValidatorUnregistered(address indexed validator);
    event ValidatorActivated(address indexed validator);
    event ValidatorDisabled(address indexed validator);

    event NewStateRoot(bytes32 indexed stateRoot, bytes32 indexed validatorTag);
}

contract Bridge is IBridge {
    address public override owner;
    address[] public override admins;
    mapping(address => ValidatorInfo) private _validators;
    mapping(bytes32 => mapping(address => bool)) public override votedOn;
    mapping(bytes32 => uint256) public override votesFor;
    bytes32 public override stateRoot;

    uint256 constant PREFIX_LENGTH = 0x4 + 0x20 + 0x20;

    modifier onlyValidator() {
        require(_validators[msg.sender].deposit > 0, "Bridge: caller is not a validator");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Bridge: caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function voteForNewRoot(bytes calldata vote) external override onlyValidator {
        (bytes32 newRoot, bool isFor,) = decodeCompressedVote(vote);
        handleNewVote(newRoot, isFor);

        if (isFor) {
            tryActivateStateRoot(newRoot);
        }
    }

    function registerValidator(address referrer, bytes32 tag) external payable override {
        require(msg.value >= 1 ether, "Bridge: insufficient deposit");
        require(_validators[msg.sender].deposit == 0, "Bridge: already registered");

        _validators[msg.sender] = ValidatorInfo({ deposit: msg.value, referrer: referrer, tag: tag });

        emit ValidatorRegistered(msg.sender, tag);
    }

    function addAdmin(address admin) external override onlyOwner {
        admins.push(admin);
    }

    function validators(address validator) external view override returns (ValidatorInfo memory) {
        return _validators[validator];
    }

    function decodeCompressedVote(bytes memory vote) private pure returns (bytes32 newRoot, bool isFor, uint48 ts) {
        require(vote.length <= PREFIX_LENGTH + 0x28, "Bridge: invalid vote length");

        assembly {
            calldatacopy(0x0, PREFIX_LENGTH, calldatasize())
            newRoot := mload(0x0)
            isFor := mload(0x20)
            ts := shr(mload(0x22), 0x20)
        }
    }

    function handleNewVote(bytes32 newRoot, bool isFor) private {
        require(!votedOn[newRoot][msg.sender], "Bridge: validator already voted");
        votedOn[newRoot][msg.sender] = true;

        if (!isFor) {
            return;
        }

        votesFor[newRoot] += _validators[msg.sender].deposit;
    }

    function tryActivateStateRoot(bytes32 root) private {
        ValidatorInfo memory info = _validators[msg.sender];
        address[] memory currentAdmins = getAdmins();

        bool isAdmin = false;
        for (uint256 i = 0; i < currentAdmins.length; i++) {
            if (currentAdmins[i] == msg.sender) {
                isAdmin = true;
                break;
            }
        }

        if (isAdmin || votesFor[root] >= 100 ether) {
            votesFor[root] = 0;
            stateRoot = root;
            emit NewStateRoot(root, info.tag);
        }
    }

    function getAdmins() private view returns (address[] memory result) {
        if (admins.length > 0) {
            result = new address[](admins.length);
            for (uint256 i = 0; i < admins.length; i++) {
                result[i] = admins[i];
            }
        }
    }
}
