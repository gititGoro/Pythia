pragma solidity ^0.4.17;

import "./baseContracts/AccessControlled.sol";
import "./baseContracts/AccessController.sol";
import "./interfaces/PushERC20.sol";
import "./interfaces/NotifiableTokenHolder.sol";
import "./storage/ScarcityStore.sol";

contract Scarcity is PushERC20, AccessControlled {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier isScaled {
        require(ScarcityStore(store).iteration(msg.sender) >= ScarcityStore(store).currentLockTick());
        _;
    }

    string public symbol;
    string public  name;
    uint8 public decimals;
    //the following 3 variables allow scarcity balances to be scaled.
    //if the supply falls too low, a new factor is set. All users are frozen
    //until they call scaleCurrentBalances.
    //This gets around the "too little change" problem that deflationary currecies experience
    address store;

    function Scarcity() public {
        symbol = "SCARCITY";
        name = "Scarcity";
        decimals = 18;
        //on upgrade to 4.21, add emit keywordc
    }

    function SetScarcityStore(address scarcityStore) public {
        AccessController(accessControllerContract).setOwnership(this, scarcityStore);
        store = scarcityStore;
        ScarcityStore(store).ResetOwnerBalance(msg.sender);
        Transfer(address(0), AccessController(accessControllerContract).getOwner(this), ScarcityStore(store).supply());
    }
    function () payable public { 
        revert();
    }


    function amplifyBalances (uint factor) onlyOwner public {
        require (factor * ScarcityStore(store).supply() <= 100000000 * 10**uint(decimals));
        ScarcityStore(store).pushMultiplicativeFactor(factor);       
        ScarcityStore(store).incrementLockTick();
    }

    function scaleCurrentBalance () public {
        for (uint i = ScarcityStore(store).iteration(msg.sender)+1; i < ScarcityStore(store).getMultiplicativeFactorLength(); i++) {
            ScarcityStore(store).BalanceIncrement(msg.sender,ScarcityStore(store).multiplicativeFactors(i));
            ScarcityStore(store).incrementIteration(msg.sender);
        }
    }

    function totalSupply() public view returns (uint256) {
        return ScarcityStore(store).supply();
    }

    function balanceOf(address who) isScaled public view returns (uint256) {
        return ScarcityStore(store).balances(who);
    }

    function transfer(address to, uint256 value) isScaled public returns (bool) {
        require(ScarcityStore(store).balances(msg.sender) >= value);
        if(to == address (0)) {
            ScarcityStore(store).DecrementSupply(value);
        } else
            ScarcityStore(store).BalanceIncrement(to,value);

        ScarcityStore(store).BalanceDecrement(msg.sender,value);
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
