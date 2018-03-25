pragma solidity ^0.4.17;

import "./ERC20.sol";

contract PushERC20 is ERC20 {

    function transferAndNotify(address to, uint value) public returns (bool);
}
