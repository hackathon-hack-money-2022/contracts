interface ICustomUniswapPool {
    /**
        https://github.com/Uniswap/v3-core/blob/234f27b9bc745eee37491802aa37a0202649e344/contracts/UniswapV3Pool.sol#L91
            - should be possible to call balance0
                - NOO this uses the token balance -> should not be used ref. https://stackoverflow.com/a/71815432
        https://github.com/Uniswap/v3-sdk/issues/42
            - https://docs.uniswap.org/protocol/concepts/V3-overview/oracle#optimism
                - OH NO!!!! :(
     */

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (
            int56[] memory tickCumulatives,
            uint160[] memory secondsPerLiquidityCumulativeX128s
        );
}
