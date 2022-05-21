//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract AMM {
    function swap(
        Tokens fromToken,
        Tokens toToken,
        uint256 amount
    ) public payable virtual returns (uint256);

    function getLatestPrice(Tokens token)
        public
        virtual
        returns (uint256, int8);

    function getTokenAddress(Tokens token) public virtual returns (address);
}

enum Tokens {
    ETH,
    DAI,
    SNX
}
