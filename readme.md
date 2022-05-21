## Rebalancer - contracts
[Rebalancer is an application taking inspiration from the now shutdown Prism exchange](https://github.com/hackathon-hack-money-2022/.github/blob/main/profile/README.md)

In this repository is the core component of the Rebalancer application. It's the contracts that pools the capital together to allow more efficient Rebalancing of portfolios[1], and keeps users exposure to assets constant.

[1] Since not every users don't have to pay gas fees. The gas fee is paid once for rebalancing all users portfolios.

# How does it work ? 
1. User deposit ETH into the application and gives the application an "portfolio" they want to keep constant. For instance an user can deposit 1 ETH and say they want it to be 50% in DAI and 50% in SNX. 
2. The protocol will initialize the portfolio.
3. When users are "done" with the portfolio they can withdraw, and get the ETH back (not supported yet - first point of future work).

# Future work
Did not have as much time as I wanted for this project (worked all day - tried to work on this at night), so sadly I did not have enough time to complete all the things I wanted :(

Here are a list of a few features that should be added for the application to be "complete" (mvp)

- Complete the application, i.e add support for withdraw :) 
- Add some standard scaling constant of numbers to make the math safer.
- Add some fuzzing logic for the rebalancing logic, is it safe ? I wrote it in one go, so probably there is some arithmetic error there.
- Add some protection against slippages!!
- Make things more capital efficient. 
- Use an AMM oracle since that is more trustless and cooler
- Integrate other protocols, not just AMMs
    - We could integrate with compound and allow users to put an percentage of all rebalances into a "savings" account. This could be useful in case of an market drop.
    - Integrate with some options protocols to allow users rebalance short positions. This would allow users to hedge more easily within the portocol.
