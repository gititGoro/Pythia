pragma solidity ^0.4.17;

import "./AccessRestriction.sol";

contract AccessController is AccessRestriction  {
    
    mapping (address => address) ownedToOwner;

    function setOwnership(address owner, address owned) onlyOwner public {
        ownedToOwner[owned] = owner;
    }

    function isOwner (address sender, address ownedContract) public view returns (bool) {
        return ownedToOwner[ownedContract] == sender;
    }

    function getOwner (address ownedContract) public view returns (address) {
        return ownedToOwner[ownedContract];
    }
}
