// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
//import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/IV3SwapRouter.sol";
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestUniswap {
    uint256 amountIn = 20;

    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    IV3SwapRouter public uniswapRouter = IV3SwapRouter(UNISWAP_ROUTER_ADDRESS);

    function hello() public payable {
  //      uint256 deadline = block.timestamp + 100000;
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
            tokenIn: 0x4200000000000000000000000000000000000006,
            tokenOut: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1,
            recipient: msg.sender,
            fee: 3000,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        uniswapRouter.exactInputSingle{value: amountIn}(
            params//params
        );
        /*
        bytes memory transferPayload = abi.encodeWithSignature("exactInputSingle((address,address,uint24,address,uint256,uint256,uint160))",
            0x4200000000000000000000000000000000000006,
            0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1,
            0x48dB0a2E700c3A80d9b183ffF942d7c20F5d5632,
            20,
            0,
            0
        );
        */
        /*
        address(UNISWAP_ROUTER_ADDRESS).call{gas :10000, value: amountIn}(transferPayload);
    */
//        payable(address(UNISWAP_ROUTER_ADDRESS)).transferPayload()
    }

    function testDeposit() public payable {
        require(msg.value > 0, 'failed deposti');
    }
}


import '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol';

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface IV3SwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @dev Setting `amountIn` to 0 will cause the contract to look up its own balance,
    /// and swap the entire amount, enabling contracts to send tokens before calling this function.
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @dev Setting `amountIn` to 0 will cause the contract to look up its own balance,
    /// and swap the entire amount, enabling contracts to send tokens before calling this function.
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// that may remain in the router after the swap.
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// that may remain in the router after the swap.
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}