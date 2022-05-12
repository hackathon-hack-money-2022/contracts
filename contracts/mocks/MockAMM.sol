//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../abstract/AMM.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {MockBTC} from "./MockBTC.sol";
import {MockLTC} from "./MockLTC.sol";

/*
    This has to be changed, but it works for now.
 */
contract MockAMM is AMM {
    mapping(string => uint256) prices;

    MockBTC mockBTC;
    MockLTC mockLTC;

    constructor(MockBTC _mockBTC, MockLTC _mockLTC) {
        mockBTC = _mockBTC;
        mockLTC = _mockLTC;
    }

    function swap(
        string memory fromToken,
        string memory toToken,
        uint256 amount
    ) public payable override returns (uint256) {
        // we mint based on the current price :=)

        if (memcmp(bytes(toToken), bytes("BTC"))) {
            mockBTC.mint(address(msg.sender), prices[toToken] * msg.value);
        } else if (memcmp(bytes(toToken), bytes("LTC"))) {
            mockLTC.mint(address(msg.sender), prices[toToken]);
        } else if (memcmp(bytes(toToken), bytes("ETH"))) {
            if (memcmp(bytes(fromToken), bytes("BTC"))) {
                uint256 balanceEth = amount * this.getLatestPrice(fromToken);
                payable(address(msg.sender)).send(1 ether);
            } else {
                revert("not implemented");
            }
        } else {
            revert("ops");
        }
    }

    function setPrice(uint256 _price, string memory token) public {
        prices[token] = _price;
    }

    function getLatestPrice(string memory token)
        public
        view
        override
        returns (uint256)
    {
        return prices[token];
    }

    function memcmp(bytes memory a, bytes memory b)
        internal
        pure
        returns (bool)
    {
        return (a.length == b.length) && (keccak256(a) == keccak256(b));
    }
}
