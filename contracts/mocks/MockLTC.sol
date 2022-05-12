//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import 'openzeppelin-contracts/contracts/token/ERC20/ERC20.sol';

contract MockLTC is ERC20 {
    constructor() ERC20("Litecoin", "LTC") {}

    function mint(address target, uint256 amount) public {
        _mint(target, amount);
    }
}
