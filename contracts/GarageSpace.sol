// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GarageSpace is ERC721Enumerable, Ownable {
    constructor() ERC721("ParkMe", "PM") Ownable() { }

    function mint() payable external returns(bool) {
        require(msg.value >= 0.5 ether, "Insuficient funds");
        _safeMint(msg.sender, totalSupply());
        return true;
    }
}
