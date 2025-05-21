// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITokenRegistry {
    // Structs
    struct TokenParams {
        uint256 minStakeAmount;
        uint256 cooldownPeriod;
        bool supportsNative;
    }

    // Events
    event TokenWhitelisted(address indexed token, TokenParams params);
    event TokenRemoved(address indexed token);
    event TokenParamsUpdated(address indexed token, TokenParams params);

    // Functions
    function whitelistToken(address token, TokenParams calldata params) external;
    function removeToken(address token) external;
    function updateTokenParams(address token, TokenParams calldata params) external;
    function isTokenWhitelisted(address token) external view returns (bool);
    function getTokenParams(address token) external view returns (TokenParams memory);
    function validateToken(address token) external view returns (bool);
    function validateAmount(address token, uint256 amount) external view returns (bool);
} 