pragma solidity ^0.4.11;
//TODO: see common patters for restricting access so that bids can't be inspected without going through request function
//TODO: read security stuff
//TODO: when placing a bid, do an inplace sort so that the final request doesn't run out of gas
//SECURITY: Always change all variables and only as the very last act, transfer ether.
//SECURITY: perform all bookkeeping on the same scope level in case malicious actor gets stack to 1024 and then you try to do something with function call and 
//it isn't atomic
//SECURITY: use invariants to trigger safe mode if any of the invariants become inconsistent.
//Breakthrough: It doesn't matter than the state is viewable to all. What matters is that it's private to contracts.
import "./AccessRestriction.sol";

contract Pythia is AccessRestriction{

    enum KreshmoiDataType{
     STRING,UINT,INT,PICO
    }

    //A kreshmoi is an ancient Greek word meaning an utterance issued by an oracle.
    //In our decentralized oracle, Pythia, Kreshmoi will be the name of the data structure representing an "utterance" on a given datafeed.
    struct Kreshmoi{
    uint blockNumber;
    string datafeedKey; //eg. USDETH
    KreshmoiDataType dataType;
    string value_str;
    uint value_uint;
    int value_int;
    uint value_pico; // each unit of this represents 1 trillionth of a unit
    address sender;
    }

    mapping (string => Kreshmoi) bids;
    mapping (address => Kreshmoi []) successfulHistory; //TODO: make sure dynamic array
    //if a datafeed is requested and doesn't exist, ("name",false) is created, otherwise ("name",true) is set
    mapping (string => bool) existentDataFeeds; 
}