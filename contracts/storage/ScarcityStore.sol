pragma solidity ^0.4.17;
import "../baseContracts/AccessControlled.sol";
import "../libraries/SafeMath.sol";

contract ScarcityStore is AccessControlled {
    using SafeMath for uint;
    mapping (address => uint) public balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    //the following 3 variables allow scarcity balances to be scaled.
    //if the supply falls too low, a new factor is set. All users are frozen
    //until they call scaleCurrentBalances.
    //This gets around the "too little change" problem that deflationary currecies experience
    mapping (address=>uint) public iteration;
    uint public currentLockTick;
    uint[] public multiplicativeFactors;
    uint public supply;

    function initializeSupply(uint s) onlyOwner public {
        if(s==0)
         supply = 100000000 * 10**uint(18);
            else
         supply = s;
    }

    function reduceAllotment(address from, address to, uint value) onlyOwner public {
        require(value <= allowed[from][to]);
        allowed[from][to] = allowed[from][to].sub(value);
    }

    function getAllotment(address owner, address spender) public view returns (uint){
        return allowed[owner][spender];
    }

    function setAllotment(address from, address to, uint value) onlyOwner public {
        allowed[from][to] = value;
    }

    function validateBalance (address sender, uint value) onlyOwner public view {
        require(value <= balances[sender]);
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

    function BalanceSet(address to, uint value) onlyOwner public {
        balances[to] = value;
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
