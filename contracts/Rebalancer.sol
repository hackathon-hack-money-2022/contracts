//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {AMM, Tokens} from "./abstract/AMM.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Rebalancer {
    // Deposited amount with total exposure in ETH
    uint256 public btcDeposit;
    uint256 public ltcDeposit;

    AMM amm;

    mapping(address => PortfolioT0[]) public portfolioT0;

    constructor(AMM _amm) {
        amm = _amm;
    }

    function deposit(Portfolio memory portfolio)
        public
        payable
        returns (uint256)
    {
        require(portfolio.btc + portfolio.ltc == 100);
        require(0 < msg.value);

        uint8 numberOfAssets = 0;

        uint256 senderBtcDeposit = (portfolio.btc * msg.value) / 100;
        uint256 newBtcDeposit = btcDeposit + senderBtcDeposit;

        uint256 senderLTcDeposit = (portfolio.ltc * msg.value) / 100;
        uint256 newLtcDeposit = ltcDeposit + senderLTcDeposit;

        // TODO: This could just be a function call, is that cheaper ?
        if (0 < portfolio.btc) {
            numberOfAssets++;
        }
        if (0 < portfolio.ltc) {
            numberOfAssets++;
        }

        /**
            To adjust the percentages we need to see how much this new capital
            affects the already deposited capital (bit tricky).
        */
        amm.swap{value: senderBtcDeposit}(
            Tokens.ETH,
            Tokens.BTC,
            senderBtcDeposit
        );
        amm.swap{value: senderLTcDeposit}(
            Tokens.ETH,
            Tokens.LTC,
            senderLTcDeposit
        );

        portfolioT0[msg.sender].push(
            PortfolioT0({
                btc: amm.getLatestPrice(Tokens.BTC),
                ltc: amm.getLatestPrice(Tokens.LTC),
                ethDeposit: msg.value,
                portfolio: portfolio,
                numberOfAssets: numberOfAssets
            })
        );

        btcDeposit = newBtcDeposit;
        ltcDeposit = newLtcDeposit;

        return msg.value;
    }

    function rebalance() public {
        // output should be price in ETH
        uint256 newBtcPrice = ERC20(amm.getTokenAddress(Tokens.BTC)).balanceOf(
            address(this)
        ) * amm.getLatestPrice(Tokens.BTC);
        uint256 newLtcPrice = ERC20(amm.getTokenAddress(Tokens.LTC)).balanceOf(
            address(this)
        ) * amm.getLatestPrice(Tokens.LTC);

        uint256 newTotalPrice = newBtcPrice + newLtcPrice;

        uint256 totalPriceDeposit = btcDeposit + ltcDeposit;

        uint256 btcRatio = (((newBtcPrice * 100) / ((newTotalPrice))));
        uint256 btcWantedRatio = (((btcDeposit * 100) / (totalPriceDeposit)));

        // hardcoded for now
        if (btcWantedRatio < btcRatio) {
            // TODO: Make this a variable tracked by the smart contract
            uint256 coinExposure = 1;
            uint256 ethChunks = ((newBtcPrice * (btcRatio - btcWantedRatio)) /
                100) / coinExposure;

            // TODO: THis should update the exposure to the assets.
            // Because of the value increase, we have more in both BTC and LTC.
            amm.swap(Tokens.BTC, Tokens.ETH, ethChunks);
            amm.swap{value: this.getBalance()}(
                Tokens.ETH,
                Tokens.LTC,
                ethChunks
            );

            btcDeposit = newBtcPrice - ethChunks;
            ltcDeposit = ltcDeposit + ethChunks;
        }
    }

    function withdraw(uint256 portfolioIndex) public returns (uint256) {
        PortfolioT0 storage portfolio = portfolioT0[msg.sender][portfolioIndex];
        uint256 deposited = portfolio.ethDeposit;
        int256 deltaBtc = getAdjustedDelta(
            amm.getLatestPrice(Tokens.BTC),
            portfolio.btc
        );
        int256 deltaLtc = getAdjustedDelta(
            amm.getLatestPrice(Tokens.LTC),
            portfolio.ltc
        );

        int256 deltaExposure = deltaBtc;
        uint256 uDeltaExposure = (
            deltaExposure < 0 ? uint256(-deltaExposure) : uint256(deltaExposure)
        ) / portfolio.numberOfAssets;

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

        btcDeposit -= adjustedBtc;
        ltcDeposit -= adjustedLtc;

        amm.swap(Tokens.BTC, Tokens.ETH, adjustedBtc);
        amm.swap(Tokens.LTC, Tokens.ETH, adjustedLtc);

        return adjustedBtc + adjustedLtc;
    }

    function getAdjustedDelta(uint256 currentPrice, uint256 entryPrice)
        private
        pure
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
    ) private pure returns (uint256) {
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
    uint8 numberOfAssets;
    uint256 btc;
    uint256 ltc;
    Portfolio portfolio;
}
