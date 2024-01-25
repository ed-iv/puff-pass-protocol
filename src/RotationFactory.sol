// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { LibClone } from "@solady/utils/LibClone.sol";
import { Ownable } from "@solady/auth/Ownable.sol";

import { IRotation } from "./interfaces/IRotation.sol";

contract RotationFactory is Ownable {
    address public tokenImplementation;

    error TokenImplementationNotSet();

    event TokenImplementationUpdated(address);
    event RotationCreated(address indexed rotation);

    constructor(address _tokenImplementation) {
        _initializeOwner(msg.sender);
        tokenImplementation = _tokenImplementation;
    }

    function createRotation(
        address firstPuffer,
        string calldata name,
        string calldata symbol
    )
        external
        returns (address rotation)
    {
        if (tokenImplementation == address(0)) revert TokenImplementationNotSet();
        rotation = LibClone.clone(tokenImplementation);
        IRotation(rotation).initialize(firstPuffer, name, symbol);
        emit RotationCreated(address(rotation));
    }

    function setTokenImplementation(address _tokenImplementation) external onlyOwner {
        tokenImplementation = _tokenImplementation;
        emit TokenImplementationUpdated(_tokenImplementation);
    }
}
