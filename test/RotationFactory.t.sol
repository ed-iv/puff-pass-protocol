// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import { ERC721 } from "@solady/tokens/ERC721.sol";
import { LibString } from "@solady/utils/LibString.sol";
import { Rotation, IRotation } from "../src/Rotation.sol";
import { RotationFactory } from "../src/RotationFactory.sol";

contract RotationTest is PRBTest, StdCheats {
    Rotation internal rotation;
    RotationFactory internal factory;

    address puffer1 = makeAddr("puffer1");
    address puffer2 = makeAddr("puffer2");
    address puffer3 = makeAddr("puffer3");

    event RotationCreated(address indexed rotation);

    function setUp() public virtual {
        rotation = new Rotation();
        factory = new RotationFactory(address(rotation));
    }

    function test_setUp() external {
        assertEq(factory.tokenImplementation(), address(rotation));
    }

    function test_CreateRotationWorks() external {
        // Deploy
        vm.expectEmit(false, true, true, true);
        emit RotationCreated(address(0));
        Rotation r1 = Rotation(factory.createRotation(puffer1, "Rotation 1", "R1"));
        vm.expectEmit(false, true, true, true);
        emit RotationCreated(address(0));
        Rotation r2 = Rotation(factory.createRotation(puffer1, "Rotation 2", "R2"));

        // Test mints
        vm.prank(puffer1);
        r1.mint(puffer1, "ipfs://r1", puffer2);
        vm.prank(puffer1);
        r2.mint(puffer1, "ipfs://r2", puffer2);

        // Verify
        assertEq(r1.name(), "Rotation 1");
        assertEq(r1.symbol(), "R1");
        assertEq(r1.totalSupply(), 1);
        assertEq(r1.ownerOf(1), puffer1);
        assertEq(r1.tokenURI(1), "ipfs://r1");
        assertEq(r1.currPuffer(), puffer2);

        assertEq(r2.name(), "Rotation 2");
        assertEq(r2.symbol(), "R2");
        assertEq(r2.totalSupply(), 1);
        assertEq(r2.ownerOf(1), puffer1);
        assertEq(r2.tokenURI(1), "ipfs://r2");
        assertEq(r2.currPuffer(), puffer2);
    }
}
