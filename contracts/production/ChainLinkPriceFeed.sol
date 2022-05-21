//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../abstract/AMM.sol";

contract ChainLinkPriceFeed {
    mapping(Tokens => address) public tokenPriceProxyAddress;

    constructor() {
        tokenPriceProxyAddress[
            Tokens.ETH
        ] = 0x7f8847242a530E809E17bF2DA5D2f9d2c4A43261;
        tokenPriceProxyAddress[
            Tokens.DAI
        ] = 0xa18B00759bF7659Ad47d618734c8073942faFdEc;
        tokenPriceProxyAddress[
            Tokens.SNX
        ] = 0x38D2f492B4Ef886E71D111c592c9338374e1bd8d;
    }

    function getPriceTokenInEth(Tokens token) public view returns (int256) {
        int256 decimals = int256(10 ** uint256(8));

        int256 ethUsd = getTokenPrice(Tokens.ETH);
        int256 tokenUsd = getTokenPrice(token);
        int256 tokenInEth = (tokenUsd * decimals) / ethUsd;
        require(false, Strings.toString(uint256(tokenInEth)));

        // Scaled up with 10^8, need to be scaled down again.
        return tokenInEth;
    }

    function getTokenPrice(Tokens token) public view returns (int256) {
        require(
            tokenPriceProxyAddress[token] != address(0x0),
            'Invalid address'
        );
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            tokenPriceProxyAddress[token]
        );

        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }
}
