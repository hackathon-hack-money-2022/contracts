# Contracts


### Links
- [] https://kovan-optimistic.etherscan.io/address/0x5ee99870b0bfaaa76ff583659e66afe10c783383
    - Address of the "owner"

### Foundry
- https://book.getfoundry.sh/cheatcodes/deal.html?highlight=deal(#deal

### Uniswap
- https://docs.uniswap.org/protocol/reference/deployments
- https://docs.uniswap.org/protocol/reference/periphery/SwapRouter
- https://kovan-optimistic.etherscan.io/address/0x68b3465833fb72a70ecdf485e0e4c7bd8665fc45#code
    - SwapRouter02
- https://soliditydeveloper.com/uniswap2
- https://blockchain.oodles.io/dev-blog/utilizing-the-new-uniswap-v2-in-your-smart-contract/

### Uniswap tx
- https://kovan-optimistic.etherscan.io/tx/0xd7ecf64e0e202fb8708762f5a3e8009d6a58c4308c4a52725e5d210060e5068e
- https://kovan-optimistic.etherscan.io/tx/0x13cf89038ca35c9f05b728f6cee58f231afe6237973fbb63107c3b9729977c0d

#### Problems with uniswap
- https://github.com/Uniswap/solidity-lib/blob/master/contracts/libraries/TransferHelper.sol
    - Somethings fails inside here
    - I have enough liquidity, so not sure what the problem is.
- Got it working when calling it directly to the contract
    - https://kovan-optimistic.etherscan.io/tx/0x9402b8e46cf04da64f77145caea07f8aa15f53da5e06586d648feaa0a2b05c55
    - Tried to deposit ETH into a smart contract and then call it througth it, but it did not work
- Got it working (finally)
    - I think the problem was that the wrong interface was used for the router
        - https://kovan-optimistic.etherscan.io/tx/0x87ee2fc4335d9000818cdb6bd03a98ede6981672cc510559f968bcc4aee2c99b
        
### Rip - the price oracle for uniswap is actually not onchain
- could do something like https://stackoverflow.com/a/71815432
    - Requires user to interact :(
- Never mind should be able to use reserve0/reserve1, but it is on pool level. I think this is ok, but we need to use liquid pool as the oracle.
    - https://github.com/Uniswap/v2-core/blob/master/contracts/UniswapV2Pair.sol
    
