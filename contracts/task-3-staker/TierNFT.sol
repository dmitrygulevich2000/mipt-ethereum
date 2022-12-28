pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TierNFT is Ownable {
    mapping (uint256 => address) tokenOwner;
    mapping (uint256 => string) tokenDescription;
    mapping (address => uint256) balance;
    uint256 nextTokenID = 0;

    string internal tierName = "undefined";

    address stakerFactory;

    function setFactory(address _stakerFactory) public onlyOwner {
        stakerFactory = _stakerFactory;
    }

    function create(address _to, string memory _description) external {
        require(stakerFactory == msg.sender, "only staker is allowed to create NFTs");

        tokenOwner[nextTokenID] = _to;
        tokenDescription[nextTokenID] = string.concat(tierName, ": ", _description);
        balance[_to]++;
        nextTokenID++;
    }

    function description(uint256 _tokenId) external view returns(string memory) {
        return tokenDescription[_tokenId];
    }

    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "ERC721: address zero is not a valid owner");
        return balance[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = tokenOwner[_tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }
}

contract GoldTierNFT is TierNFT {
    constructor() {
        tierName = "GOLD";
    }
}

contract SilverTierNFT is TierNFT {
    constructor() {
        tierName = "SILVER";
    }
}

contract BronzeTierNFT is TierNFT {
    constructor() {
        tierName = "BRONZE";
    }
}
