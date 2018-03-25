pragma solidity ^0.4.17;
import "../AccessRestriction.sol";
import "../libraries/SafeMath.sol";

contract ScarcityStore is AccessRestriction {
    using SafeMath for uint;
    mapping (address => uint) public balances;
    //the following 3 variables allow scarcity balances to be scaled.
    //if the supply falls too low, a new factor is set. All users are frozen
    //until they call scaleCurrentBalances.
    //This gets around the "too little change" problem that deflationary currecies experience
    mapping (address=>uint) public iteration;
    uint public currentLockTick;
    uint[] public multiplicativeFactors;
    uint public supply;
    function ScarcityStore () public {
        supply = 100000000 * 10**uint(18);
    }

    function IncrementSupply(uint value) onlyOwner public {
        supply = supply.add(value);
    }
    
    function DecrementSupply(uint value) onlyOwner public {
        supply = supply.sub(value);
    }

    function ResetOwnerBalance (address scarcityOwner) onlyOwner public {
        balances[scarcityOwner] = supply;
    }

    function BalanceIncrement(address to, uint value) onlyOwner public {
        balances[to] = balances[to].add(value);
    }

    function BalanceDecrement(address to, uint value) onlyOwner public {
        balances[to] = balances[to].sub(value);
    }

    function getMultiplicativeFactorLength() public view returns (uint) {
        return multiplicativeFactors.length;
    }

    function pushMultiplicativeFactor(uint factor) onlyOwner public {
        multiplicativeFactors.push(factor);
    }

    function incrementLockTick () onlyOwner public {
        currentLockTick = currentLockTick.add(1);
    }

    function incrementIteration(address sender) onlyOwner public {
        iteration[sender] = iteration[sender].add(1); 
    }

    function () payable public { 
        revert();
    }
}
