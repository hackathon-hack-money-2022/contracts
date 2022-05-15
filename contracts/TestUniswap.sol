//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {AMM, Tokens} from "./abstract/AMM.sol";
import {UniswapAMM} from "./production/uniswap.sol";
import "forge-std/console.sol";

contract TestUniswap {
    AMM amm;

    constructor() {
        amm = new UniswapAMM();
    }

    function call() public  {
        amm.swap(
            Tokens.ETH,
            Tokens.ETH,
            1
        );
    }
}
