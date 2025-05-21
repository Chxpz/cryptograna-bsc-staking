// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IStakingSystem {
    // Structs
    struct StakingPosition {
        uint256 amount;
        uint256 startTime;
        uint256 lockEndTime;
        uint256 lastRewardTime;
        uint256 accumulatedRewards;
        bool isFixed;
    }

    struct TokenConfig {
        uint256 minStakeAmount;
        uint256 cooldownPeriod;
        uint256 fixedLockPeriod;
        uint256 maxRewardTokens;
        bool isActive;
    }

    // Events
    event Staked(address indexed user, address indexed token, uint256 amount, bool isFixed);
    event Unstaked(address indexed user, address indexed token, uint256 amount);
    event RewardsClaimed(address indexed user, address indexed rewardToken, uint256 amount);
    event TokenWhitelisted(address indexed token);
    event TokenRemoved(address indexed token);

    // Functions
    function stake(address token, uint256 amount, bool isFixed) external payable;
    function unstake(address token) external;
    function claimRewards(address token) external;
    function getStakingPosition(address user, address token) external view returns (StakingPosition memory);
    function getTotalStaked(address token) external view returns (uint256);
    function getAvailableRewards(address user, address token) external view returns (uint256);
} 