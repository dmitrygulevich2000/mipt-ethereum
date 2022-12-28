pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Escrow.sol";

contract EscrowFactory {
    address public escrowImplementation;

    constructor(address _implementation) {
        escrowImplementation = _implementation;
    }

    function newEscrow(address _buyer, address _seller, uint _costEther, string memory _description) public returns (address) {
        address proxy = Clones.clone(escrowImplementation);
        Escrow(proxy).initialize(_buyer, _seller, _costEther, _description);
        return proxy;
    }
}