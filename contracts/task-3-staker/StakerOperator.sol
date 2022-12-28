pragma solidity ^0.8.0;

import "./StakerFactory.sol";

interface TierNFT {
    function create(address _to, string memory _description) external;
}

contract StakerOperator is StakerFactory {

    TierNFT goldTierNFT;
    TierNFT silverTierNFT;
    TierNFT bronzeTierNFT;

    constructor(address _goldTierNFT, address _silverTierNFT, address _bronzeTierNFT) {
        goldTierNFT = TierNFT(_goldTierNFT);
        silverTierNFT = TierNFT(_silverTierNFT);
        bronzeTierNFT = TierNFT(_bronzeTierNFT);
    }

    function contribution(string memory _staker) external view returns(uint) {
        Staker storage staker = _getStaker(_staker);
        return staker.contributions[msg.sender];
    }

    function getCollectedTotal(string memory _staker) external view returns(uint) {
        Staker storage staker = _getStaker(_staker);
        return staker.collectedTotal;
    }

    function contribute(string memory _staker) external payable {
        Staker storage staker = _getStaker(_staker);
        require(!_expired(staker), "Staker: cannot contribute to expired contract");
        require(msg.value > 0, "Staker: contribute requires money");
        if (staker.contributions[msg.sender] == 0) {
            staker.participants.push(msg.sender);
        }

        staker.contributions[msg.sender] += msg.value;
        staker.collectedTotal += msg.value;
    }

    function withdraw(string memory _staker) external {
        Staker storage staker = _getStaker(_staker);

        require(_expired(staker), "Staker: can withdraw only after expiration");
        require(!_targetReached(staker), "Staker: can withdraw only if target not reached");
        require(staker.contributions[msg.sender] > 0, "Staker: no value to contribute");
        
        payable(msg.sender).transfer(staker.contributions[msg.sender]);
        staker.contributions[msg.sender] = 0;
    }

    function complete(string memory _staker) public /*onlyOwner*/ {
        
        Staker storage staker = _getStaker(_staker);
        
        require(_expired(staker), "Staker: can complete only after expiration");
        require(!_completed(staker), "Staker: can complete only once");
        if (_targetReached(staker)) {
            payable(staker.targetAddress).transfer(staker.collectedTotal);
            _reward(staker);
        }
        staker.completed = true;
    }

    function _reward(Staker storage _staker) internal {
        for (uint i = 0; i < _staker.participants.length; i++) {
            address addr = _staker.participants[i];
            uint contrib = _staker.contributions[addr];
            
            if (contrib * 2 >= _staker.targetSum) {
                goldTierNFT.create(addr, _staker.description);
            
            } else if (contrib * 3 >= _staker.targetSum) {
                silverTierNFT.create(addr, _staker.description);
            
            } else if (contrib * 10 >= _staker.targetSum) {
                bronzeTierNFT.create(addr, _staker.description);
            }

        }
    }

    function _expired(Staker storage _staker) internal view returns(bool) {
        return block.timestamp >= _staker.expiresAt;
    }

    function _targetReached(Staker storage _staker) internal view returns(bool) {
        return _staker.targetSum <= _staker.collectedTotal;
    }

    function _completed(Staker storage _staker) internal view returns(bool) {
        return _staker.completed;
    }
}