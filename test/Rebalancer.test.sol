pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Rebalancer, Portfolio} from "contracts/Rebalancer.sol";
import {MockAMM, Tokens} from "contracts/mocks/MockAMM.sol";
import {MockDAI} from "contracts/mocks/MockDAI.sol";
import {MockSNX} from "contracts/mocks/MockSNX.sol";

contract RebalancerTest is Test {
    Rebalancer rebalancer;
    MockAMM amm;
    MockSNX mockSNX;
    MockDAI mockDAI;

    function setUp() public {
        mockSNX = new MockSNX();
        mockDAI = new MockDAI();

        amm = new MockAMM(mockSNX, mockDAI);
        rebalancer = new Rebalancer(amm);

        // initial price
        amm.setPrice(1, Tokens.DAI, 1);
        amm.setPrice(1, Tokens.SNX, 1);

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

            Initial deposit will make the contract 50% to DAI and 50% to SNX.

            The next deposit will shrink the DAI exposure.

            The exposure to DAI will be 
            (0.5 * 0.5) + (0.25 * 1)

            The exposure to SNX will be 
            (0.5 * 0.5) + (0.75 * 1)  = 1 eth
        */
        assert(
            0 <
                rebalancer.deposit{value: 0.5 ether}(
                    Portfolio({DAI: 50, SNX: 50})
                )
        );
        assert(
            0 <
                rebalancer.deposit{value: 1 ether}(
                    Portfolio({DAI: 25, SNX: 75})
                )
        );

        assert(rebalancer.totalDeposits() <= 1.5 ether);

        assert(rebalancer.SNXDeposit() == 1 ether);
        assert(rebalancer.DAIDeposit() <= 0.5 ether);

        assert(0 < mockDAI.balanceOf(address(rebalancer)));
        assert(0 < mockSNX.balanceOf(address(rebalancer)));
    }

    function testShouldCorrectlyAdjustExposure() public {
        // initial price
        amm.setPrice(1, Tokens.DAI, 1);
        amm.setPrice(1, Tokens.SNX, 1);

        assert(0 < address(amm).balance);
        assert(
            0 <
                rebalancer.deposit{value: 0.5 ether}(
                    Portfolio({DAI: 50, SNX: 50})
                )
        );
        assert(
            0 <
                rebalancer.deposit{value: 1 ether}(
                    Portfolio({DAI: 25, SNX: 75})
                )
        );
        assert(rebalancer.totalDeposits() <= 1.5 ether);

        // Price of SNX doubles, need to rebalance the portfolio!!
        amm.setPrice(2, Tokens.SNX, 1);
        /*
            Our original deposit was 1 ETH in SNX, and 0.5 ETH in DAI.

            Our current position (before rebalance) is 2 ETH in SNX, and 0.5 in DAI.

            We need to rebalance the portfolio to make it balanced again. 
            This means we need to rebalance the exposoure.

            We want to be 0.66% exposed to SNX and 33 % to DAI.
            The new SNX balance should be 1.66 ETH, and new DAI blaance should be 0.825 ETH
        */

        uint256 beforeBalanceSNX = mockSNX.balanceOf(address(rebalancer));
        uint256 beforeBalanceDAI = mockDAI.balanceOf(address(rebalancer));

        uint256 beforeBalanceSNX_ETH = rebalancer.SNXDeposit();
        uint256 beforeBalanceDAI_ETH = rebalancer.DAIDeposit();

        rebalancer.rebalance();
        // we sold some SNX for DAI
        require(mockSNX.balanceOf(address(rebalancer)) < beforeBalanceSNX);
        require(beforeBalanceDAI < mockDAI.balanceOf(address(rebalancer)));
        assert(0 == rebalancer.getBalance());

        // Should update the internal state of the balance, we know have more ETH in the DAI, and same with SNX.
        require(mockSNX.balanceOf(address(rebalancer)) < beforeBalanceSNX);
        require(beforeBalanceSNX_ETH < rebalancer.SNXDeposit());
        require(beforeBalanceDAI_ETH < rebalancer.DAIDeposit());
    }

    function testShouldWithdrawCorrectlySingleUserMarketUp() public {
        /**
            User deposit 1 ETH with exposure to DAI and SNX 50/50.
            SNX goes up 100%
            User should be able to withdraw 1.5 ETH.
         */

        // initial price
        amm.setPrice(100, Tokens.DAI, 1);
        amm.setPrice(100, Tokens.SNX, 1);

        assert(
            0 <
                rebalancer.deposit{value: 1 ether}(
                    Portfolio({DAI: 50, SNX: 50})
                )
        );
        /*
            Balance should now be 1 ETH
            0.5 ETH in SNX
            0.5 ETH in DAI
        */
        amm.setPrice(200, Tokens.SNX, 1);
        /*
            After re-balance the balance should be 1.5 ETH
            0.75 ETH in SNX
            0.75 ETH in DAI
        */

        rebalancer.rebalance();
        uint256 depositBefore = rebalancer.totalDeposits();
        uint256 withdraw = rebalancer.withdraw(0);
        assert(rebalancer.totalDeposits() < depositBefore);
        assert(1.5 ether == withdraw);
    }

    function testShouldWithdrawCorrectlySingleUserMarketDown() public {
        /**
            User deposit 1 ETH with exposure to SNX and DAI 50/50.
            SNX down 50%
            User should be able to withdraw more 0.75 ETH.
         */

        // initial price
        amm.setPrice(100, Tokens.DAI, 1);
        amm.setPrice(100, Tokens.SNX, 1);

        assert(
            0 <
                rebalancer.deposit{value: 1 ether}(
                    Portfolio({DAI: 50, SNX: 50})
                )
        );
        /*
            Balance should now be 1 ETH
            0.5 ETH in SNX
            0.5 ETH in DAI
        */
        amm.setPrice(50, Tokens.SNX, 1);
        rebalancer.rebalance();
        /*
            Balance should now be 0.75 ETH
            0.375 ETH in SNX
            0.375 ETH in DAI
        */
        uint256 depositBefore = rebalancer.totalDeposits();
        uint256 withdraw = rebalancer.withdraw(0);
        assert(rebalancer.totalDeposits() < depositBefore);
        assert(0.75 ether == withdraw);
    }

    function testDepositWithLargerValue() public {
        // initial price, 1$ and 2$ usd with scale 8 and based on current ETH price
        amm.setPrice(50816, Tokens.DAI, 8);
        amm.setPrice(101632, Tokens.SNX, 8);

        assert(
            0 <
                rebalancer.deposit{value: 1 ether}(
                    Portfolio({DAI: 50, SNX: 50})
                )
        );

        // The "flapening" - baby chicken to the moon.
        amm.setPrice(50816 + 500, Tokens.SNX, 8);

        uint256 beforeBalanceSNX = mockSNX.balanceOf(address(rebalancer));
        uint256 beforeBalanceDAI = mockDAI.balanceOf(address(rebalancer));

        uint256 beforeBalanceSNX_ETH = rebalancer.SNXDeposit();
        uint256 beforeBalanceDAI_ETH = rebalancer.DAIDeposit();

        rebalancer.rebalance();

        require(mockSNX.balanceOf(address(rebalancer)) < beforeBalanceSNX);
        require(beforeBalanceDAI < mockDAI.balanceOf(address(rebalancer)));
        assert(0 == rebalancer.getBalance());
    }
}
