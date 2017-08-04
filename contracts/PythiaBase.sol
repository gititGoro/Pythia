pragma solidity ^0.4.11;

import "./AccessRestriction.sol";

contract PythiaBase is AccessRestriction{
   
 struct Kreshmoi{
    uint16 blockRange;
    uint8 decimalPlaces;// floats don't exist in solidity (yet)
    int64 value;
    uint8 sampleSize;
    uint valueRange;
    address bountyPoster;
    }

    struct Bounty{
        uint16 maxBlockRange;
        uint earliestBlock;
        uint weiRewardPerOracle;
        uint8 requiredSampleSize;
        uint maxValueRange;
        address[] oracles;
        int64 [] predictions;
        uint8 decimalPlaces;
        address poster;
    }

}