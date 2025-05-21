// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {TokenRegistryFacet} from "../src/contracts/facets/TokenRegistryFacet.sol";
import {TokenRegistryStorage} from "../src/contracts/libraries/TokenRegistryStorage.sol";
import {LibDiamond} from "../src/contracts/libraries/LibDiamond.sol";

contract TokenRegistryFacetTest is Test {
    TokenRegistryFacet facet;

    address token1 = address(0x1);
    address token2 = address(0x2);
    TokenRegistryStorage.TokenParams params1 = TokenRegistryStorage.TokenParams({
        minStakeAmount: 1 ether,
        cooldownPeriod: 7 days,
        supportsNative: false
    });
    TokenRegistryStorage.TokenParams params2 = TokenRegistryStorage.TokenParams({
        minStakeAmount: 2 ether,
        cooldownPeriod: 14 days,
        supportsNative: true
    });

    function setUp() public {
        facet = new TokenRegistryFacet();
        LibDiamond.setContractOwner(address(this));
    }

    function testWhitelistToken() public {
        facet.whitelistToken(token1, params1);
        assertTrue(facet.isTokenWhitelisted(token1));
        TokenRegistryStorage.TokenParams memory p = facet.getTokenParams(token1);
        assertEq(p.minStakeAmount, 1 ether);
        assertEq(p.cooldownPeriod, 7 days);
        assertEq(p.supportsNative, false);
    }

    function testCannotWhitelistZeroAddress() public {
        vm.expectRevert(bytes("Zero address"));
        facet.whitelistToken(address(0), params1);
    }

    function testCannotWhitelistAlreadyWhitelisted() public {
        facet.whitelistToken(token1, params1);
        vm.expectRevert(bytes("Already whitelisted"));
        facet.whitelistToken(token1, params1);
    }

    function testRemoveToken() public {
        facet.whitelistToken(token1, params1);
        facet.removeToken(token1);
        assertFalse(facet.isTokenWhitelisted(token1));
    }

    function testCannotRemoveNotWhitelisted() public {
        vm.expectRevert();
        facet.removeToken(token2);
    }

    function testUpdateTokenParams() public {
        facet.whitelistToken(token1, params1);
        facet.updateTokenParams(token1, params2);
        TokenRegistryStorage.TokenParams memory p = facet.getTokenParams(token1);
        assertEq(p.minStakeAmount, 2 ether);
        assertEq(p.cooldownPeriod, 14 days);
        assertEq(p.supportsNative, true);
    }

    function testCannotUpdateParamsNotWhitelisted() public {
        vm.expectRevert();
        facet.updateTokenParams(token2, params2);
    }

    function testGetWhitelistedTokens() public {
        facet.whitelistToken(token1, params1);
        facet.whitelistToken(token2, params2);
        address[] memory tokens = facet.getWhitelistedTokens();
        assertEq(tokens.length, 2);
        assertEq(tokens[0], token1);
        assertEq(tokens[1], token2);
    }
} 