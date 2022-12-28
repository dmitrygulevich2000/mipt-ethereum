pragma solidity ^0.8.0;

contract Assignment {
    struct Student {
        string name;
        uint8 age;
    }

    uint16 public groupsCount = 6;
    mapping (uint16 => Student[]) groupStudents;

    function assignToGroup(string memory _name, uint8 _age) public returns(uint16) {
        uint16 groupNumber = uint16(uint256(keccak256(abi.encodePacked(_name, _age, block.timestamp))) % groupsCount) + 1;

        groupStudents[groupNumber].push(Student(_name, _age));

        return groupNumber;
    }

    function getStudents(uint16 _groupNumber) external view returns (Student[] memory) {
        require(_groupNumber > 0 && _groupNumber <= groupsCount, "group does not exist");

        return groupStudents[_groupNumber];
    }

}
