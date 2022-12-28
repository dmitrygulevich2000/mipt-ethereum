pragma solidity ^0.4.18;

contract utility {
    bytes32 public passwordInBytes;
    
    
    function PasswordToBytes (uint _pasword) public
  {
      passwordInBytes = bytes32(keccak256(_pasword));
  }
  
  function Sig() external view returns (bytes memory) {
      return abi.encodeWithSignature("Vault(bytes32 _password)", 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
  }    
}


contract Vault {
  bool public locked;
  bytes32 private password;
  bytes32 private information;
  
  
  function Vault(bytes32 _password) public {
    locked = true;
    password = _password;
  }
  
  function unlock(bytes32 _password) public {
    if (password == _password) {
      locked = false;
    }
  }
  function setInformation(bytes32 _information) public {
      information = _information; 
  }
}

// 92e00485
// 8c730612d77eb32c6e1722a2d5fdd6acea8eab09eb728cbf22e2c1fd