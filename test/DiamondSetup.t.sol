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

contract DiamondSetupTest is Test {
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupeFacet;
    TokenRegistryFacet tokenRegistryFacet;
    
    address owner = address(this);
    address token1 = address(0x1);

    function setUp() public {
        // Deploy facets
        dCutFacet = new DiamondCutFacet();
        dLoupeFacet = new DiamondLoupeFacet();
        tokenRegistryFacet = new TokenRegistryFacet();

        // Deploy diamond with fixed owner
        diamond = new Diamond(owner, address(dCutFacet));

        // Assert owner is set correctly
        address diamondOwner = address(0);
        (bool success, bytes memory data) = address(diamond).call(abi.encodeWithSignature("owner()"));
        if (success && data.length == 32) {
            diamondOwner = abi.decode(data, (address));
        }
        assertEq(diamondOwner, owner, "Diamond owner should be address(this)");

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
            facetAddress: address(dLoupeFacet),
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

    function testDiamondSetup() public {
        // Test that facets were added correctly
        IDiamondLoupe.Facet[] memory facets = IDiamondLoupe(address(diamond)).facets();
        assertEq(facets.length, 3); // DiamondCutFacet + DiamondLoupeFacet + TokenRegistryFacet

        // Test TokenRegistry functionality
        TokenRegistryStorage.TokenParams memory params = TokenRegistryStorage.TokenParams({
            minStakeAmount: 1 ether,
            cooldownPeriod: 7 days,
            supportsNative: false
        });

        // Whitelist a token
        TokenRegistryFacet(address(diamond)).whitelistToken(token1, params);
        assertTrue(TokenRegistryFacet(address(diamond)).isTokenWhitelisted(token1));
    }
} 