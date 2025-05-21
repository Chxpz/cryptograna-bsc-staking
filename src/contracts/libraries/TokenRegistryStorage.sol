// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library TokenRegistryStorage {
    bytes32 constant TOKEN_REGISTRY_STORAGE_POSITION = keccak256("token.registry.storage");

    struct TokenParams {
        uint256 minStakeAmount;
        uint256 cooldownPeriod;
        bool supportsNative;
    }

    struct Layout {
        mapping(address => bool) whitelistedTokens;
        mapping(address => TokenParams) tokenParams;
        address[] whitelistedTokenList;
    }

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = TOKEN_REGISTRY_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
} 