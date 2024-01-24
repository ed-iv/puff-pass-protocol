// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { LibClone } from "@solady/utils/LibClone.sol";
import { Ownable } from "@solady/auth/Ownable.sol";
import { ICircleOfPuffs } from "./interfaces/ICircleOfPuffs.sol";

contract CircleFactory is Ownable {
    address public tokenImplementation;

    error TokenImplementationNotSet();

    event TokenImplementationUpdated(address);
    event CircleOfPuffsCreated(string name, string symbol);

    constructor(address _tokenImplementation) {
        _initializeOwner(msg.sender);
        tokenImplementation = _tokenImplementation;
    }

    function createCircle(address firstPuffer, string calldata name, string calldata symbol) external {
        if (tokenImplementation == address(0)) revert TokenImplementationNotSet();
        ICircleOfPuffs newCircle = ICircleOfPuffs(LibClone.clone(tokenImplementation));
        newCircle.initialize(firstPuffer, name, symbol);
        emit CircleOfPuffsCreated(name, symbol);
    }

    function setTokenImplementation(address _tokenImplementation) external onlyOwner {
        tokenImplementation = _tokenImplementation;
        emit TokenImplementationUpdated(_tokenImplementation);
    }
}
