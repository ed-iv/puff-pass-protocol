// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import { ERC721 } from "@solady/tokens/ERC721.sol";
import { LibString } from "@solady/utils/LibString.sol";
import { CircleOfPuffs, ICircleOfPuffs } from "../src/CircleOfPuffs.sol";
import { CircleFactory } from "../src/CircleFactory.sol";

contract CircleOfPuffsTest is PRBTest, StdCheats {
    CircleOfPuffs internal circle;
    CircleFactory internal factory;

    address puffer1 = makeAddr("puffer1");
    address puffer2 = makeAddr("puffer2");
    address puffer3 = makeAddr("puffer3");

    event CircleOfPuffsCreated(address indexed circle);

    function setUp() public virtual {
        circle = new CircleOfPuffs();
        factory = new CircleFactory(address(circle));
    }

    function test_setUp() external {
        assertEq(factory.tokenImplementation(), address(circle));
    }

    function test_CreateCircleWorks() external {
        // Deploy
        vm.expectEmit(false, true, true, true);
        emit CircleOfPuffsCreated(address(0));
        CircleOfPuffs c1 = CircleOfPuffs(factory.createCircle(puffer1, "Circle 1", "CIRC1"));
        vm.expectEmit(false, true, true, true);
        emit CircleOfPuffsCreated(address(0));
        CircleOfPuffs c2 = CircleOfPuffs(factory.createCircle(puffer1, "Circle 2", "CIRC2"));

        // Test mints
        vm.prank(puffer1);
        c1.mint(puffer1, "ipfs://c1", puffer2);
        vm.prank(puffer1);
        c2.mint(puffer1, "ipfs://c2", puffer2);

        // Verify
        assertEq(c1.name(), "Circle 1");
        assertEq(c1.symbol(), "CIRC1");
        assertEq(c1.totalSupply(), 1);
        assertEq(c1.ownerOf(1), puffer1);
        assertEq(c1.tokenURI(1), "ipfs://c1");
        assertEq(c1.currPuffer(), puffer2);

        assertEq(c2.name(), "Circle 2");
        assertEq(c2.symbol(), "CIRC2");
        assertEq(c2.totalSupply(), 1);
        assertEq(c2.ownerOf(1), puffer1);
        assertEq(c2.tokenURI(1), "ipfs://c2");
        assertEq(c2.currPuffer(), puffer2);
    }
}
