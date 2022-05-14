//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {AMM} from "./abstract/AMM.sol";
import "forge-std/console.sol";

contract Rebalancer {
    // Total percentage of the entire contract
    uint256 btcPercentage;
    uint256 ltcPercentage;

    // Deposited amount with total exposure in ETH
    uint256 public btcDeposit;
    uint256 public ltcDeposit;

    AMM amm;

    mapping(address => PortfolioT0[]) public portfolioT0;

    constructor(AMM _amm) {
        amm = _amm;
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
        require(0 < msg.value);

        uint256 senderBtcDeposit = (portfolio.btc * msg.value) / 100;
        uint256 newBtcDeposit = btcDeposit + senderBtcDeposit;

        uint256 senderLTcDeposit = (portfolio.ltc * msg.value) / 100;
        uint256 newLtcDeposit = ltcDeposit + senderLTcDeposit;

        uint256 newTotalDeposits = newBtcDeposit + newLtcDeposit;

        /**
            To adjust the percentages we need to see how much this new capital
            affects the already deposited capital (bit tricky).
        */
        amm.swap{value: senderBtcDeposit}("ETH", "BTC", senderBtcDeposit);
        amm.swap{value: senderLTcDeposit}("ETH", "LTC", senderLTcDeposit);

        portfolioT0[msg.sender].push(
            PortfolioT0({
                btc: amm.getLatestPrice("BTC"),
                ltc: amm.getLatestPrice("LTC"),
                ethDeposit: msg.value,
                portfolio: portfolio
            })
        );

        btcDeposit = newBtcDeposit;
        ltcDeposit = newLtcDeposit;

        return msg.value;
    }

    function rebalance() public payable returns (bool) {
        // output should be price in ETH
        uint256 newBtcPrice = amm.getLatestHoldingPrice("BTC");
        uint256 newLtcPrice = amm.getLatestHoldingPrice("LTC");

        uint256 btcRatio = (((newBtcPrice * 100) /
            ((newLtcPrice + newBtcPrice))) * 100);
        uint256 btcWantedRatio = (((btcDeposit * 100) /
            (btcDeposit + ltcDeposit)) * 100);

        // hardcoded for now
        if (btcWantedRatio < btcRatio) {
            // TODO: Make this a variable tracked by the smart contract
            uint256 coinExposure = 1;
            uint256 ethChunks = ((newBtcPrice * (btcRatio - btcWantedRatio)) /
                10000) / coinExposure;

            // TODO: THis should update the exposoure to the assets.
            // Because of the value increase, we have more in both BTC and LTC.
            amm.swap("BTC", "ETH", ethChunks);
            amm.swap{value: this.getBalance()}("ETH", "LTC", ethChunks);

            btcDeposit = newBtcPrice - ethChunks;
            ltcDeposit = ltcDeposit + ethChunks;
        }
    }

    function withdraw(uint256 portfolioIndex) public returns (uint256) {
        /*
            Based on the user exposure to an asset, and the value changed, we then calculate the 
            winnings.

            Might be a bit more complicated, we will see :)
         */
        //revert("Not implemented");
        /**
            t_0 = buy 1 BTC for 1 ETH
            t_1 = price of BTC goes to 2
            t_2 = you want to withdraw 2 ETH
            

            I guess this is a bit more tricky, one thing we could do is issue some 
            token to more easily keep track of the portfolio value maybe.

            
            -> 
         */
        // TODO: This should be a variable when creating the portfolio
        uint256 numberOfCoins = 2;

        PortfolioT0 storage portfolio = portfolioT0[msg.sender][portfolioIndex];
        uint256 deposited = portfolio.ethDeposit;
        /*        uint256 deltaBtc = getAdjustedDelta(
            amm.getLatestPrice("BTC"),
            portfolio.btc
        );*/

        int256 deltaBtc = getAdjustedDelta(
            amm.getLatestPrice("BTC"),
            portfolio.btc
        );
        int256 deltaLtc = getAdjustedDelta(
            amm.getLatestPrice("LTC"),
            portfolio.ltc
        );

        int256 deltaExposure = deltaBtc / 2;
        uint256 uDeltaExposure = deltaExposure < 0
            ? uint256(-deltaExposure)
            : uint256(deltaExposure);

        uint256 adjustedBtc = getAdjustedAmount(
            deposited,
            portfolio.btc,
            portfolio.portfolio.btc,
            uDeltaExposure,
            deltaExposure < 0
        );

        uint256 adjustedLtc = getAdjustedAmount(
            deposited,
            portfolio.ltc,
            portfolio.portfolio.ltc,
            uDeltaExposure,
            deltaExposure < 0
        );
        console.log(adjustedLtc);

        btcDeposit -= adjustedBtc;
        ltcDeposit -= adjustedLtc;

        amm.swap("BTC", "ETH", adjustedBtc);
        amm.swap("LTC", "ETH", adjustedLtc);

        return adjustedBtc + adjustedLtc;
    }

    function getAdjustedDelta(uint256 currentPrice, uint256 entryPrice)
        private
        view
        returns (int256)
    {
        if (entryPrice <= currentPrice) {
            return int256(((currentPrice - entryPrice) * 100) / entryPrice);
        } else {
            return -int256(((currentPrice * 100) / entryPrice));
        }
    }

    function getAdjustedAmount(
        uint256 deposited,
        uint256 assetEntryPrice,
        uint256 assetEntryExposure,
        uint256 deltaExposure,
        bool isNegativeDelta
    ) private returns (uint256) {
        if (isNegativeDelta) {
            return
                ((((deposited * (assetEntryPrice - deltaExposure))) / 100) *
                    assetEntryExposure) / 100;
        }
        return
            ((((deposited * (assetEntryPrice + deltaExposure))) / 100) *
                assetEntryExposure) / 100;
    }

    function getBalance() public view returns (uint256) {
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

struct PortfolioT0 {
    uint256 ethDeposit;
    uint256 btc;
    uint256 ltc;
    Portfolio portfolio;
}
