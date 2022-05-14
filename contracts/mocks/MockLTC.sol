//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "./MockToken.sol";

contract MockLTC is MockToken {
    constructor() ERC20("Litecoin", "LTC") {}

    function mint(address target, uint256 amount) public override {
        _mint(target, amount);
    }

    function burn(address target, uint256 amount) public override {
        _burn(target, amount);
    }
}
