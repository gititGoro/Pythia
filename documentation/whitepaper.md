---
title: "Pizza - A Carbohydrate Based Substrate For Tomato Delivery"
date: "May 2017"
author: "Maxwell Ogden, Pizza Enthusiasts Institute"
---

# Abstract

Pizza (@pizza2000identification) is an understudied yet widely utilized implement for delivering in-vivo *Solanum lycopersicum* based liquid mediums in a variety of next-generation mastications studies. Here we describe a de novo approach for large scale *T. aestivum* assemblies based on protein folding that drastically reduces the generation time of the mutation rate.

# Introduction
Smart contracts executing on the Ethereum blockchain have no access to events external to the network. As such they rely on external actors (henceforth oracles) to supply external information to smart contracts. Since smart contracts are trustless and uncensorable by default, introducing a reliance on oracles negates this strength of design, precuding certain classes of use cases from existing. Smart contract developers are currently required to choose between designing robust, trustless but ignorant contracts and aware contracts that are vulnerable to both trust based and censorship attacks through their reliance on oracles.
Since the reliance on external, often human, actors is necessary for a smart contract to access external events, we propose that a market be created which disciplines and decentralizes the supply of oracle data in a manner that protects sources from censorship. Two levels of indirection are required to achieve this. The first is a robust market place of oracles who are require to stake deposits before selling information. The market is regulated by a decentralized, blockchain based judicial system. The second is to establish blockchain feeds which are independent and agnostic of particular sources. For instance, when establishing a feed for the latest Eth/USD price, the feed specifies accuracy and frequency but does not require oracles to reveal their sources. So long as the oracles provide reliable and accurate data, the dispute layer will act to objectively verify the integrity of the data when necessary.

# The Name
The name Pythia refers to a period of divination in Ancient Greece. Pythia was a title given to an Oracle of the god Apollo. The Pythia was a *replacable* figure who would change from generation to generation, selected from a sample of priestesses. As such, though a particular Pythia might leave or die, the institution of Pythia was robust and lasted many centuries. The name itself refers to the monstrous python slain by Apollo and and evokes imagery of a multiheaded beast, with no central point of failure.
While individual Pythia weren't as revered as the Oracle of Delphi, the institution of Pythia was so respected and entrenched that many Greek scholars neglected to explain the term when referencing one. In a similar way, the platform Pythia does not rely on the reputation of esteemed APIs but instead establishes a chain of replacable oracles who are disciplined by the mechanics of the ecosystem to provide a trustworthy institution of blockchain datafeeds. APIs will come and go but Pythia will endure. <https://en.wikipedia.org/wiki/Pythia>

# The Oracle Dilemma <venn diagram>
Ethereum and Bitcoin both require the consensus of nodes in order to establish a verifiable source of truth in the form of a blockchain (white paper). As such, it would be impossible for nodes to include data from a source external to the network and still expect every node to verify the correctness of the data in the time it takes to publish a block. Reaching consensus on an API call requires certain layers of trust and introduces a non deterministic element to the construction of each block. For this reason, smart contracts have no native access to external events. Traditional legal contracts between parties reference external events as a matter of course. Yet, until now, trustless smart contracts have acted on nothing but events internal to the blockchain. This has narrowed the scope of possible smart contract design to a class of internally verifiable use cases such as tradeable tokens. While blockchains have been touted to replace traditional financial and insurance mechanisms, their insulation from the external world hinders the realization of this vision. For instance, a simple insurance contract designed to pay farmers in the event of a flood would require a reliable source of weather. While the funds themselves could be secured by multisignature smart contract design, the source of weather would need to be agreed upon, introducing a source of trust and 3rd party intermediation.

# Stable Coins
The volatility of blockchain tokens has necessitated the need for stable coins, tokens which do not fluctuate wildly when compared to traditional fiat currencies such as the US dollar. The first generations of solutions offered have been to introduce tokens backed by offchain, realworld assets (Digix, Tether). These reserve tokens are vulnerable to censorship attacks through confiscation. The MakerDAO collateralizes all of its assets on chain but the source of price feed is still maintained through a list of trusted oracles. The purpose of Pythia in the stable coin ecosystem will be to replace trusted nodes and oracles with reliable institutions of data flow, independent from the reputation of individual oracles.

Once accurate feed sources are established, smart contracts can be designed which reference the feed by its ID, a value that is invariant over time, unlike a list of ever changing oracles. In time, certain feeds will become so established that they will be treated as ethereum primitives in contract design.

# Passive and Active Oracles
The most common type of oracle in existence is the active oracle, primarily because of its simplicity of design. Here, a smart contract designer exposes a public function which an oracle can trigger at will. For instance, an oracle which releases funds when triggered by a particular user will have a release function exposed. While the smart contract designer may specify that this should only happen when certain real world conditions are met, they have no way of enforcing this.

The second and more indirect type of oracle is the passive oracle. Here, an oracle continuously updates a feed of data on the blockchain. A smart contract can then dip into this feed when needed without alerting the oracle. For instance, suppose an oracle provides and ongoing minute by minute feed of the BTC price in USD. A smart contract is designed to release its funds when the the price falls below $1000. It has a release function. Whenver an actor calls the release function, the smart contract immediately requests the latest price from the BTC price feed contract and acts on it synchronously in the same block.  

In the case of the active oracle, the workload of the oracle scales linearly with the number of smart contracts deployed which rely on it. It has to trigger functions on every contract when an even occurs. The passive oracle need only supply a regular feed remaining ignorant of the number of dependents on its feed. The number of smart contracts relying on that feed can scale without limit.
Pythia establishes a market place of strictly passive oracles.

# Contract Design
When designing a smart contract to rely on a passive oracle, the designer has to establish first that there is a feed which fits their need and secondly that the feed is being updated with desired frequency. Once these 2 traits are established, the contract can be designed without future upgrading necessary. This contrasts with reliance on active oracles which requires constant vigilance on the reliability of oracles.
In the case of Pythia, a feed type such as "USD-BTC price" is given a unique ID which contract designers can use to reference its data. The ID will never change, allowing the desinger to hard code the feed into their design. Pythia allows smart contract developers to outsource the establishment of reliable oracle networks.
Solidy exaple:
```
    address pythiaPredictionsContract;
    mapping (address => uint) etherBalances;

    //USD-BTC feed has an ID of 12 in the Pythia Feed contract
    function ReleaseFunds () public {
        if(PythiaPredictions(pythiaPredictionsContract).getLatestFeed(12) < 1000)
            msg.sender.transfer(etherBalances[msg.sender]);
    } 
``` 

# Game Theory and Source Quality
Once desired feeds are established, would-be oracles can peruse the feed contract for an exhaustive list of every feed. When querying the Feed contract, an oracle might get back a list such as the one below:

```
[
    { 
        FeedID: 1,
        Precision: 2,
        MarginOfError:1,
        Name: "ETHUSD",
        Description: "Real time ether price in U.S. dollars",
        Frequency: 9999990,
        MinumumSuccess:0,
        EpochSpan:2500,
        StartingBlock: 124567
                    
    },
     { 
        FeedID: 3,
        Precision: 0,
        MarginOfError:0,
        Name: "REPS",
        Description: "number of republicans elected to the current House of Representatives",
        Frequency: 10,
        MinumumSuccess:100,
        EpochSpan:2500,
        StartingBlock: 124567
    },
     { 
        FeedID: 11,
        Precision: 2,
        MarginOfError:10,
        Name: "BTCUKP",
        Description: "Bitcoin core price in U.K. pounds",
        Frequency: 999990,
        MinumumSuccess:12,
        EpochSpan:2500,
        StartingBlock: 124567
    }
]
```

### Explanation of Feed List
First it should be noted that each feed has a unique ID, established at the time of registration. The precision property refers to the number of decimal places. Since the EVM does not support floating point variables at the time of writing, all oracle data is feed without decimal places. Clients must perform the necessary adjustment based on the precision value.
Margin of error is invoked only in the case of a dispute. When adjudicating on the accuracy of an oracle's feed, the judiciary will first establish an agreed upon source of truth. After than, if the oracle strayed by less than the margin of error, the feed is considered valid. The participation of oracles in a feed will increase inversely with the margin of error since the risk of penalty is lower but the reliability of the quality of the feed data will suffer as a result. Feed designers must balance these 2 variables to optimize for feed quality and regularity.
The frequency is the number of predictions required per 10 million blocks (approximately 4 years). This number is used by the judiciary to determine if an oracle participated with the expected frequency.
Finally, the MinimumSuccess parameter establishes how many feeds an oracle has successfully contributed to before they may contribute to the current feed. In the early days of Pythia, we expect this value to be zero but as oracles establish their track records, certain feeds can be designed to curate only the most reliable oracles. A cheating oracle can have its reputation slashed to zero by the judiciary.
The last 2 properties will be explained in the subsequent section.

A corrollary of the above design is that popular feeds such as the USD-ETH price can be designed with strict parameters, improving the quality of the information provided. As such, beacon feeds will emerge in the ecoysystem which can be treated as de facto sources of truth for smart contracts. Less popular and more obscure feeds will attract fewer oracles. The reliability of such feeds will be questionably. If the use cases for a particular unpopular feed with lax parameters increase over time, consumers might be tempted to establish a replacement feed with tighter parameters. As such a spectrum of feeds for the same information might emerge in time and offering contract designers a choice between cheap and unreliable feeds or expensive but trustworthy sources. 


# Epochs
Each feed can only be supplied by one oracle at a time. The current oracle has a tenure that lasts for the duration of blocks as specified by **EpochSpan**. The first epoch starts at the property **StartingBlock**. To secure the right to supply for the duration of an epoch, oracles bid on particular epochs which are numbered in sequence. For instance, if EpochSpan is 1000 and the starting block is 0 then epoch1 is from block 0 to block 999, epoch2 is from block 1000 to block 1999 etc. Oracles will search for empty epochs and bid in an auction a particular epoch, establishing a queue of oracles. For popular feeds, the queue of next oracles will be long enough to guarantee a sufficiently long list of filled epochs. 

# Source Ignorance
A smart contract relying on a feed will not be able to forcast the list of oracles. Participating in Pythia means relinquishing the notion of insisting that data be provided from a particular trusted source. Instead, designers should only trust the incentives and mechanics of the system to regulate the reliability of the data provided.

# Bounty Auctions
Since oracles need to be compensated for the time and gas they spend supplying data, consumers of data can offer bounties per epoch (denominated in ether or an ERC20 token). If an oracle supplies data for the duration of the epoch and is not contested in the judicial overview system then they may withdraw the bounty reward. If more than 1 consumer offers a bounty, the value is simply added to the jackpot.

# Feed Bounties - consumer economics
Certain feeds may be so important that communities of consumers arise who essentially crowdfund bounties, ensuring the continued integrity of a feed. In other cases, one consumer may have such a strong need to ensure integrity that all bounties are supplied by them. Other consumers may then simply free ride off of the integrity established by the sole donor consumer. The value and supply of bounties of a feed will therefore be directly proportional to its popularity. The use of the passive oracle model means that one feed can supply 1000s of smart contracts. A feed such as ETHUSD will be so well supplied that many smart contract designers will be able to treat it as a free and permanent source of information. The average cost of a feed decreases with the number of consumers. Contrast this with an active oracle system where each reliant smart contract has to provide incentive to be activated. The average cost is constant in this case. The blockchain bloat in the active oracle scenario is a function of the number of consumers but it invariant with use in Pythia. 
For popular feeds, the effect of Pythia will be to drive down the cost of consuming data and will reduce the redundancy of repeated data on the blockchain.

# Deposit Auctions and Oracle Economics
Oracles compete to win the right to a bounty on a given epoch in return for supplying reliable data for the duration of the epoch. In order to secure the right to an epoch, Oracles bid in an auction before the epoch begins. The highest bid is locked until it is displaced by a higher bid. The oracle who placed the displaced bid can withdraw. A certain number of blocks before the epoch begins, the auction is concluded. The highest bid is now staked as a deposit for the duration of the epoch and some time after, refered to as the epoch cool down period. At any time during the epoch or the epoch cooldown, anyone can dispute the results offered by the oracle, triggering the dispute resolution mechanism. The bounty reward and deposit are then locked until the dispute has been adjudicated over. If the oracle loses, their divided between the judges and the plaintiff and the bounty is burned. Otherwise, both are returned to the oracle.

# Dispute Resolution
If an oracle is suspected of providing bad data, anyone can dispute the data. In order to do so, the plaintiff has to stake a deposit equal in size to the deposit staked by the oracle. For popular epochs, this means that the incentive to dispute is higher but the risk of false accusations is greater. Both incentives act to ensure the smooth running of popular feeds. 
In the initial stage of Pythia, the dispute will trigger the Aragon Court System into effect. The rules of Pythia dispute resolution are defined according to the objective standards laid out in the feed (MarginOfError, RequiredFreqency and EpochSpan). The court will be free to decide on its source of truth. The design of Pythia will in the future allow users to bring their own legal system and attach the legal system to a particular feed. The Pythia platform will provide a set of smart contract interfaces that can be used to construct a custom legal system. For instance, suppose that a user wishes a feed to be governed by the 3 judge mechanism outlined in the Ulex documentation (ulex link). They would implement the interfaces correctly, deploy the necessary smart contracts and then register the entry point contract with the feed. A feed will thus be defined as 
```
 { 
        FeedID: 110,
        Precision: 2,
        MarginOfError:1,
        Name: "TOMH",
        Description: "Number of hairstyles Tom W. Bell has had since turning 20",
        Frequency: 99990,
        MinumumSuccess:0,
        EpochSpan:2500,
        StartingBlock: 1245678,
        LegalContract: 0xF643724f52BC1316109D343E79b4Ba0dc2Faca88
}
```
The **LegalContract** property refers to the address the deployed contract that acts as an entry point into the Ulex legal system. In this case, Aragon's Court System will act as a supreme court.

# Attack Vectors
The attack surface of Pythia is dependent on the vigilance of its users. The non-exhaustive list of attack vectors are:
1. Supply bogus data to an unpopular feed. This risk requires feed authors to establish a known popularity for a feed before relying on the authenticity of its contributors
2. Faking a winning streak: An group of colluding oracles can establish a feed and contribute to it, boosting their winning streak allowing them to participate in coveted feeds which have high MinimumSuccess properties. This is a special case in which users can dispute the very existence of a feed. If a feed is a bogus to boost the reputation of oracles and cannot be objectively verified, the legal system can delete the feed as well as the winning streak for any oracles which have participated in it.
3. Dead epochs. A malicious user who wishes to see a feed fail may expend resources bidding on an epoch, only to provide bogus data. The attacker in this case is willing to forefeit their deposit. This is Pythia's equivalent of a 51% attack. Currently there is no obvious solution to this. Instead, since the attack is costly, it should be unsustainable over long periods of time. It is also less likely since a feed is not associated with one company but with a fact of reality such as the gold price in Japanese Yen. The more popular a feed, the more costly it will be to attack, similarly to how the highest value blockchains are the most resiliant to 51% attacks.

# Long Term Scaling
In order to save oracles gas, authors of less popular feeds may wish to establish their feed on a sidechain. Future additions to Pythia will be engineered to allow for feeds to exist on sidechains such as those provided by the Loom Network. For less popular feeds or very application specific feeds (such as metrics for online games), it may be desirable to keep the feed out of the mainchain. Conceptually, Pythia naturally allows for offchain scaling. However, as mentioned above, a secondary benefit will be to establish universal sources of truth for popular feeds such as ETHUSD, negating the need for each new smart contract to source its own version of the truth. 

# Conclusion



# Diagram

![It's Pizza](https://gist.github.com/maxogden/97190db73ac19fc6c1d9beee1a6e4fc8/raw/adaaa9b5c19460d3be42021ef0c1b8e11a8d38fe/pizza.png)

# Algorithm

$$f(x)=pizza^2$$

# References