// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {Diamond} from "../src/contracts/diamond/Diamond.sol";
import {DiamondCutFacet} from "../src/contracts/diamond/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../src/contracts/diamond/DiamondLoupeFacet.sol";
import {TokenRegistryFacet} from "../src/contracts/facets/TokenRegistryFacet.sol";
import {IDiamondCut} from "../src/contracts/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../src/contracts/interfaces/IDiamondLoupe.sol";
import {TokenRegistryStorage} from "../src/contracts/libraries/TokenRegistryStorage.sol";

contract TokenRegistryFacetDiamondTest is Test {
    Diamond diamond;
    TokenRegistryFacet tokenRegistryFacet;

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
        // Deploy facets
        DiamondCutFacet cutFacet = new DiamondCutFacet();
        DiamondLoupeFacet loupeFacet = new DiamondLoupeFacet();
        tokenRegistryFacet = new TokenRegistryFacet();

        // Deploy diamond with test contract as owner
        address owner = address(this);
        diamond = new Diamond(owner, address(cutFacet));

        // Prepare selectors for DiamondLoupeFacet
        bytes4[] memory loupeSelectors = new bytes4[](4);
        loupeSelectors[0] = IDiamondLoupe.facets.selector;
        loupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        loupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        loupeSelectors[3] = IDiamondLoupe.facetAddress.selector;

        // Prepare selectors for TokenRegistryFacet
        bytes4[] memory registrySelectors = new bytes4[](6);
        registrySelectors[0] = TokenRegistryFacet.whitelistToken.selector;
        registrySelectors[1] = TokenRegistryFacet.removeToken.selector;
        registrySelectors[2] = TokenRegistryFacet.updateTokenParams.selector;
        registrySelectors[3] = TokenRegistryFacet.isTokenWhitelisted.selector;
        registrySelectors[4] = TokenRegistryFacet.getTokenParams.selector;
        registrySelectors[5] = TokenRegistryFacet.getWhitelistedTokens.selector;

        // Prepare the cut
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](2);
        
        // Add DiamondLoupeFacet
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(loupeFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });

        // Add TokenRegistryFacet
        cut[1] = IDiamondCut.FacetCut({
            facetAddress: address(tokenRegistryFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: registrySelectors
        });

        // Perform the cut using the external diamondCut function
        DiamondCutFacet(address(diamond)).diamondCut(cut, address(0), "");
    }

    function testWhitelistToken() public {
        TokenRegistryFacet proxy = TokenRegistryFacet(address(diamond));
        proxy.whitelistToken(token1, params1);
        assertTrue(proxy.isTokenWhitelisted(token1));
        TokenRegistryStorage.TokenParams memory p = proxy.getTokenParams(token1);
        assertEq(p.minStakeAmount, 1 ether);
        assertEq(p.cooldownPeriod, 7 days);
        assertEq(p.supportsNative, false);
    }

    function testCannotWhitelistZeroAddress() public {
        TokenRegistryFacet proxy = TokenRegistryFacet(address(diamond));
        vm.expectRevert(bytes("Zero address"));
        proxy.whitelistToken(address(0), params1);
    }

    function testCannotWhitelistAlreadyWhitelisted() public {
        TokenRegistryFacet proxy = TokenRegistryFacet(address(diamond));
        proxy.whitelistToken(token1, params1);
        vm.expectRevert(bytes("Already whitelisted"));
        proxy.whitelistToken(token1, params1);
    }

    function testRemoveToken() public {
        TokenRegistryFacet proxy = TokenRegistryFacet(address(diamond));
        proxy.whitelistToken(token1, params1);
        proxy.removeToken(token1);
        assertFalse(proxy.isTokenWhitelisted(token1));
    }

    function testCannotRemoveNotWhitelisted() public {
        TokenRegistryFacet proxy = TokenRegistryFacet(address(diamond));
        vm.expectRevert();
        proxy.removeToken(token2);
    }

    function testUpdateTokenParams() public {
        TokenRegistryFacet proxy = TokenRegistryFacet(address(diamond));
        proxy.whitelistToken(token1, params1);
        proxy.updateTokenParams(token1, params2);
        TokenRegistryStorage.TokenParams memory p = proxy.getTokenParams(token1);
        assertEq(p.minStakeAmount, 2 ether);
        assertEq(p.cooldownPeriod, 14 days);
        assertEq(p.supportsNative, true);
    }

    function testCannotUpdateParamsNotWhitelisted() public {
        TokenRegistryFacet proxy = TokenRegistryFacet(address(diamond));
        vm.expectRevert();
        proxy.updateTokenParams(token2, params2);
    }

    function testGetWhitelistedTokens() public {
        TokenRegistryFacet proxy = TokenRegistryFacet(address(diamond));
        proxy.whitelistToken(token1, params1);
        proxy.whitelistToken(token2, params2);
        address[] memory tokens = proxy.getWhitelistedTokens();
        assertEq(tokens.length, 2);
        assertEq(tokens[0], token1);
        assertEq(tokens[1], token2);
    }

    function testOwnerAndDiamondCut() public {
        // Check owner
        address owner = address(this);
        address diamondOwner = address(0);
        (bool success, bytes memory data) = address(diamond).call(abi.encodeWithSignature("owner()"));
        if (success && data.length == 32) {
            diamondOwner = abi.decode(data, (address));
        }
        assertEq(diamondOwner, owner, "Diamond owner should be address(this)");

        // Try to perform a diamond cut as owner
        DiamondLoupeFacet loupeFacet = new DiamondLoupeFacet();
        bytes4[] memory loupeSelectors = new bytes4[](4);
        loupeSelectors[0] = IDiamondLoupe.facets.selector;
        loupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        loupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        loupeSelectors[3] = IDiamondLoupe.facetAddress.selector;
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(loupeFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });
        vm.startPrank(owner);
        DiamondCutFacet(address(diamond)).diamondCut(cut, address(0), "");
        vm.stopPrank();
    }
} 