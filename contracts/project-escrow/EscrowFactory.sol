pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract EscrowFactory is UpgradeableBeacon {

    constructor(address _escrowImplementation) UpgradeableBeacon(_escrowImplementation) {}

    function newEscrow(address _buyer, address _seller, uint _costEther, string memory _description) public returns (address) {
        BeaconProxy escrowProxy = new BeaconProxy(
            address(this),
            abi.encodeWithSignature("initialize(address,address,uint256,string)", _buyer, _seller, _costEther, _description)
        );
        return address(escrowProxy);
    }
}
