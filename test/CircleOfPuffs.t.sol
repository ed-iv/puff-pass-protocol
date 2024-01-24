// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { ERC721 } from "@solady/tokens/ERC721.sol";
import { LibString } from "@solady/utils/LibString.sol";
import { CircleOfPuffs } from "../src/CircleOfPuffs.sol";

contract CircleOfPuffsTest is PRBTest, StdCheats {
    using LibString for uint256;

    CircleOfPuffs internal circle;

    string constant TOKEN_NAME = "Founder's Circle";
    string constant TOKEN_SYMBOL = "CIRC1";

    address puffer1 = makeAddr("puffer1");
    address puffer2 = makeAddr("puffer2");
    address puffer3 = makeAddr("puffer3");
    address rando = makeAddr("rando");

    address[] testCircle = [puffer1, puffer2, puffer3];

    function setUp() public virtual {
        circle = new CircleOfPuffs();
        circle.initialize(puffer1, TOKEN_NAME, TOKEN_SYMBOL);
    }

    // Initialization

    function test_InitWorks() external {
        assertEq(circle.currPuffer(), puffer1);
        assertEq(circle.name(), TOKEN_NAME);
        assertEq(circle.symbol(), TOKEN_SYMBOL);
    }

    function test_Revert_MultipleInits() external {
        vm.expectRevert(CircleOfPuffs.AlreadyInitialized.selector);
        circle.initialize(puffer1, TOKEN_NAME, TOKEN_SYMBOL);
    }

    // Minting

    function test_CurrPufferCanMint() external {
        vm.prank(puffer1);
        circle.mint(puffer1, "ipfs://puff", puffer2);

        assertEq(circle.ownerOf(1), puffer1);
        assertEq(circle.totalSupply(), 1);
        assertEq(circle.currPuffer(), puffer2);
        assertEq(circle.tokenURI(1), "ipfs://puff");
    }

    function test_Revert_NextPufferNobody() external {
        vm.expectRevert(CircleOfPuffs.AddressZeroNoPuff.selector);
        vm.prank(puffer1);
        circle.mint(puffer1, "ipfs://puff", address(0));
    }

    function test_Revert_DoublePuff() external {
        vm.expectRevert(CircleOfPuffs.UnlawfulDoublePuffAttempted.selector);
        vm.prank(puffer1);
        circle.mint(puffer1, "ipfs://puff", puffer1);
    }

    function test_Revert_RandoCantMint() external {
        vm.expectRevert(CircleOfPuffs.UnauthorizedPuff.selector);
        vm.prank(rando);
        circle.mint(rando, "ipfs://puff", puffer2);
    }

    function test_CircleCanMint() external {
        for (uint256 i = 0; i < testCircle.length; i++) {
            // Mint
            address puffer = testCircle[i];
            address nextPuffer = i == testCircle.length - 1 ? testCircle[0] : testCircle[i + 1];
            string memory uri = string.concat("ipfs://puff-", (i + 1).toString());
            vm.prank(puffer);
            circle.mint(puffer, uri, nextPuffer);

            // Verify
            assertEq(circle.ownerOf(i + 1), puffer);
            assertEq(circle.tokenURI(i + 1), uri);
        }
        assertEq(circle.totalSupply(), 3);
    }

    // TokenURI

    function test_Revert_TokenURIForNonExistentToken() external {
        vm.expectRevert(ERC721.TokenDoesNotExist.selector);
        circle.tokenURI(1);
    }
}
