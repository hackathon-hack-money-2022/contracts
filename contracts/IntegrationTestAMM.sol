//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/console.sol";
import {AMM, Tokens} from "./abstract/AMM.sol";
import {UniswapAMM} from "./production/uniswap.sol";

contract IntegrationTestAMM {
    AMM amm;

    constructor() {
        amm = new UniswapAMM();
    }

    function hello() public {
        amm.swap(Tokens.ETH, Tokens.ETH, 1);
    }
}
