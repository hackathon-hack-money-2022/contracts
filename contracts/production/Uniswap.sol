//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../abstract/AMM.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";
//import "uniswap-v2-periphery/interfaces/IUniswapV2Router02.sol";
import {IV3SwapRouter} from "../interfaces/IV3SwapRouter.sol";
import "v3-periphery/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

/*
    This has to be changed, but it works for now.
 */
contract UniswapAMM is AMM {
    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;

    IV3SwapRouter public uniswapRouter = IV3SwapRouter(UNISWAP_ROUTER_ADDRESS);

    mapping(Tokens => address) public tokenAddress;

    constructor() {
        tokenAddress[Tokens.DAI] = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
        tokenAddress[Tokens.SNX] = 0x0064A673267696049938AA47595dD0B3C2e705A1;
        tokenAddress[Tokens.ETH] = 0x4200000000000000000000000000000000000006;
    }

    function swap(
        Tokens fromToken,
        Tokens toToken,
        uint256 amount
    ) public payable override returns (uint256) {
        // https://docs.uniswap.org/protocol/guides/swaps/single-swaps
        /*
            Todo:
            - Should add some proper protection here. We should try to protect the contract
            from having huge slippages on the swap.
        */
        require(
            tokenAddress[fromToken] != address(0x0),
            "Expected an from token address"
        );
        require(
            tokenAddress[toToken] != address(0x0),
            "Expected an to token address"
        );

        bool isNotFromETH = fromToken != Tokens.ETH;

        if (isNotFromETH) {
            TransferHelper.safeTransferFrom(
                tokenAddress[fromToken],
                msg.sender,
                address(this),
                amount
            );
        }

        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenAddress[fromToken],
                tokenOut: tokenAddress[toToken],
                fee: 3000,
                recipient: msg.sender,
                amountIn: isNotFromETH ? amount : msg.value,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        uint256 sentAmount = isNotFromETH ? 0 : msg.value;
  //     uniswapRouter.exactInputSingle{value: sentAmount}(params);

        return 0;
    }

    function getLatestPrice(Tokens token)
        public
        pure
        override
        returns (uint256)
    {
        require(
            false,
            "This is not supported yet, hopefully in a close future it will be"
        );
        return 0;
    }

    function getTokenAddress(Tokens token)
        public
        pure
        override
        returns (address)
    {
        require(false, "not implemented, but should be accessible");
        return UNISWAP_ROUTER_ADDRESS;
    }
}
