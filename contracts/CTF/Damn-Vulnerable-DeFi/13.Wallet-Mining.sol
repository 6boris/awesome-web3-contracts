// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts-v4.7.1/token/ERC20/IERC20.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable-v4.7.1/proxy/utils/Initializable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable-v4.7.1/access/OwnableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable-v4.7.1/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title AuthorizerUpgradeable
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AuthorizerUpgradeable is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    mapping(address => mapping(address => uint256)) private wards;

    event Rely(address indexed usr, address aim);

    function init(address[] memory _wards, address[] memory _aims) external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();

        for (uint256 i = 0; i < _wards.length;) {
            _rely(_wards[i], _aims[i]);
            unchecked {
                i++;
            }
        }
    }

    function _rely(address usr, address aim) private {
        wards[usr][aim] = 1;
        emit Rely(usr, aim);
    }

    function can(address usr, address aim) external view returns (bool) {
        return wards[usr][aim] == 1;
    }

    function upgradeToAndCall(address imp, bytes memory wat) external payable override {
        _authorizeUpgrade(imp);
        _upgradeToAndCallUUPS(imp, wat, true);
    }

    function _authorizeUpgrade(address imp) internal override onlyOwner { }
}

interface IGnosisSafeProxyFactory {
    function createProxy(address masterCopy, bytes calldata data) external returns (address);
}

/**
 * @title  WalletDeployer
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 * @notice A contract that allows deployers of Gnosis Safe wallets (v1.1.1) to be rewarded.
 *         Includes an optional authorization mechanism to ensure only expected accounts
 *         are rewarded for certain deployments.
 */
contract WalletDeployer {
    // Addresses of the Gnosis Safe Factory and Master Copy v1.1.1
    IGnosisSafeProxyFactory public constant fact = IGnosisSafeProxyFactory(0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B);
    address public constant copy = 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F;

    uint256 public constant pay = 1 ether;
    address public immutable chief = msg.sender;
    address public immutable gem;

    address public mom;

    error Boom();

    constructor(address _gem) {
        gem = _gem;
    }

    /**
     * @notice Allows the chief to set an authorizer contract.
     * Can only be called once. TODO: double check.
     */
    function rule(address _mom) external {
        if (msg.sender != chief || _mom == address(0) || mom != address(0)) {
            revert Boom();
        }
        mom = _mom;
    }

    /**
     * @notice Allows the caller to deploy a new Safe wallet and receive a payment in return.
     *         If the authorizer is set, the caller must be authorized to execute the deployment.
     * @param wat initialization data to be passed to the Safe wallet
     * @return aim address of the created proxy
     */
    function drop(bytes memory wat) external returns (address aim) {
        aim = fact.createProxy(copy, wat);
        if (mom != address(0) && !can(msg.sender, aim)) {
            revert Boom();
        }
        IERC20(gem).transfer(msg.sender, pay);
    }

    // TODO(0xth3g450pt1m1z0r) put some comments
    function can(address u, address a) public view returns (bool) {
        assembly {
            let m := sload(0)
            if iszero(extcodesize(m)) { return(0, 0) }
            let p := mload(0x40)
            mstore(0x40, add(p, 0x44))
            mstore(p, shl(0xe0, 0x4538c4eb))
            mstore(add(p, 0x04), u)
            mstore(add(p, 0x24), a)
            if iszero(staticcall(gas(), m, p, 0x44, p, 0x20)) { return(0, 0) }
            if and(not(iszero(returndatasize())), iszero(mload(p))) { return(0, 0) }
        }
        return true;
    }
}
