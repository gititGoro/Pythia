pragma solidity ^0.4.17;
import "../AccessRestriction.sol";

contract ScarcityStore is AccessRestriction {

    mapping (address => uint) public balances;
    //the following 3 variables allow scarcity balances to be scaled.
    //if the supply falls too low, a new factor is set. All users are frozen
    //until they call scaleCurrentBalances.
    //This gets around the "too little change" problem that deflationary currecies experience
    mapping (address=>uint) public iteration;
    uint public currentLockTick;
    uint[] public multiplicativeFactors;

    function getMultiplicativeFactorLength() public returns (uint) {
        return multiplicativeFactors.length;
    }

    function pushMultiplicativeFactor(uint factor) onlyOwner public {
        multiplicativeFactors.push(factor);
    }

    function () payable public { 
        revert();
    }
}
