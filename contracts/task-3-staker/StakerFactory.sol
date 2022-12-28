pragma solidity ^0.8.0;

contract StakerFactory {
    struct Staker {
        string description;

        uint targetSum;
        address targetAddress;

        mapping (address => uint) contributions;
        address[] participants;
        uint collectedTotal;
        
        uint expiresAt;
        bool completed;
    }

    // description => staker
    mapping (string => Staker) stakers;

    function createStaker(string memory _description, uint _targetEtherCount, uint _durationMinutes) public {
        require(_targetEtherCount > 0, "stake sum must be positive");
        require(stakers[_description].targetSum == 0, "staker with such description already present");

        Staker storage new_staker = stakers[_description];
        
        new_staker.description = _description;

        new_staker.targetSum =_targetEtherCount * 1 ether;
        new_staker.targetAddress = msg.sender;

        new_staker.expiresAt = block.timestamp + _durationMinutes * 1 minutes;
        new_staker.completed = false;
    }

    function _getStaker(string memory _description) internal view returns(Staker storage) {
        require(stakers[_description].targetSum > 0, "staker with such description not found");
        
        return stakers[_description];
    }
}