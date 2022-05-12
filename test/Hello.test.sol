pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Hello, Portfolio} from "contracts/Hello.sol";
import {MockAMM} from "contracts/mocks/MockAMM.sol";
import {MockLTC} from "contracts/mocks/MockLTC.sol";
import {MockBTC} from "contracts/mocks/MockBTC.sol";

contract HelloTest is Test {
    Hello hello;
    MockAMM amm;
    MockBTC mockBTC;
    MockLTC mockLTC;

    function setUp() public {
        mockBTC = new MockBTC();
        mockLTC = new MockLTC();

        amm = new MockAMM(mockBTC, mockLTC);
        hello = new Hello(amm);

        // initial price
        amm.setPrice(1, "LTC");
        amm.setPrice(1, "BTC");

        // This is a simple AMM, so we just deposit some ETH
        Test.deal(address(amm), 10000 ether);
        
    }

    function testDeposit() public {
        Test.deal(address(this), 1 ether);
        assert(0 < hello.deposit{value: 0.05 ether}(Portfolio(50, 50)));
      //  Test.warp(1);
        assert(0 < hello.getBalance());
    }

    function testUpdateExposure() public {
        /*
            The exposure should now be adjusted 

            The total capital in the smart contract will be 1.5 ETH.

            Initial deposit will make the contract 50% to LTC and 50% to BTC.

            The next deposit will shrink the LTC exposure.

            The exposure to LTC will be 
            (0.5 * 0.5) + (0.25 * 1)

            The exposure to BTC will be 
            (0.5 * 0.5) + (0.75 * 1)  = 1 eth
        */
        assert(
            0 < hello.deposit{value: 0.5 ether}(Portfolio({ltc: 50, btc: 50}))
        );
        assert(
            0 < hello.deposit{value: 1 ether}(Portfolio({ltc: 25, btc: 75}))
        );

        assert(hello.totalDeposits() <= 1.5 ether);

        assert(hello.btcDeposit() == 1 ether);

        assert(hello.ltcDeposit() <= 0.5 ether);
        assert(0 < mockLTC.balanceOf(address(hello)));
        assert(0 < mockBTC.balanceOf(address(hello)));
    }

    function testShouldCorrectlyAdjustExposure() public {
        assert(
            0 < hello.deposit{value: 0.5 ether}(Portfolio({ltc: 50, btc: 50}))
        );
        assert(
            0 < hello.deposit{value: 1 ether}(Portfolio({ltc: 25, btc: 75}))
        );

        assert(1 < address(hello).balance);
        assert(hello.totalDeposits() <= 1.5 ether);

        // Price of BTC doubles, need to rebalance the portfolio!!
        amm.setPrice(2, "BTC");
        /*
            Our original deposit was 1 ETH in BTC, and 0.5 ETH in LTC.

            Our current position (before rebalance) is 2 ETH in BTC, and 0.5 in LTC.

            We need to rebalance the portfolio to make it balanced again. 
            This means we need to rebalance the exposoure.

            We want to be 0.66% exposed to BTC and 33 % to LTC.
            The new BTC balance should be 1.66 ETH, and new LTC blaance should be 0.825 ETH
        */
        assert(1 < address(amm).balance);
        //      hello.rebalance();

        //        assert(hello.totalDeposits() <= 2.5 ether);
    }
}
