
# Pythia Decentralized Ethereum Oracle

Pythia is a datafeed oracle that incentivizes data submissions. Any contract requesting data will specify the freshness and acceptable variance of the datafeed they request and will provide a non zero reward. If the conditions set by the requester are met, the senders of the most recent submissions will have the reward equally split amongst them. If the range of answers is too wide or if the data is too stale, no one is rewarded and the contract receives no data.
In this way, the sumbitters who are ignorant of other submissions will be acting most rationally if they try to submit the most accurate data. Similarly, if the requester wants fresh and accurate data, the incentive will be to place as high a reward and as leniant a variance as possible.