pragma solidity ^0.4.17;

contract AccessRestriction {
    // These will be assigned at the construction
    // phase, where `msg.sender` is the account
    // creating this contract.
    address public owner = msg.sender;
    uint public creationTime = block.timestamp;


    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // Modifiers can be used to change
    // the body of a function.
    // If this modifier is used, it will
    // prepend a check that only passes
    // if the function is called from
    // a certain address.
    // modifier onlyBy(address _account)
    // {
    //     require(msg.sender == _account);
    //     // Do not forget the "_;"! It will
    //     // be replaced by the actual function
    //     // body when the modifier is used.
    //     _;
    // }

    // /// Make `_newOwner` the new owner of this
    // /// contract.
    // function changeOwner(address _newOwner) public
    //     onlyBy(owner)
    // {
    //     owner = _newOwner;
    // }

    // modifier onlyAfter(uint _time) {
    //     require(block.timestamp >= _time);
    //     _;
    // }

    // /// Erase ownership information.
    // /// May only be called 6 weeks after
    // /// the contract has been created.
    // function disown() public
    //     onlyBy(owner)
    //     onlyAfter(creationTime + 6 weeks)
    // {
    //     delete owner;
    // }
}