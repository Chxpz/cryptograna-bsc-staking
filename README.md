# BSC Multi-Token Staking System

A comprehensive staking system for Binance Smart Chain that supports multiple tokens, including native BNB and BEP-20 tokens, with a hybrid reward mechanism.

## Overview

This staking system allows users to stake multiple tokens and earn rewards through a combination of fixed and variable APY mechanisms. The system is designed with security and flexibility in mind, supporting both native BNB and BEP-20 tokens.

## Core Features

### Token Management
- Support for multiple staking tokens (BEP-20 and native BNB)
- Configurable accepted tokens list with RBAC protection
- Configurable minimum staking amounts per token with RBAC protection
- Token whitelist management system
- Maximum of 5 reward tokens per pool
- Reward token management with 24-hour timelock and weekly change limit

### Reward Mechanism
- Hybrid reward system:
  - 50% Fixed APY rewards
  - 50% Variable rewards based on pool utilization
- Support for multiple reward tokens
- Configurable reward rates with RBAC protection
- Maximum reward cap implementation

#### Variable APY Calculation
The variable APY is calculated using the following formula:
```
Variable APY = Base Rate + TVL Factor + Staker Factor

Where:
- Base Rate: 5% (minimum starting point)
- TVL Factor: (Current TVL / Target TVL) * 10% (up to 10% additional APY)
- Staker Factor: (Number of Stakers / Target Stakers) * 5% (up to 5% additional APY)

Total Variable APY Range: 5% - 20%
```

### Staking Options
1. Fixed Lock Period Staking
   - Fixed APY rewards
   - Configurable lock periods (default: 1 month)
   - Multiple lock period options available
   - Early withdrawal penalty (loss of rewards)

2. Flexible Staking
   - Variable rewards based on pool utilization
   - No lock period
   - Cooldown period implementation
   - Early withdrawal available with penalty

#### Cooldown Period
- Default duration: 7 days
- Configurable per token
- Rationale:
  - Prevents flash loan attacks
  - Balances user experience with security
  - Adaptable to token volatility

### Security Features
- Role-Based Access Control (RBAC) for administrative functions
- Emergency pause functionality
- Secure reward distribution mechanism
- Protected configuration updates
- 24-hour timelock for reward token changes
- Weekly limit on reward token modifications

## Technical Specifications

### Smart Contracts

1. **StakingSystem.sol**
   - Main staking contract
   - Token management
   - Staking operations
   - Reward distribution
   - Pool configuration management

2. **RewardManager.sol**
   - Reward calculation and distribution
   - APY management
   - Pool utilization tracking
   - Variable APY formula implementation
   - Reward token management

3. **TokenRegistry.sol**
   - Token whitelist management
   - Token configuration
   - Minimum stake amounts
   - Cooldown period management

### Administrative Functions
- Add/remove staking tokens
- Set minimum stake amounts
- Update reward rates
- Emergency pause
- Update cooldown periods
- Configure fixed APY rates
- Manage reward tokens (with timelock)
- Update pool parameters

### User Functions
- Stake tokens
- Unstake tokens
- Claim rewards
- View staking positions
- View available rewards
- Check cooldown status
- View current APY rates

## Testing

The project includes comprehensive test coverage for:
- Token management
- Staking operations
- Reward calculations
- Administrative functions
- Edge cases and security scenarios
- APY formula accuracy
- Cooldown period functionality
- Reward token management

## Deployment

Deployment scripts are provided for:
- Mainnet deployment
- Testnet deployment
- Contract verification
- Initial configuration
- Pool parameter setup

## Security Considerations

- All administrative functions are protected by RBAC
- Emergency pause functionality for critical situations
- Secure reward distribution mechanism
- Protected configuration updates
- Timelock for critical parameter changes
- Weekly limits on reward token modifications
- Cooldown period protection against flash loans

## Future Enhancements (Backlog)
- Staking tiers implementation
- Referral system
- Multiple staking pools
- Governance mechanism
- Timelock implementation
- Multi-signature requirements

## Development Setup

1. Install dependencies:
```bash
forge install
```

2. Compile contracts:
```bash
forge build
```

3. Run tests:
```bash
forge test
```

## License

MIT License

## Disclaimer

This project is for educational purposes. Use at your own risk. 