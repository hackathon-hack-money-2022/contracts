/*pragma solidity ^0.8.0;

import "forge-std/console.sol";
import {AMM, Tokens} from "./abstract/AMM.sol";
import {UniswapAMM} from "./production/uniswap.sol";
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract TestUniswap {
    ISwapRouter public uniswapRouter;
    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;

    function hello() public {
        uint256 amountIn = 256;
        // something fails inis
      //  TransferHelper.safeTransferFrom(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1, msg.sender, address(this), amountIn);
    }

    function setAllowance() public {
        ERC20(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1).approve(address(this), 250);
    }
}

/*

 */

/*
contract TestUniswap {
    AMM amm;

    constructor() {
        amm = new UniswapAMM();
    }

    function hello() public  {
        amm.swap(
            Tokens.ETH,
            Tokens.ETH,
            1
        );
    }
}
*/