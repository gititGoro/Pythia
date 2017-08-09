#Domain Language
* Pythia
  - In Ancient Greece, a special class of oracle existed. Pythia consisted of groups of oracles offering predictions on common questions. The Pythia were far more accessible than individual oracles such as the Oracle of Delphi but were considered less accurate. 
  - The name is perfectly fitting for this decentralized oracle smart contract for 2 reasons:
    1. Each prediction requires many participants to form a consenus.
    2. Although game theory and behavioural economics implies increased accuracy with increased participation, accuracy is not guaranteed
  - Note that popular feeds such as ETHBTC and BTCUSD will attract enough bounties and oracles that we expect accuracy to match any centralized oracles but feeds for less popular feeds such as the zimbabwean dollar vs the botswana pula might require a great pinch of salt and consist of very stale data.
  - For this reason, bounties constitute data demand and predictions constitute data supply.
* Kreshmoi
  - In ancient Greece, an utterance by an oracle is called a Kreshmoi. For our domain, a prediction is only considered "by an oracle" if certain conditions are met. Therefore, a Kreshmoi refers to a consensus of successful predictions
* Hopeful
  - A bounty can only be won if enough participants offer a consensus of data. Only when a bounty is successful, is each participant considered a true oracle. Until then, they are only acolytes, peons... hopefuls.
* Oracle
  - When the required number of hopefuls offer data in the required window of time within the required margin of error, they are all rewarded ether and are classified as oracles for that datafeed. No special privileges exist going forward, other than an ego boost and an increased ether balance.

#Functions
* **SetDescription**(datafeed, description) *payable transaction*
  - sets or replaces the existing description for the datafeed provided you pay twice what the previous setter paid.
* **GetDatafeedNameChangeCost**(datafeed) *call*
  - returns the wei cost of calling SetDescription for a given feed
* **GetDescriptionByName**(datafeed) *call*
  - returns the description for the given datafeed.
* **GetDescriptionByIndex**(index) *call*
  - returns the description of the datafeed at the index
  - returns error message if index out of bounds
* **PostBounty**(datafeed, maxBlockRange, maxValueRange, requiredSampleSize, decimalPlaces) *payable transaction*
  - post a bounty for a given datafeed. Must post more wei than hopefuls so that each hopeful gets at least 1 wei reward
  - requiredSampleSize: The number of predictions from unique particiapants required to successfully create a quorum of agreeing pythia
  - maxBlockRange: window of blocks that all predictions must fall within. The window moves until it contains enough predictions.
    - eg. suppose a bounty with maxBlockRange of 5 and a requiredSampleSize of 4 exists. After 5 blocks only 3 unique hopefuls have contributed. In the next block, a hopeful contributes to the existing bounty. The previous hopefuls are all erased along with their prediction and this latest hopeful is the first on the list, resetting the bounty participation.
  - maxValueRange: if the range of values offered by the hopefuls exceeds this value, the bounty is reset. This creates the incentive for unanimity. A hopeful planning to skew the data to game a feed risks resetting the predictions if the other hopefuls are honest. To the extent that automatic web services participate, this risk is magnified.
  - decimalPlaces: at the time of publishing, solidity has no concept for floating point storage, even though it can perform floating point arithmetic. For this reason, all predictions are ints and are adjusted by the bounty's specified decimal places. This gives the bounty placer choice over precision
* **OfferKreshmoi** (datafeed, value) *transaction*
  - hopefuls can offer predictions for a given datafeed and potentially earn ether by becoming oracles
* **GetBountyReward** *call* 
  - Check ether balance of payouts for oracles.
* **CollectedBountyReward** *transaction*
  - Withdraw ether to oracle
* **GetKreshmoi** (datafeed) *call*
  - Returns the list of all predictions on this datafeed as well the precision for each one. Ordered by time desc
