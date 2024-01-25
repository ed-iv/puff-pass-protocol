// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { ERC721 } from "@solady/tokens/ERC721.sol";

import { IRotation } from "./interfaces/IRotation.sol";

contract Rotation is ERC721, IRotation {
    bool private initialized;

    string private _name;
    string private _symbol;
    mapping(uint256 id => string uri) private _tokenURIs;
    address public currPuffer;

    uint256 private _nextTokenId;

    error AlreadyInitialized();
    error UnauthorizedPuff();
    error UnlawfulDoublePuffAttempted();
    error AddressZeroNoPuff();

    modifier onlyPuffer() {
        if (msg.sender != currPuffer) revert UnauthorizedPuff();
        _;
    }

    function initialize(address firstPuffer, string calldata name_, string calldata symbol_) external {
        if (initialized) revert AlreadyInitialized();
        initialized = true;
        currPuffer = firstPuffer;
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        if (!_exists(id)) revert TokenDoesNotExist();
        return _tokenURIs[id];
    }

    function mint(address to, string calldata uri, address nextPuffer) external onlyPuffer {
        if (nextPuffer == address(0)) revert AddressZeroNoPuff();
        if (nextPuffer == currPuffer) revert UnlawfulDoublePuffAttempted();
        uint256 tokenId = ++_nextTokenId;
        _mint(to, tokenId);
        _tokenURIs[tokenId] = uri;
        currPuffer = nextPuffer;
    }

    function totalSupply() external view returns (uint256) {
        return _nextTokenId;
    }
}
