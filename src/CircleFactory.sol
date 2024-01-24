// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { LibClone } from "@solady/utils/LibClone.sol";
import { Ownable } from "@solady/auth/Ownable.sol";
import { ICircleOfPuffs } from "./interfaces/ICircleOfPuffs.sol";

contract CircleFactory is Ownable {
    address public tokenImplementation;

    error TokenImplementationNotSet();

    event TokenImplementationUpdated(address);
    event CircleOfPuffsCreated(address indexed circle);

    constructor(address _tokenImplementation) {
        _initializeOwner(msg.sender);
        tokenImplementation = _tokenImplementation;
    }

    function createCircle(
        address firstPuffer,
        string calldata name,
        string calldata symbol
    )
        external
        returns (address circle)
    {
        if (tokenImplementation == address(0)) revert TokenImplementationNotSet();
        circle = LibClone.clone(tokenImplementation);
        ICircleOfPuffs(circle).initialize(firstPuffer, name, symbol);
        emit CircleOfPuffsCreated(address(circle));
    }

    function setTokenImplementation(address _tokenImplementation) external onlyOwner {
        tokenImplementation = _tokenImplementation;
        emit TokenImplementationUpdated(_tokenImplementation);
    }
}
