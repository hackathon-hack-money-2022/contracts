//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {AMM} from "./abstract/AMM.sol";

contract Hello {
    // Total percentage of the entire contract
    uint256 btcPercentage;
    uint256 ltcPercentage;

    // Deposited amount with total exposure in ETH
    uint256 public btcDeposit;
    uint256 public ltcDeposit;
    uint256 public totalDeposits;

    // Previous ETH -> Token price
    uint256 public previousBtcPrice;
    uint256 public previousLtcPrice;

    AMM amm;

    mapping(address => uint256) public btcExposure;
    mapping(address => uint256) public ltcExposure;

    constructor(AMM _amm) {
        amm = _amm;

        previousBtcPrice = _amm.getLatestPrice("BTC");
        previousLtcPrice = _amm.getLatestPrice("LTC");
    }

    function hello() public pure returns (uint256) {
        return 0;
    }

    function deposit(Portfolio memory portfolio)
        public
        payable
        returns (uint256)
    {
        require(portfolio.btc + portfolio.ltc == 100);

        if (0 < msg.value) {
            /*            uint256 exposureBtc = portfolio.btc * msg.value;
            uint256 exposureLtc = portfolio.ltc * msg.value;
*/
            uint256 senderBtcDeposit = (portfolio.btc * msg.value) / 100;
            uint256 newBtcDeposit = btcDeposit + senderBtcDeposit;

            uint256 senderLTcDeposit = (portfolio.ltc * msg.value) / 100;
            uint256 newLtcDeposit = ltcDeposit + senderLTcDeposit;
            uint256 newTotalDeposits = newBtcDeposit + newLtcDeposit;

            /**
                To adjust the percentages we need to see how much this new capital
                affects the already deposited capital (bit tricky).
            */
            amm.swap{value: senderBtcDeposit}('ETH', 'BTC', senderBtcDeposit);
            amm.swap{value: senderLTcDeposit}('ETH', 'LTC', senderLTcDeposit);

            btcDeposit = newBtcDeposit;
            ltcDeposit = ltcDeposit;
            totalDeposits = newTotalDeposits;

            return msg.value;
        }

        return 0;
    }

    function rebalance() public payable returns (bool) {
        uint256 newBtcPrice = amm.getLatestPrice("BTC");
        uint256 newLtcPrice = amm.getLatestPrice("LTC");

        amm.swap{value: 0}('BTC', 'ETH', 1 ether);

        /*

        */
    }

    function withdraw() public pure returns (uint256) {
        /*
            Based on the user exposure to an asset, and the value changed, we then calculate the 
            winnings.

            Might be a bit more complicated, we will see :)
         */
        revert("Not implemented");
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}

struct Portfolio {
    uint8 btc;
    uint8 ltc;
}
