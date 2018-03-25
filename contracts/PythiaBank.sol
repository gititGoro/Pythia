pragma solidity ^0.4.17;
import "./interfaces/Bank.sol";
import "./AccessRestriction.sol";
import "./libraries/SafeMath.sol";
import "./interfaces/ERC20.sol";

contract PythiaBank is Bank, AccessRestriction {
    
    using SafeMath for uint;

    mapping(address => bool) public authorizedContracts;
    mapping(address => uint) public unfetteredEtherBalances;
    mapping(address => mapping(address=> uint)) public unfetteredERC20Balances;
    //lockedERC20[token][lockingcontract][user]
    mapping(address => mapping(address => mapping(address=>uint))) public lockedERC20;
    //lockedEther[lockingcontract][user]
    mapping(address => mapping(address => uint)) public lockedEther;

    function NotifyOnReceipt(address from, address tokenContract, uint amount) public {
        unfetteredERC20Balances[tokenContract][from] = amount;
    }

    function GrantControlToContract (address authority) onlyOwner public  {
        authorizedContracts[authority] = true;
    } 

    function RevokeControlToContract (address authority) public {
        authorizedContracts[authority] = false; 
    }

    //if address is 0x0 then we're using ether 
    function LockDeposit(address user, uint amount, address tokenContract) public {
        require (authorizedContracts[msg.sender] = true);
        if(tokenContract == address(0)) {
            require(unfetteredEtherBalances[user] >= amount);
            lockedEther[msg.sender][user].add(amount);
        } else {
            require(unfetteredERC20Balances[tokenContract][user] >= amount);
            lockedERC20[tokenContract][msg.sender][user].add(amount);
            unfetteredERC20Balances[tokenContract][user].sub(amount);
        }
    }

    function UnlockDeposit(address user, uint amount, address tokenContract) public {
        require (authorizedContracts[msg.sender] = true);
        if(tokenContract == address(0)) {
            require(lockedEther[msg.sender][user] >= amount);
            lockedEther[msg.sender][user].sub(amount);
            unfetteredEtherBalances[user].add(amount);
        } else {
            require(lockedERC20[tokenContract][msg.sender][user] >= amount);
            unfetteredERC20Balances[tokenContract][user].add(amount);
            lockedERC20[tokenContract][msg.sender][user].sub(amount);
        }
    }

    //allow free - totalLocked to be withdrawn
    function Withdraw(address user, uint amount, address tokenContract) public {
        if(tokenContract == address(0)) {
            require(unfetteredEtherBalances[user] >= amount);
            unfetteredEtherBalances[user].sub(amount);
            user.transfer(amount);
        } else {
            require(unfetteredERC20Balances[tokenContract][user] >= amount);
            unfetteredERC20Balances[tokenContract][user].sub(amount);
            ERC20(tokenContract).transfer(user, amount);
        }
    }

    function BurnDeposit(address user, uint amount, address tokenContract) public {
        require (authorizedContracts[msg.sender] = true);
        if(tokenContract == address(0)) {
            require(lockedEther[msg.sender][user] >= amount);
            lockedEther[msg.sender][user].sub(amount);
            address(0).transfer(amount);
        } else {
            require(lockedERC20[tokenContract][msg.sender][user] >= amount);
            lockedERC20[tokenContract][msg.sender][user].sub(amount);
            ERC20(tokenContract).transfer(address(0),amount);
        }
    }

}
