# Travel Planner Platform Smart Contract


The Travel Planner Platform smart contract enables users to create, manage, and interact with travel plans, including destinations, itineraries, accommodations, activities, transportation, budgets, and user information.

## Features

- **Create Plan:** Create a new travel plan with details such as destination, itinerary, accommodation, activity, transportation, budget, and user information.
- **Get Plan:** Retrieve a specific travel plan by its ID.
- **Update Plan:** Update an existing travel plan with new information.
- **Delete Plan:** Remove a travel plan from the platform.
- **List All Plans:** Retrieve a list of all travel plans stored in the platform.

## Note

- This smart contract utilizes various structs to represent different components of a travel plan.
- It provides functions to handle plan creation, retrieval, updating, and deletion.
- Access control mechanisms can be implemented to restrict certain operations to authorized users only.
- Transactions such as creating, updating, and deleting plans require sufficient gas for execution.

## Dependency

- This DApp relies on the Sui blockchain framework for its smart contract functionality.
- Ensure you have the Move compiler installed and configured to the appropriate framework (e.g., `framework/devnet` for Devnet or `framework/testnet` for Testnet).

```bash
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/devnet" }
```

## Installation

Follow these steps to deploy and use the Travel Planner Platform:

1. **Move Compiler Installation:**
   Ensure you have the Move compiler installed. Refer to the [Sui documentation](https://docs.sui.io/) for installation instructions.

2. **Compile the Smart Contract:**
   Switch the dependencies in the `Sui` configuration to match your chosen framework (`framework/devnet` or `framework/testnet`), then build the contract.

   ```bash
   sui move build
   ```

3. **Deployment:**
   Deploy the compiled smart contract to your chosen blockchain platform using the Sui command-line interface.

   ```bash
   sui client publish --gas-budget 100000000 --json
   ```

