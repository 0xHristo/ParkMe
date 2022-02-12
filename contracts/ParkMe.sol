// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {GarageSpace} from "./GarageSpace.sol";

contract ParkMe is Ownable {
    struct GarageSpaceInfo {
        uint256 id;
        uint256 rentedUntil;
        uint256 rentPrice;
        address owner;
        address rentedBy;
    }

    GarageSpaceInfo[] public _garages;
    GarageSpace public _garageSpace;
    mapping(uint256 => bool) public _listedGarages;
    uint256 RENT_PRICE = 1 ether;
    uint256 RENT_PERIOD = 30 * 24 * 60 * 60;

    constructor(address garageSpace) Ownable() { 
        _garageSpace = GarageSpace(garageSpace);
    }

    function listForRent(uint256 id) external {
        require(_listedGarages[id] == false, "Garage spaace already listed!");
        require(_garageSpace.ownerOf(id) == msg.sender, "You can't list garage which is not yours!");
        GarageSpaceInfo memory newGarageSpaceInfo = GarageSpaceInfo(
            id,
            0,
            RENT_PRICE,
            msg.sender,
            address(0)
        );
        _garages.push(newGarageSpaceInfo);
    }

    function getListedAndNotRented() public view returns(GarageSpaceInfo[] memory) {
        uint256 freeGaragesCount;
        for (uint i = 0; i < _garages.length; i++) {
            if(_garages[i].rentedUntil < block.timestamp) {
                freeGaragesCount++;
            }
        }

        GarageSpaceInfo[] memory freeGarages = new GarageSpaceInfo[](freeGaragesCount);

        uint256 index;
        for (uint i = 0; i < _garages.length; i++) {
            if(_garages[i].rentedUntil < block.timestamp) {
               freeGarages[index] = _garages[i];
               index++;
            }
        }
       
       return freeGarages;
    }
    function rent(uint id) payable external returns(bool) {
         uint256 index;
         bool isFreeAndListed;
         for (uint i = 0; i < _garages.length; i++) {
            GarageSpaceInfo storage currentGarageSpace = _garages[i];
            if(currentGarageSpace.id == id && currentGarageSpace.rentedUntil < block.timestamp) {
                isFreeAndListed = true;
                index = i;
            }
        }

        require(isFreeAndListed == false, "The garage with the desired ID is not free at the moment!");
        GarageSpaceInfo storage garageSpaceWithID = _garages[index];
        require(msg.value >= garageSpaceWithID.rentPrice, "Insufficient funds sent!");

        garageSpaceWithID.rentedBy = msg.sender;
        garageSpaceWithID.rentedUntil = block.timestamp + RENT_PERIOD;
    }

    function open(uint id) external view returns(bool){
        uint256 index;
        bool isFreeAndListed;
        for (uint i = 0; i < _garages.length; i++) {
            GarageSpaceInfo memory currentGarageSpace = _garages[i];
            if(currentGarageSpace.id == id && currentGarageSpace.rentedUntil < block.timestamp) {
                isFreeAndListed = true;
                index = i;
            }
        }

        require(isFreeAndListed == false, "The garage with the desired ID is not free at the moment!");
        GarageSpaceInfo memory garageSpaceWithID = _garages[index];
        require(msg.sender >= garageSpaceWithID.rentedBy, "You are not the owner!");
        require(block.timestamp <= garageSpaceWithID.rentedUntil, "Your rent has ended!");

        return true;
    }
}
