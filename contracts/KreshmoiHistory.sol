pragma solidity ^0.4.18;
import "./Judge.sol";
import "./FeedMaster.sol";

contract KreshmoiHistory is AccessRestriction {
    
   struct UnrewardedKreshmoi {
        uint totalPredictionValue;
        address[] oracles;
        uint blocknumber;
    }

    struct FinalKreshmoi {
        uint averageValue;
        uint blocknumber;
    }

    mapping (uint => FinalKreshmoi[]) finalKreshmoi;
    mapping (uint => UnrewardedKreshmoi[]) unrewardedKreshmoi;
    Judge judge;
    FeedMaster feedMaster;
    address judgeContractAddress;

    function setDependencies (address judgeAddress, address feedMasterAddress)  onlyOwner public {
        judge = Judge(judgeAddress);
        feedMaster = FeedMaster(feedMasterAddress);
    }
   
    function logUnrewardedPythiaKreshmoi (uint totalValue, uint feedId, address[] oracles) public {
        require (msg.sender == judgeContractAddress);
        UnrewardedKreshmoi memory kreshmoi = UnrewardedKreshmoi({
            totalPredictionValue: totalValue,
            oracles: oracles,
            blocknumber: block.number
        });
        unrewardedKreshmoi[feedId].push(kreshmoi);
    }

    function finalizeKreshmoiForFeed (uint feedId, uint offset) public {
        uint rewardPerOracle = feedMaster.getRewardByFeedId(feedId) / feedMaster.getNumberOfOracles(feedId);
        while (unrewardedKreshmoi[feedId].length > 0 && offset > 0) {
                uint currentIndex = unrewardedKreshmoi[feedId].length-1;
                
                for (uint j = 0; j < unrewardedKreshmoi[feedId][currentIndex].oracles.length; j--) {
                   judge.addBountyReward (unrewardedKreshmoi[feedId][currentIndex].oracles[j],rewardPerOracle); 
                }
                //TODO: create final kreshmoi and delete unrewardedKreshmoi

                FinalKreshmoi memory kreshmoi = FinalKreshmoi ({
                    averageValue: unrewardedKreshmoi[feedId][currentIndex].totalPredictionValue/unrewardedKreshmoi[feedId][currentIndex].oracles.length,
                    blocknumber: unrewardedKreshmoi[feedId][currentIndex].blocknumber
                });
                finalKreshmoi[feedId].push(kreshmoi);

                delete unrewardedKreshmoi[feedId][currentIndex];
                unrewardedKreshmoi[feedId].length--;
                offset--;
        }
    }
}