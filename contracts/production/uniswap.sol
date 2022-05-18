//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../abstract/AMM.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";
//import "uniswap-v2-periphery/interfaces/IUniswapV2Router02.sol";
import {ISwapRouter} from "v3-periphery/interfaces/ISwapRouter.sol";
import 'v3-periphery/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

/*
    This has to be changed, but it works for now.
 */
contract UniswapAMM is AMM {
    ISwapRouter public uniswapRouter;
    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;

    function swap(
        Tokens fromToken,
        Tokens toToken,
        uint256 amount
    ) public payable override returns (uint256) {
        // https://docs.uniswap.org/protocol/guides/swaps/single-swaps


        uint256 deadline = block.timestamp + 15;
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
            tokenIn: 0x4200000000000000000000000000000000000006,
            tokenOut: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1,
            fee: 3000,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: amount,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        uniswapRouter.exactInputSingle(
            params
        );
        return 0;
    }

    function getLatestPrice(Tokens token)
        public
        view
        override
        returns (uint256)
    {
        return 0;
    }

    function getLatestHoldingPrice(Tokens token)
        public
        view
        override
        returns (uint256)
    {
        return 0;
    }
}

struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
//    uint24 fee;
    address recipient;
//    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
}