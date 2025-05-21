// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import { Diamond } from "../src/contracts/diamond/Diamond.sol";
import { DiamondCutFacet } from "../src/contracts/diamond/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "../src/contracts/diamond/DiamondLoupeFacet.sol";
import { TokenRegistryFacet } from "../src/contracts/facets/TokenRegistryFacet.sol";
import { LibDiamond } from "../src/contracts/libraries/LibDiamond.sol";
import { IDiamondCut } from "../src/contracts/interfaces/IDiamondCut.sol";
import { IDiamondLoupe } from "../src/contracts/interfaces/IDiamondLoupe.sol";
import { TokenRegistryStorage } from "../src/contracts/libraries/TokenRegistryStorage.sol";

contract TestDiamond is Test {
    Diamond public diamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    TokenRegistryFacet public tokenRegistryFacet;

    function setUp() public {
        // Deploy facets
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        tokenRegistryFacet = new TokenRegistryFacet();

        // Deploy diamond
        diamond = new Diamond(address(this), address(diamondCutFacet));

        // Prepare selectors for all facets
        bytes4[] memory cutSelectors = new bytes4[](1);
        cutSelectors[0] = DiamondCutFacet.diamondCut.selector;

        bytes4[] memory loupeSelectors = new bytes4[](4);
        loupeSelectors[0] = IDiamondLoupe.facets.selector;
        loupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        loupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        loupeSelectors[3] = IDiamondLoupe.facetAddress.selector;

        bytes4[] memory registrySelectors = new bytes4[](6);
        registrySelectors[0] = TokenRegistryFacet.whitelistToken.selector;
        registrySelectors[1] = TokenRegistryFacet.removeToken.selector;
        registrySelectors[2] = TokenRegistryFacet.updateTokenParams.selector;
        registrySelectors[3] = TokenRegistryFacet.isTokenWhitelisted.selector;
        registrySelectors[4] = TokenRegistryFacet.getTokenParams.selector;
        registrySelectors[5] = TokenRegistryFacet.getWhitelistedTokens.selector;

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(diamondCutFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: cutSelectors
        });
        cut[1] = IDiamondCut.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });
        cut[2] = IDiamondCut.FacetCut({
            facetAddress: address(tokenRegistryFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: registrySelectors
        });

        // Add all facet functions to the diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0), "");
    }

    function testWhitelistTokenAsOwner() public {
        TokenRegistryStorage.TokenParams memory params = TokenRegistryStorage.TokenParams({
            minStakeAmount: 1,
            cooldownPeriod: 100,
            supportsNative: false
        });
        address token = address(0x123);
        TokenRegistryFacet(address(diamond)).whitelistToken(token, params);
        bool whitelisted = TokenRegistryFacet(address(diamond)).isTokenWhitelisted(token);
        assertTrue(whitelisted, "Token should be whitelisted");
    }

    function testDiamondCutSelectorRouting() public {
        bytes4 selector = IDiamondCut.diamondCut.selector;
        address facet = IDiamondLoupe(address(diamond)).facetAddress(selector);
        emit log_named_address("Facet address for diamondCut selector", facet);
        assertEq(facet, address(diamondCutFacet));
    }
} 