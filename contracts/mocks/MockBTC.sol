//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import 'openzeppelin-contracts/contracts/token/ERC20/ERC20.sol';

contract MockBTC is ERC20 {
	constructor() ERC20('Bitcoin', 'BTC') {}

	function mint(address target, uint256 amount) public {
		_mint(target, amount);
	}
}
