pragma solidity ^0.4.17;
import "./interfaces/PushERC20.sol";
import "./AccessRestriction.sol";
import "./libraries/SafeMath.sol";
import "./interfaces/NotifiableTokenHolder.sol";

contract Scarcity is PushERC20, AccessRestriction {
    using SafeMath for uint;
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier isScaled {
        require(iteration[msg.sender] >= currentLockTick);
        _;
    }

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public supply;
    mapping (address => uint) public balances;
    //the following 3 variables allow scarcity balances to be scaled.
    //if the supply falls too low, a new factor is set. All users are frozen
    //until they call scaleCurrentBalances.
    //This gets around the "too little change" problem that deflationary currecies experience
    mapping (address=>uint) iteration;
    uint currentLockTick;
    uint[] multiplicativeFactors;

    function FixedSupplyToken() public {
        symbol = "SCARCITY";
        name = "Scarcity";
        decimals = 18;
        supply = 100000000 * 10**uint(decimals);
        balances[owner] = supply;
        Transfer(address(0), owner, supply); //on upgrade to 4.21, add emit keywordc
        currentLockTick = 0;
        multiplicativeFactors.push(1);
    }

    function amplifyBalances (uint factor) onlyOwner public {
        require (factor * supply <= 100000000 * 10**uint(decimals));
        multiplicativeFactors.push(factor);
        currentLockTick = currentLockTick.add(1);
    }

    function scaleCurrentBalance () public {
        for (uint i = iteration[msg.sender]+1; i<multiplicativeFactors.length; i++) {
            balances[msg.sender] = balances[msg.sender].mul(multiplicativeFactors[i]);
            iteration[msg.sender] = iteration[msg.sender].add(1);
        }
    }

    function totalSupply() public view returns (uint256) {
        return supply;
    }

    function balanceOf(address who) isScaled public view returns (uint256) {
        return balances[who];
    }

    function transfer(address to, uint256 value) isScaled public returns (bool) {
        require(balances[msg.sender]>=value);
        if(to == address (0)) {
            supply = supply.sub(value);
        } else
          balances[to] = balances[to].add(value);
       
        balances[msg.sender] = balances[msg.sender].sub(value);
        Transfer(msg.sender, to, value);
        return true;
    }
    
    function burn (uint value) public returns (bool) {
        transfer (address(0), value);
    }

    function transferAndNotify(address to, uint value) isScaled public returns (bool) {
        transfer (to, value);
        NotifiableTokenHolder(to).NotifyOnReceipt(msg.sender, this, value);
    }

    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) isScaled public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);

}
