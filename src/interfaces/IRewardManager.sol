// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IRewardManager {
    // Structs
    struct RewardConfig {
        uint256 baseRate;
        uint256 tvlFactor;
        uint256 stakerFactor;
        uint256 maxVariableAPY;
    }

    // Events
    event RewardTokenAdded(address indexed token);
    event RewardTokenRemoved(address indexed token);
    event RewardRatesUpdated(address indexed stakingToken, address[] rewardTokens, uint256[] rates);

    // Functions
    function addRewardToken(address token) external;
    function removeRewardToken(address token) external;
    function setRewardRates(address stakingToken, address[] calldata rewardTokens, uint256[] calldata rates) external;
    function calculateRewards(address user, address stakingToken) external view returns (uint256);
    function getRewardRate(address stakingToken, address rewardToken) external view returns (uint256);
    function getVariableAPY(address stakingToken) external view returns (uint256);
    function updateAccumulatedRewards(address user, address stakingToken) external;
} 