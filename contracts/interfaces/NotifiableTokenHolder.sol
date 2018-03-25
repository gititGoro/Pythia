pragma solidity ^0.4.17;


contract NotifiableTokenHolder {

    function NotifyOnReceipt(address from, address tokenContract, uint amount) public;
}
