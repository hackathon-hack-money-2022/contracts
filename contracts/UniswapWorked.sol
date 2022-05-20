// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

//import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
//import {OracleLibrary} from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import {IV3SwapRouter} from "./interfaces/IV3SwapRouter.sol";
import {ICustomUniswapPool} from "./interfaces/ICustomUniswapPool.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

contract TestUniswap {
    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address internal constant UNISWAP_POOL_TEST =
        0x100bdC1431A9b09C61c0EFC5776814285f8fB248;

    //  IV3SwapRouter public uniswapRouter = IV3SwapRouter(UNISWAP_ROUTER_ADDRESS);

    //    OracleLibrary oracle = OracleLibrary(UNISWAP_ROUTER_ADDRESS);

    //  UniswapV3Pool public uniswapPool = UniswapV3Pool(UNISWAP_POOL_TEST);

    function hello2() public payable {
        uint256 amountIn = 1000000;
        /*
            eth - 0x4200000000000000000000000000000000000006
            Dai - 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1
            Synthetix - 0x0064A673267696049938AA47595dD0B3C2e705A1
         */
        /*
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter
            .ExactInputSingleParams({
                tokenIn: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1,
                tokenOut: 0x4200000000000000000000000000000000000006,
                recipient: msg.sender,
                fee: 3000,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        uniswapRouter.exactInputSingle{value: 0}(params);
        */
    }

    function hello() public returns (uint256) {
        ICustomUniswapPool ref = ICustomUniswapPool(UNISWAP_POOL_TEST);

        uint32[] memory secondsAgo = new uint32[](2);
        secondsAgo[0] = 1800;
        secondsAgo[1] = 0;

        (
            int56[] memory tickCumulatives,
            uint160[] memory secondsPerLiquidityCumulativeX128s
        ) = ref.observe(secondsAgo);

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
        uint160 secondsPerLiquidityCumulativesDelta = secondsPerLiquidityCumulativeX128s[
                1
            ] - secondsPerLiquidityCumulativeX128s[0];

        uint256 test = uint256(uint112(int112((tickCumulativesDelta))));
        uint256 test2 = uint256(secondsPerLiquidityCumulativesDelta);

        //        uint256 secondsPerLiquidityCumulativesDeltaInt = (test / test2); //uint256(tickCumulativesDelta - 0);// / secondsPerLiquidityCumulativesDelta);

        //      int24 arithmeticMeanTick = int24(tickCumulativesDelta / secondsAgo);
        // Always round to negative infinity
        //        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgo != 0)) arithmeticMeanTick--;

        // We are multiplying here instead of shifting to ensure that harmonicMeanLiquidity doesn't overflow uint128
        //      uint192 secondsAgoX160 = uint192(secondsAgo) * type(uint160).max;
        //        uint128 harmonicMeanLiquidity = uint128(secondsAgoX160 / (uint192(secondsPerLiquidityCumulativesDelta) << 32));
        //
        //     int256 price = int256(tickCumulativesDelta) / (secondsPerLiquidityCumulativesDelta);
        require(
            false,
            string(
                abi.encodePacked(
                    Strings.toString(test),
                    " ",
                    "and",
                    " ",
                    Strings.toString(test2)
                )
            )
        );

        return 10;
    }

    function testDeposit() public payable {
        require(msg.value > 0, "failed deposit");
    }
}
