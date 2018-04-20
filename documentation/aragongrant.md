
# Aragon Nest Proposal: Decentralized Market for Datafeed Oracles Adjudicated by Aragon Court System 

## Abstract

Ethereum Oracles traditionally are a point of centralization, undermining the trustless and censorship-resistant nature of the blockchain. The offchain and often human-driven nature of oracles also limits contract design. Ideally, a smart contract should be able to dip into a stream of constantly updated data in order to execute based on external conditions. For instance, an insurance contract that can release funds when a change in financial markets occurs without direct human oversight.
I believe I've found the solution in the form of a decentralized oracle market, regulated by carefully constructed game theory. The solution will both provide a necessary boost to the Ethereum ecosystem and provide a solid, continuous use case for the Aragon Court System.

### How it works demonstrated by an example use case
Suppose you wish to construct a smart contract that accepts ether deposits but only releases ether for withdrawal when the USD Ether price is above $5000.
You register your desired data feed with a special smart contract that holds important criteria for would be oracles: 
``` 
{
FeedName: ETHUSD, 
Description: Ether price in US dollars, 
Precision: 2, 
RegularityPer100blocks: 90, 
marginOfError: 0.1
}
``` 
The feed above will get a unique ID. You can now design your smart contract to reference the unique FeedID requesting the latest data.
In order to get a regular feed, you issue a bounty that will be paid to whoever is willing and able to supply the data. The bounty will have a reward denominated in ether or an ERC20 token. The bounty also specifies the starting block for when the feed should commence and the number of blocks the feed should last.
Anyone can bid for the bounty. Bidding is done through an auction contract. Each bid displaces the previous bid. For instance, oracle1 spots a bounty and bids 1 eth. The 1 eth is locked. oracle2 places 2eth for the same bounty. Oracle1's deposit is now released for withdrawal.
Auctioning for top spot carries on for some period (probably a week) after which bidding ends. The winning oracle must now supply the feed starting from the initial block for the duration. The bid amount will now be staked (skin in the game) for the duration of the feed and some time after. From here, the winner of the above auction will be refered to as the chosen oracle.

After the bounty period ends, there is a week in which any user can contest the results supplied by the chosen oracle. If the feed is contested, the plaintiff places a deposit equal in size to the deposit placed by the chosen oracle. At this point, the Aragon Court System is activated. The judges will deliberate over whether the data was accurate to within the required margin of error and if it was delivered with the correct frequency. If so, the plaintiff will lose the deposit as per the court system rules. Else, the bounty is released for the oracle to withrdraw.

### Caveats: 
1. The type of data best suited to this system is a continuous stream of numeric data such as financial market data and perhaps is not best suited for all scenarios.
2. Accuracy can only be guaranteed with the existence of an active 'citizenry' monitoring and punishing bad actor oracles. There are post release plans to broaden the active ecosystem but that is beyond the scope of this proposal.
3. A continuous onchain stream might bloat the main chain. A potential future upgrade will be to move this onto a side chain as demonstrated by the Loom Network or perhaps if the native protol permits, post Casper. However, this isn't a concern until the number of different feeds exceeds 100.

## Deliverables

    1. An ether only version with a simplified court system, live on a test net.
    2. An ERC20 aware version on a test net that plugs into the Aragon Court System.
    3. A live and mature web of contracts on the main net.
    4. A decent front end single page app that provides an easy to navigate workflow for users who have metamask but who don't want to think of anything under the hood. Specifically, would be oracles should not need any knowledge of Ethereum beyond being able to use a wallet.
    Bonus: 
    5. A sufficiently generic set of legal primitives to allow users to "bring their own legal system", allowing Aragon to act as an "International Court" of last resort. This would help with Aragon's desire to foster a Cambrian Explosion of legal systems.

## Grant size

Funding: $7k per month for 12 months paid in Ether.

Success reward: Up to $50k in ANT, given out when all non bonus deliverables are ready.


## Application requirements

- **Proof of Existence**: This doesn't just exist in theory but has evolved from an ongoing open source project of mine found at https://github.com/gititGoro/Pythia. The currently active branch is "judiciary". I raise this point of evidence to illustrate that I am well aware of the limitations and challenges of programming to the EVM and have found the ongoing Aragon and Zeppelin research illuminating. It should also illustrate  that I use rigirous testing principles and hold my code to enterprise standards. Please forgive 1 or 2 tests that aren't currently passing. I wanted to nip this opportunity in the bud, rather than wait until I'd reached perfection.
- For the duration of the grant, I would be the only team member. I plan to live frugally and any savings will be used to outsource UX as and when necessary since UX is not my strength. However, in the early stages, this would not necessitate a full time front end professional working with me.
- Estimated average burn rate for completing the deliverables: Although software estimation is a fools game, I imagine conservatively that each deliverable will take 3 months with sufficient testing and accounting for re-writes and show stopping bugs (found before production of course). Combining any necessary outsourcing with hardware purchases would bring the estimated monthly burn to around $7k initially, tapering in the middle and then picking up near the end to possibly more than $7.5k. I will endeavour to smooth out consumption conservatively
- Legal structure to be adopted: I will be acting as a sole proprietor, operating under my name in the country I reside in (South Africa). I foresee no legal or regulatory roadblocks in my jurisdiction as the state has adopted a very relaxed attitude toward cryptocurrencies but if the need arises, I will relocate to the island state of Mauritius which has adopted a pro cryptocurrency stance, dubbing themselves Ethereum Island and ranking consistently in the top 20 economically most free nations. The standard of living is similar in both so the funding requirements will not change and the project not halted.



## Development timeline

The development timeline will be the following one in regards to each deliverable:

1. Sep 2018
2. December 2018
3. Feb 2019 
4. Feb 2019 (4 would run concurrently with 3)
5. (Bonus, optional) some time in 2019. I'm hoping at this point to pull in open source contributors attracted by the ideal of orthogonal legal primitives. 


## Proof that I have a good grasp of cryptoeconomics
I would refer you to my medium blog where I have a number of pieces illustrating my grasp of cryptoeconomics and ability to project complex scenarios. I will list a few examples below: 
1. https://medium.com/social-evolution/blockchains-will-save-us-from-a-i-ec366be62a95
2. https://medium.com/social-evolution/a-minimum-viable-disc-how-to-make-a-ubi-in-the-age-of-blockchain-8ef1bd984be7
3. https://medium.com/social-evolution/the-economics-of-lightning-network-fees-76f0926da82
4. https://medium.com/@justingoro/a-blockchain-solution-for-international-amazon-deliveries-3616690717ac