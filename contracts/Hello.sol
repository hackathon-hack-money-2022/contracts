//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {AMM} from "./abstract/AMM.sol";
import "forge-std/console.sol";

contract Hello {
    // Total percentage of the entire contract
    uint256 btcPercentage;
    uint256 ltcPercentage;

    // Deposited amount with total exposure in ETH
    uint256 public btcDeposit;
    uint256 public ltcDeposit;
    //    uint256 public totalDeposits;

    /*
    // Previous ETH -> Token price
    uint256 public previousBtcPrice;
    uint256 public previousLtcPrice;
*/
    AMM amm;

    mapping(address => uint256) public btcExposure;
    mapping(address => uint256) public ltcExposure;

    constructor(AMM _amm) {
        amm = _amm;
        /*
        previousBtcPrice = _amm.getLatestPrice("BTC");
        previousLtcPrice = _amm.getLatestPrice("LTC");
*/
    }

    function hello() public pure returns (uint256) {
        return 0;
    }

    function deposit(Portfolio memory portfolio)
        public
        payable
        returns (uint256)
    {
        console.log(address(this));
        console.log(msg.value);
        console.log(address(this).balance);

        require(portfolio.btc + portfolio.ltc == 100);
        require(0 < msg.value);
        /*            uint256 exposureBtc = portfolio.btc * msg.value;
        uint256 exposureLtc = portfolio.ltc * msg.value;
*/
        uint256 senderBtcDeposit = (portfolio.btc * msg.value) / 100;
        uint256 newBtcDeposit = btcDeposit + senderBtcDeposit;

        uint256 senderLTcDeposit = (portfolio.ltc * msg.value) / 100;
        uint256 newLtcDeposit = ltcDeposit + senderLTcDeposit;

        console.log("ltc");
        console.log(newLtcDeposit);
        console.log(newBtcDeposit);

        uint256 newTotalDeposits = newBtcDeposit + newLtcDeposit;

        /**
            To adjust the percentages we need to see how much this new capital
            affects the already deposited capital (bit tricky).
        */
        amm.swap{value: senderBtcDeposit}("ETH", "BTC", senderBtcDeposit);
        amm.swap{value: senderLTcDeposit}("ETH", "LTC", senderLTcDeposit);

        btcDeposit = newBtcDeposit;
        ltcDeposit = newLtcDeposit;
        // totalDeposits = newTotalDeposits;

        return msg.value;
    }

    function rebalance() public payable returns (bool) {
        // output should be price in ETH
        uint256 newBtcPrice = amm.getLatestPrice("BTC");
        uint256 newLtcPrice = amm.getLatestPrice("LTC");

        uint256 btcRatio = (((newBtcPrice * 100) /
            ((newLtcPrice + newBtcPrice))) * 100);
        uint256 btcWantedRatio = (((btcDeposit * 100) /
            (btcDeposit + ltcDeposit)) * 100);
        /*
        console.log('===============');

        console.log(newBtcPrice);
        console.log(newLtcPrice);

        console.log(btcRatio);
        console.log(btcWantedRatio);
*/
        // hardcoded for now
        if (btcWantedRatio < btcRatio) {
            // TODO: Make this a variable tracked by the smart contract
            uint256 coinExposure = 1;
            uint256 ethChunks = ((newBtcPrice * (btcRatio - btcWantedRatio)) /
                10000) / coinExposure;

            amm.swap("BTC", "ETH", ethChunks);
            amm.swap{value: this.getBalance()}("ETH", "LTC", ethChunks);
        }
    }

    function withdraw() public pure returns (uint256) {
        /*
            Based on the user exposure to an asset, and the value changed, we then calculate the 
            winnings.

            Might be a bit more complicated, we will see :)
         */
        revert("Not implemented");
    }

    function getBalance() public view returns (uint256) {
        console.log(address(this));
        return address(this).balance;
    }

    function totalDeposits() public view returns (uint256) {
        return btcDeposit + ltcDeposit;
    }
}

struct Portfolio {
    uint8 btc;
    uint8 ltc;
}
