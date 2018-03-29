pragma solidity ^0.4.17;
import "./AccessController.sol";

contract AccessControlled {
    address public accessControllerContract;

    function setAccessController (address controller) public {
        accessControllerContract = controller;
    }

    modifier onlyOwner {
        require(AccessController(accessControllerContract).isOwner(msg.sender,this));
        _;
    }
}