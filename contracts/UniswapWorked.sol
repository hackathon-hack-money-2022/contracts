// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import {IV3SwapRouter} from "./interfaces/IV3SwapRouter.sol";
import "@uniswap/v3-core/contracts/UniswapV3Pool.sol";

contract TestUniswap {
    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address internal constant UNISWAP_POOL_TEST = 0x7C473Fea63efA9a3CcFa0f35DC39C727f917bC8c;

    IV3SwapRouter public uniswapRouter = IV3SwapRouter(UNISWAP_ROUTER_ADDRESS);
    UniswapV3Pool public uniswapPool = UniswapV3Pool(UNISWAP_POOL_TEST);

    function hello() public payable {
        uint256 amountIn = 1000000;
        /*
            eth - 0x4200000000000000000000000000000000000006
            Dai - 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1
            Synthetix - 0x0064A673267696049938AA47595dD0B3C2e705A1
         */

        TransferHelper.safeApprove(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1, address(UNISWAP_ROUTER_ADDRESS), amountIn);

        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter
            .ExactInputSingleParams({
 /*               tokenIn: 0x4200000000000000000000000000000000000006,
                tokenOut: 0x0064A673267696049938AA47595dD0B3C2e705A1, // 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1,
*/
               tokenIn: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1,
                tokenOut: 0x4200000000000000000000000000000000000006, // 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1,
                recipient: msg.sender,
                fee: 3000,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        uniswapRouter.exactInputSingle{value: 0}(params);
    }

    function getTokenPrice() public returns (uint256) {
        
    }

    function testDeposit() public payable {
        require(msg.value > 0, "failed deposit");
    }
}
