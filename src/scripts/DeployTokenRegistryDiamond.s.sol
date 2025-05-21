// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Diamond} from "../contracts/diamond/Diamond.sol";
import {DiamondCutFacet} from "../contracts/diamond/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../contracts/diamond/DiamondLoupeFacet.sol";
import {IDiamondCut} from "../contracts/interfaces/IDiamondCut.sol";
import {TokenRegistryFacet} from "../contracts/facets/TokenRegistryFacet.sol";

contract DeployTokenRegistryDiamond is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy core facets
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();

        // Deploy Diamond
        Diamond diamond = new Diamond(msg.sender, address(diamondCutFacet));

        // Deploy TokenRegistryFacet
        TokenRegistryFacet tokenRegistryFacet = new TokenRegistryFacet();

        // Prepare diamondCut
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](2);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors(address(diamondLoupeFacet))
        });
        cut[1] = IDiamondCut.FacetCut({
            facetAddress: address(tokenRegistryFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors(address(tokenRegistryFacet))
        });

        // Add facets to Diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0), "");

        vm.stopBroadcast();

        // console2.log("Diamond deployed at:", address(diamond));
        // console2.log("TokenRegistryFacet deployed at:", address(tokenRegistryFacet));
    }

    function getSelectors(address facet) internal pure returns (bytes4[] memory selectors) {
        // This is a placeholder. In production, use a tool or script to extract selectors.
        // For Foundry, you can use forge introspect or hardcode selectors for now.
        selectors = new bytes4[](0);
    }
} 