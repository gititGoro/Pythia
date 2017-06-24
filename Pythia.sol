pragma solidity ^0.4.11;
//TODO: see common patters for restricting access so that bids can't be inspected without going through request function
//TODO: read security stuff

contract Pythia{

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

    mapping(string => Kreshmoi) bids;
    mapping(address => Kreshmoi[]) successfulHistory; //TODO: make sure dynamic array
}