//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract AMM {
    function swap(
        string memory fromToken,
        string memory toToken,
        uint256 amount
    ) public payable virtual returns (uint256);

    function getLatestPrice(string memory token)
        public
        virtual
        returns (uint256);

    function getLatestHoldingPrice(string memory token)
        public
        virtual
        returns (uint256);

    /*
    function token0Price() public virtual view returns (uint256);

    function token1Price() public virtual view returns (uint256);
*/
}