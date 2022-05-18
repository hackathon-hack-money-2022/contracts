//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

abstract contract MockToken is ERC20 {
    function mint(address target, uint256 amount) public virtual;

    function burn(address target, uint256 amount) public virtual;
}
