// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { ERC721 } from "@solady/tokens/ERC721.sol";
import { LibString } from "@solady/utils/LibString.sol";
import { Rotation } from "../src/Rotation.sol";

contract RotationTest is PRBTest, StdCheats {
    using LibString for uint256;

    Rotation internal rotation;

    string constant TOKEN_NAME = "Test Rotation";
    string constant TOKEN_SYMBOL = "ROT1";

    address puffer1 = makeAddr("puffer1");
    address puffer2 = makeAddr("puffer2");
    address puffer3 = makeAddr("puffer3");
    address rando = makeAddr("rando");

    address[] testRotation = [puffer1, puffer2, puffer3];

    function setUp() public virtual {
        rotation = new Rotation();
        rotation.initialize(puffer1, TOKEN_NAME, TOKEN_SYMBOL);
    }

    // Initialization

    function test_InitWorks() external {
        assertEq(rotation.currPuffer(), puffer1);
        assertEq(rotation.name(), TOKEN_NAME);
        assertEq(rotation.symbol(), TOKEN_SYMBOL);
    }

    function test_Revert_MultipleInits() external {
        vm.expectRevert(Rotation.AlreadyInitialized.selector);
        rotation.initialize(puffer1, TOKEN_NAME, TOKEN_SYMBOL);
    }

    // Minting

    function test_CurrPufferCanMint() external {
        vm.prank(puffer1);
        rotation.mint(puffer1, "ipfs://puff", puffer2);

        assertEq(rotation.ownerOf(1), puffer1);
        assertEq(rotation.totalSupply(), 1);
        assertEq(rotation.currPuffer(), puffer2);
        assertEq(rotation.tokenURI(1), "ipfs://puff");
    }

    function test_Revert_NextPufferNobody() external {
        vm.expectRevert(Rotation.AddressZeroNoPuff.selector);
        vm.prank(puffer1);
        rotation.mint(puffer1, "ipfs://puff", address(0));
    }

    function test_Revert_DoublePuff() external {
        vm.expectRevert(Rotation.UnlawfulDoublePuffAttempted.selector);
        vm.prank(puffer1);
        rotation.mint(puffer1, "ipfs://puff", puffer1);
    }

    function test_Revert_RandoCantMint() external {
        vm.expectRevert(Rotation.UnauthorizedPuff.selector);
        vm.prank(rando);
        rotation.mint(rando, "ipfs://puff", puffer2);
    }

    function test_rotationCanMint() external {
        for (uint256 i = 0; i < testRotation.length; i++) {
            // Mint
            address puffer = testRotation[i];
            address nextPuffer = i == testRotation.length - 1 ? testRotation[0] : testRotation[i + 1];
            string memory uri = string.concat("ipfs://puff-", (i + 1).toString());
            vm.prank(puffer);
            rotation.mint(puffer, uri, nextPuffer);

            // Verify
            assertEq(rotation.ownerOf(i + 1), puffer);
            assertEq(rotation.tokenURI(i + 1), uri);
        }
        assertEq(rotation.totalSupply(), 3);
    }

    // TokenURI

    function test_Revert_TokenURIForNonExistentToken() external {
        vm.expectRevert(ERC721.TokenDoesNotExist.selector);
        rotation.tokenURI(1);
    }
}
