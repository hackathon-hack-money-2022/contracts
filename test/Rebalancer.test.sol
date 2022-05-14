pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Rebalancer, Portfolio} from "contracts/Rebalancer.sol";
import {MockAMM} from "contracts/mocks/MockAMM.sol";
import {MockLTC} from "contracts/mocks/MockLTC.sol";
import {MockBTC} from "contracts/mocks/MockBTC.sol";

contract RebalancerTest is Test {
    Rebalancer rebalancer;
    MockAMM amm;
    MockBTC mockBTC;
    MockLTC mockLTC;

    function setUp() public {
        mockBTC = new MockBTC();
        mockLTC = new MockLTC();

        amm = new MockAMM(mockBTC, mockLTC);
        rebalancer = new Rebalancer(amm);

        // initial price
        amm.setPrice(1, "LTC");
        amm.setPrice(1, "BTC");

        // This is a simple AMM, so we just deposit some ETH
        Test.deal(address(amm), 10000 ether);
        assert(0 < address(amm).balance);
    }

    function testDeposit() public {
        Test.deal(address(this), 1 ether);
        assert(0 < rebalancer.deposit{value: 0.05 ether}(Portfolio(50, 50)));
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
            0 <
                rebalancer.deposit{value: 0.5 ether}(
                    Portfolio({ltc: 50, btc: 50})
                )
        );
        assert(
            0 <
                rebalancer.deposit{value: 1 ether}(
                    Portfolio({ltc: 25, btc: 75})
                )
        );

        assert(rebalancer.totalDeposits() <= 1.5 ether);

        assert(rebalancer.btcDeposit() == 1 ether);
        assert(rebalancer.ltcDeposit() <= 0.5 ether);

        assert(0 < mockLTC.balanceOf(address(rebalancer)));
        assert(0 < mockBTC.balanceOf(address(rebalancer)));
    }

    function skipTestShouldCorrectlyAdjustExposure() public {
        // initial price
        amm.setPrice(1, "LTC");
        amm.setPrice(1, "BTC");

        assert(0 < address(amm).balance);
        assert(
            0 <
                rebalancer.deposit{value: 0.5 ether}(
                    Portfolio({ltc: 50, btc: 50})
                )
        );
        assert(
            0 <
                rebalancer.deposit{value: 1 ether}(
                    Portfolio({ltc: 25, btc: 75})
                )
        );
        assert(rebalancer.totalDeposits() <= 1.5 ether);

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

        uint256 beforeBalanceBTC = mockBTC.balanceOf(address(rebalancer));
        uint256 beforeBalanceLTC = mockLTC.balanceOf(address(rebalancer));

        uint256 beforeBalanceBTC_ETH = rebalancer.btcDeposit();
        uint256 beforeBalanceLTC_ETH = rebalancer.ltcDeposit();

        rebalancer.rebalance();

        // we sold some BTC for LTC
        require(mockBTC.balanceOf(address(rebalancer)) < beforeBalanceBTC);
        require(beforeBalanceLTC < mockLTC.balanceOf(address(rebalancer)));
        assert(0 == rebalancer.getBalance());

        // Should update the internal state of the balance, we know have more ETH in the LTC, and same with BTC.
        require(mockBTC.balanceOf(address(rebalancer)) < beforeBalanceBTC);
        require(beforeBalanceBTC_ETH < rebalancer.btcDeposit());
        require(beforeBalanceLTC_ETH < rebalancer.ltcDeposit());
    }

    function testShouldWithdrawCorrectlySingleUserMarketUp() public {
        /**
            User deposit 1 ETH with exposure to LTC and BTC 50/50.
            BTC goes up 100%
            User should be able to withdraw 1.5 ETH.
         */

        // initial price
        amm.setPrice(100, "LTC");
        amm.setPrice(100, "BTC");

        assert(
            0 <
                rebalancer.deposit{value: 1 ether}(
                    Portfolio({ltc: 50, btc: 50})
                )
        );
        /*
            Balance should now be 1 ETH
            0.5 ETH in BTC
            0.5 ETH in LTC
        */
        amm.setPrice(200, "BTC");
        rebalancer.rebalance();
        /*
            Balance should now be 1.5 ETH
            0.75 ETH in BTC
            0.75 ETH in LTC
        */
        uint256 depositBefore = rebalancer.totalDeposits();
        uint256 withdraw = rebalancer.withdraw(0);
        assert(rebalancer.totalDeposits() < depositBefore);
        assert(1.5 ether == withdraw);
    }

    function testShouldWithdrawCorrectlySingleUserMarketDown() public {
        /**
            User deposit 1 ETH with exposure to BTC and LTC 50/50.
            BTC down 50%
            User should be able to withdraw more 0.75 ETH.
         */

        // initial price
        amm.setPrice(100, "LTC");
        amm.setPrice(100, "BTC");

        assert(
            0 <
                rebalancer.deposit{value: 1 ether}(
                    Portfolio({ltc: 50, btc: 50})
                )
        );
        /*
            Balance should now be 1 ETH
            0.5 ETH in BTC
            0.5 ETH in LTC
        */
        amm.setPrice(50, "BTC");
        rebalancer.rebalance();
        /*
            Balance should now be 0.75 ETH
            0.375 ETH in BTC
            0.375 ETH in LTC
        */
        uint256 depositBefore = rebalancer.totalDeposits();
        uint256 withdraw = rebalancer.withdraw(0);
        assert(rebalancer.totalDeposits() < depositBefore);
        assert(0.75 ether == withdraw);
    }
}
