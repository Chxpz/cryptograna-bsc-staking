# Deployment Guide: BSC Multi-Token Staking System

## 1. Prerequisites

### 1.1 Environment Setup
```bash
# Required tools
- Node.js (v16+)
- npm/yarn
- Hardhat/Foundry
- BSC Node access
- BSCScan API key
```

### 1.2 Configuration
```javascript
// .env file
BSC_RPC_URL=https://bsc-dataseed.binance.org/
PRIVATE_KEY=your_private_key
BSCSCAN_API_KEY=your_bscscan_api_key
```

## 2. Deployment Scripts

### 2.1 Main Deployment Script
```solidity
// scripts/deploy.js
async function main() {
    // 1. Deploy TokenRegistry
    const TokenRegistry = await ethers.getContractFactory("TokenRegistry");
    const tokenRegistry = await TokenRegistry.deploy();
    await tokenRegistry.deployed();
    console.log("TokenRegistry deployed to:", tokenRegistry.address);

    // 2. Deploy RewardManager
    const RewardManager = await ethers.getContractFactory("RewardManager");
    const rewardManager = await RewardManager.deploy();
    await rewardManager.deployed();
    console.log("RewardManager deployed to:", rewardManager.address);

    // 3. Deploy StakingSystem
    const StakingSystem = await ethers.getContractFactory("StakingSystem");
    const stakingSystem = await StakingSystem.deploy(
        tokenRegistry.address,
        rewardManager.address
    );
    await stakingSystem.deployed();
    console.log("StakingSystem deployed to:", stakingSystem.address);

    // 4. Initialize contracts
    await initializeContracts(tokenRegistry, rewardManager, stakingSystem);
}
```

### 2.2 Initialization Script
```solidity
// scripts/initialize.js
async function initializeContracts(tokenRegistry, rewardManager, stakingSystem) {
    // 1. Set up roles
    await stakingSystem.grantRole(ADMIN_ROLE, adminAddress);
    await stakingSystem.grantRole(OPERATOR_ROLE, operatorAddress);
    await stakingSystem.grantRole(EMERGENCY_ROLE, emergencyAddress);

    // 2. Configure initial tokens
    await tokenRegistry.whitelistToken(BNB_ADDRESS, {
        minStakeAmount: ethers.utils.parseEther("0.1"),
        cooldownPeriod: 7 * 24 * 60 * 60, // 7 days
        supportsNative: true
    });

    // 3. Set up reward tokens
    await rewardManager.addRewardToken(REWARD_TOKEN_1);
    await rewardManager.addRewardToken(REWARD_TOKEN_2);

    // 4. Configure reward rates
    await rewardManager.setRewardRates(
        BNB_ADDRESS,
        [REWARD_TOKEN_1, REWARD_TOKEN_2],
        [500, 300] // 5% and 3% APY
    );
}
```

## 3. Verification Scripts

### 3.1 Contract Verification
```bash
# Verify TokenRegistry
npx hardhat verify --network bsc <TokenRegistry_Address>

# Verify RewardManager
npx hardhat verify --network bsc <RewardManager_Address>

# Verify StakingSystem
npx hardhat verify --network bsc <StakingSystem_Address> <TokenRegistry_Address> <RewardManager_Address>
```

### 3.2 Post-Deployment Verification
```javascript
// scripts/verify.js
async function verifyDeployment() {
    // 1. Verify contract addresses
    console.log("Verifying contract addresses...");
    
    // 2. Verify role assignments
    console.log("Verifying role assignments...");
    
    // 3. Verify token configurations
    console.log("Verifying token configurations...");
    
    // 4. Verify reward settings
    console.log("Verifying reward settings...");
}
```

## 4. Deployment Parameters

### 4.1 Network Parameters
- BSC Mainnet
  - Chain ID: 56
  - RPC URL: https://bsc-dataseed.binance.org/
  - Block Time: ~3 seconds

- BSC Testnet
  - Chain ID: 97
  - RPC URL: https://data-seed-prebsc-1-s1.binance.org:8545/
  - Block Time: ~3 seconds

### 4.2 Contract Parameters
```javascript
const DEPLOYMENT_PARAMS = {
    // Token Registry
    maxRewardTokens: 5,
    timelockDuration: 24 * 60 * 60, // 24 hours
    
    // Reward Manager
    baseRate: 500, // 5%
    maxVariableAPY: 2000, // 20%
    
    // Staking System
    minStakeAmount: ethers.utils.parseEther("0.1"),
    cooldownPeriod: 7 * 24 * 60 * 60, // 7 days
    fixedLockPeriod: 30 * 24 * 60 * 60 // 30 days
};
```

## 5. Deployment Checklist

### 5.1 Pre-Deployment
- [ ] Environment variables configured
- [ ] Contract parameters reviewed
- [ ] Gas estimates calculated
- [ ] Testnet deployment verified
- [ ] Security audit completed

### 5.2 Deployment Steps
- [ ] Deploy TokenRegistry
- [ ] Deploy RewardManager
- [ ] Deploy StakingSystem
- [ ] Initialize contracts
- [ ] Verify contracts on BSCScan
- [ ] Set up monitoring

### 5.3 Post-Deployment
- [ ] Verify contract addresses
- [ ] Verify role assignments
- [ ] Verify token configurations
- [ ] Verify reward settings
- [ ] Test all main functions
- [ ] Set up monitoring alerts

## 6. Monitoring Setup

### 6.1 Required Monitoring
- Contract events
- Token transfers
- Reward distributions
- Error rates
- Gas usage

### 6.2 Alert Configuration
```javascript
const ALERT_CONFIG = {
    // Contract Events
    events: [
        "Staked",
        "Unstaked",
        "RewardsClaimed",
        "TokenWhitelisted",
        "TokenRemoved"
    ],
    
    // Error Monitoring
    errors: [
        "InsufficientStakeAmount",
        "TokenNotWhitelisted",
        "CooldownPeriodActive",
        "LockPeriodNotEnded"
    ],
    
    // Performance Metrics
    metrics: [
        "TVL",
        "Number of Stakers",
        "Reward Distribution",
        "Gas Usage"
    ]
};
```

## 7. Emergency Procedures

### 7.1 Emergency Pause
```javascript
// scripts/emergency.js
async function emergencyPause() {
    await stakingSystem.pause();
    console.log("System paused");
}
```

### 7.2 Emergency Withdraw
```javascript
async function emergencyWithdraw() {
    await stakingSystem.emergencyWithdraw();
    console.log("Emergency withdrawal executed");
}
```

## 8. Maintenance Procedures

### 8.1 Regular Maintenance
- Monitor TVL
- Check reward distributions
- Verify token configurations
- Update reward rates if needed

### 8.2 Parameter Updates
```javascript
// scripts/update.js
async function updateParameters() {
    // Update reward rates
    await rewardManager.updateRewardRates(...);
    
    // Update token configurations
    await tokenRegistry.updateTokenConfig(...);
    
    // Update system parameters
    await stakingSystem.updateParameters(...);
}
``` 