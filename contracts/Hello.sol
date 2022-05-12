//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Hello {
    function hello() public pure returns (uint256) {
        return 0;
    }

    function deposit() public payable returns (uint256) {
        if (0 < msg.value) {
            return msg.value;
        }
        return 0;
    }
}
