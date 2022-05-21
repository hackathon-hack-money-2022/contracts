//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../abstract/AMM.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {MockSNX} from "./MockSNX.sol";
import {MockDAI} from "./MockDAI.sol";
import {MockToken} from "./MockToken.sol";
import "forge-std/console.sol";

/*
    This has to be changed, but it works as a proof of concept.
*/
contract MockAMM is AMM {
    mapping(Tokens => uint256) prices;
    mapping(Tokens => int8) pricesScales;
    mapping(Tokens => MockToken) tokens;

    MockSNX mockSNX;
    MockDAI mockDAI;

    constructor(MockSNX _mockSNX, MockDAI _mockLTC) {
        mockSNX = _mockSNX;
        mockDAI = _mockLTC;

        tokens[Tokens.SNX] = mockSNX;
        tokens[Tokens.DAI] = mockDAI;
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

    function setPrice(uint256 _price, Tokens token, int8 scale) public {
        // set the price in ETH
        prices[token] = _price;
        pricesScales[token] = scale;
    }

    function getLatestPrice(Tokens token)
        public
        view
        override
        returns (uint256, int8)
    {
        return (
            prices[token],
            pricesScales[token]
        );
    }

    function getTokenAddress(Tokens token)
        public
        view
        override
        returns (address)
    {
        return address(tokens[token]);
    }
}
