// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {TokenRegistryStorage} from "../libraries/TokenRegistryStorage.sol";

contract TokenRegistryFacet {
    using TokenRegistryStorage for TokenRegistryStorage.Layout;

    event TokenWhitelisted(address indexed token, TokenRegistryStorage.TokenParams params);
    event TokenRemoved(address indexed token);
    event TokenParamsUpdated(address indexed token, TokenRegistryStorage.TokenParams params);

    function whitelistToken(address _token, TokenRegistryStorage.TokenParams calldata _params) external {
        LibDiamond.enforceIsContractOwner();
        require(_token != address(0), "Zero address");
        require(!isTokenWhitelisted(_token), "Already whitelisted");

        TokenRegistryStorage.Layout storage s = TokenRegistryStorage.layout();
        s.whitelistedTokens[_token] = true;
        s.tokenParams[_token] = _params;
        s.whitelistedTokenList.push(_token);

        emit TokenWhitelisted(_token, _params);
    }

    function removeToken(address _token) external {
        LibDiamond.enforceIsContractOwner();
        require(isTokenWhitelisted(_token), "Not whitelisted");

        TokenRegistryStorage.Layout storage s = TokenRegistryStorage.layout();
        s.whitelistedTokens[_token] = false;
        delete s.tokenParams[_token];

        // Remove from list
        address[] storage list = s.whitelistedTokenList;
        for (uint256 i = 0; i < list.length; i++) {
            if (list[i] == _token) {
                list[i] = list[list.length - 1];
                list.pop();
                break;
            }
        }

        emit TokenRemoved(_token);
    }

    function updateTokenParams(address _token, TokenRegistryStorage.TokenParams calldata _params) external {
        LibDiamond.enforceIsContractOwner();
        require(isTokenWhitelisted(_token), "Not whitelisted");

        TokenRegistryStorage.Layout storage s = TokenRegistryStorage.layout();
        s.tokenParams[_token] = _params;

        emit TokenParamsUpdated(_token, _params);
    }

    function isTokenWhitelisted(address _token) public view returns (bool) {
        return TokenRegistryStorage.layout().whitelistedTokens[_token];
    }

    function getTokenParams(address _token) external view returns (TokenRegistryStorage.TokenParams memory) {
        require(isTokenWhitelisted(_token), "Not whitelisted");
        return TokenRegistryStorage.layout().tokenParams[_token];
    }

    function getWhitelistedTokens() external view returns (address[] memory) {
        return TokenRegistryStorage.layout().whitelistedTokenList;
    }
} 