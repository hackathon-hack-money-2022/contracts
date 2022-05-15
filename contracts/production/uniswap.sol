//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../abstract/AMM.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";
import "uniswap-v2-periphery/interfaces/IUniswapV2Router02.sol";

/*
    This has to be changed, but it works for now.
 */
contract UniswapAMM is AMM {
    IUniswapV2Router02 public uniswapRouter;
    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;

    function swap(
        Tokens fromToken,
        Tokens toToken,
        uint256 amount
    ) public payable override returns (uint256) {
        uint256 deadline = block.timestamp + 15;

        uniswapRouter.swapExactTokensForTokens(
            10,
            10,
            getPathForETHtoDAI(),
            0x5eE99870B0bfaaA76Ff583659e66AfE10C783383,
            deadline
        );
        return 0;
    }

    function getPathForETHtoDAI() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
        path[1] = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;

        return path;
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
