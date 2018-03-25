pragma solidity ^0.4.17;
import "./NotifiableTokenHolder.sol";

/*when designing an ecosystem of contracts that can handle payments
in ether or ERC20 tokens, it helps to use a common payment interface
so that the rest of the ecosystem can be payment type agnostic in their 
implementation. This means we can switch between paying in ether or a token
with no code change require.
use case: user sends tokens or ether to bank by 
    either calling ERC20.transfer and then Bank.NotifyOnReceipt or by calling PushERC20.transferAndNotify
    the user's balance is then added to an unlocked balance.
    a judiciary contract can then lock down a deposit to prevent a user from transferring
    This simulates the reserved amount feature of credit cards
*/
contract Bank is NotifiableTokenHolder {

    function GrantControlToContract (address authority) public; //gives a contract right to lock deposits
    function RevokeControlToContract (address authority) public;
    function LockDeposit(address user, uint amount, address tokenContract) public; //if address is 0x0 then we're using ether 
    function UnlockDeposit(address user, uint amount, address tokenContract) public;
    function Withdraw(address user, uint amount, address tokenContract) public;//allow free - totalLocked to be withdrawn
    function BurnDeposit(address user, uint amount, address tokenContract) public;
}
