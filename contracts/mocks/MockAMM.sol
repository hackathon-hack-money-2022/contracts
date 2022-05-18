//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../abstract/AMM.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {MockBTC} from "./MockBTC.sol";
import {MockLTC} from "./MockLTC.sol";
import {MockToken} from "./MockToken.sol";
import "forge-std/console.sol";

/*
    This has to be changed, but it works for now.
 */
contract MockAMM is AMM {
    mapping(Tokens => uint256) prices;
    mapping(Tokens => MockToken) tokens;

    MockBTC mockBTC;
    MockLTC mockLTC;

    constructor(MockBTC _mockBTC, MockLTC _mockLTC) {
        mockBTC = _mockBTC;
        mockLTC = _mockLTC;

        tokens[Tokens.BTC] = mockBTC;
        tokens[Tokens.LTC] = mockLTC;
    }

    function swap(
        Tokens fromToken,
        Tokens toToken,
        uint256 amount
    ) public payable override returns (uint256) {
        /* 
        This mocking is incomplete, missing
            - ERC20 transfer logic.
            - Should enforce balance check of swap from token.
            - Should use x * y = z formula to simulate Uniswap
        */
        if (fromToken == Tokens.ETH) {
            tokens[toToken].mint(address(msg.sender), amount * prices[toToken]);
        } else if (fromToken != Tokens.ETH) {
            uint256 price = prices[fromToken];
            uint256 burnToken = amount / price;

            tokens[fromToken].burn(msg.sender, burnToken);
            payable(address(msg.sender)).send(amount * price);
        } else {
            revert("not implemented");
        }

        return 0;
    }

    function setPrice(uint256 _price, Tokens token) public {
        // set the price in ETH
        prices[token] = _price;
    }

    function getLatestPrice(Tokens token)
        public
        view
        override
        returns (uint256)
    {
        return prices[token];
    }

    function getLatestHoldingPrice(Tokens token)
        public
        view
        override
        returns (uint256)
    {
        if (token == Tokens.BTC) {
            return prices[token] * mockBTC.balanceOf(msg.sender);
        } else if (token == Tokens.LTC) {
            return prices[token] * mockLTC.balanceOf(msg.sender);
        } else {
            revert("Error");
        }
    }
}
