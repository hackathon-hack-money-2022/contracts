//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {AMM, Tokens} from "./abstract/AMM.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Rebalancer {
    // Deposited amount with total exposure in ETH
    uint256 public SNXDeposit;
    uint256 public DAIDeposit;

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
        require(portfolio.SNX + portfolio.DAI == 100);
        require(0 < msg.value);

        uint8 numberOfAssets = 0;

        uint256 senderSnxDeposit = (portfolio.SNX * msg.value) / 100;
        uint256 newSnxDeposit = SNXDeposit + senderSnxDeposit;

        uint256 senderDAIDeposit = (portfolio.DAI * msg.value) / 100;
        uint256 newDAIDeposit = DAIDeposit + senderDAIDeposit;

        // TODO: This could just be a function call, is that cheaper ?
        if (0 < portfolio.SNX) {
            numberOfAssets++;
        }
        if (0 < portfolio.DAI) {
            numberOfAssets++;
        }

        /**
            To adjust the percentages we need to see how much this new capital
            affects the already deposited capital (bit tricky).
        */
        amm.swap{value: senderSnxDeposit}(
            Tokens.ETH,
            Tokens.SNX,
            senderSnxDeposit
        );
        amm.swap{value: senderDAIDeposit}(
            Tokens.ETH,
            Tokens.DAI,
            senderDAIDeposit
        );

        portfolioT0[msg.sender].push(
            PortfolioT0({
                SNX: getLatestPrice(Tokens.SNX),
                DAI: getLatestPrice(Tokens.DAI),
                ethDeposit: msg.value,
                portfolio: portfolio,
                numberOfAssets: numberOfAssets
            })
        );

        SNXDeposit = newSnxDeposit;
        DAIDeposit = newDAIDeposit;

        return msg.value;
    }

    function rebalance() public {
        // output should be price in ETH
        uint256 newSnxPrice = ERC20(amm.getTokenAddress(Tokens.SNX)).balanceOf(
            address(this)
        ) * getLatestPrice(Tokens.SNX);
        uint256 newDAIPrice = ERC20(amm.getTokenAddress(Tokens.DAI)).balanceOf(
            address(this)
        ) * getLatestPrice(Tokens.DAI);

        uint256 newTotalPrice = newSnxPrice + newDAIPrice;

        uint256 totalPriceDeposit = SNXDeposit + DAIDeposit;

        uint256 SnxRatio = (((newSnxPrice * 100) / ((newTotalPrice))));
        uint256 SnxWantedRatio = (((SNXDeposit * 100) / (totalPriceDeposit)));

        // hardcoded for now
        if (SnxWantedRatio < SnxRatio) {
            // TODO: Make this a variable tracked by the smart contract
            uint256 coinExposure = 1;
            uint256 ethChunks = ((newSnxPrice * (SnxRatio - SnxWantedRatio)) /
                100) / coinExposure;

            // TODO: THis should update the exposure to the assets.
            // Because of the value increase, we have more in both SNX and DAI.
            amm.swap(Tokens.SNX, Tokens.ETH, ethChunks);
            amm.swap{value: this.getBalance()}(
                Tokens.ETH,
                Tokens.DAI,
                ethChunks
            );

            SNXDeposit = newSnxPrice - ethChunks;
            DAIDeposit = DAIDeposit + ethChunks;
        }
    }

    function withdraw(uint256 portfolioIndex) public returns (uint256) {
        PortfolioT0 storage portfolio = portfolioT0[msg.sender][portfolioIndex];
        uint256 deposited = portfolio.ethDeposit;
        int256 deltaSnx = getAdjustedDelta(
            getLatestPrice(Tokens.SNX),
            portfolio.SNX
        );
        int256 deltaDAI = getAdjustedDelta(
            getLatestPrice(Tokens.DAI),
            portfolio.DAI
        );

        int256 deltaExposure = deltaSnx;
        uint256 uDeltaExposure = (
            deltaExposure < 0 ? uint256(-deltaExposure) : uint256(deltaExposure)
        ) / portfolio.numberOfAssets;

        uint256 adjustedSnx = getAdjustedAmount(
            deposited,
            portfolio.SNX,
            portfolio.portfolio.SNX,
            uDeltaExposure,
            deltaExposure < 0
        );

        uint256 adjustedDAI = getAdjustedAmount(
            deposited,
            portfolio.DAI,
            portfolio.portfolio.DAI,
            uDeltaExposure,
            deltaExposure < 0
        );

        SNXDeposit -= adjustedSnx;
        DAIDeposit -= adjustedDAI;

        amm.swap(Tokens.SNX, Tokens.ETH, adjustedSnx);
        amm.swap(Tokens.DAI, Tokens.ETH, adjustedDAI);

        return adjustedSnx + adjustedDAI;
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

    function getLatestPrice(Tokens token) private returns (uint256) {
        (uint256 price, int8 scale) = amm.getLatestPrice(token);

        return price;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function totalDeposits() public view returns (uint256) {
        return SNXDeposit + DAIDeposit;
    }
}

struct Portfolio {
    uint8 SNX;
    uint8 DAI;
}

struct PortfolioT0 {
    uint256 ethDeposit;
    uint8 numberOfAssets;
    uint256 SNX;
    uint256 DAI;
    Portfolio portfolio;
}
