//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/console.sol";
import {AMM, Tokens} from "../abstract/AMM.sol";
import {UniswapAMM} from "../production/Uniswap.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract IntegrationTestAMM {
    UniswapAMM amm;

    constructor() {
        amm = new UniswapAMM();
    }

    function swap() public payable {
        //        amm.swap{value: msg.value}(Tokens.ETH, Tokens.DAI, msg.value);
        amm.swap{value: msg.value}(
            Tokens.DAI,
            Tokens.ETH,
            10000000000000000000
        );
    }

    function deposit() public payable {
        require(msg.value > 0, "no deposit ser ?");
    }

    function approve() public payable {
        address addr = amm.tokenAddress(Tokens.DAI);

        require(
            ERC20(addr).approve(address(amm), 20000000000000000000) == true,
            "failed increase allowance"
        );
    }
}
