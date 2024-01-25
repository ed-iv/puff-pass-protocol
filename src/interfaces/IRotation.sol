// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

interface IRotation {
    function initialize(address firstPuffer, string calldata name_, string calldata symbol_) external;

    function mint(address to, string calldata uri, address nextPuffer) external;
}
