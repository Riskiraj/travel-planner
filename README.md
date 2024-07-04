# Travel Planner Platform Smart Contract

The Travel Planner Platform smart contract provides a comprehensive system for managing travel-related operations including travel agencies, agents, travelers, bookings, and destinations.

## Features

- **Create Travel Agency:** Establish a new travel agency with a name, address, and initial balance.
- **Deposit Funds:** Add funds to the travel agency’s balance for operational needs.
- **Add Travel Agent:** Hire a new travel agent with a name, role, and hire date.
- **Update Travel Agent Info:** Update the information of an existing travel agent.
- **Pay Travel Agent Salary:** Transfer a specified amount from the travel agency’s balance to a travel agent’s balance.
- **Add Traveler:** Register a new traveler with a name, email, and travel history.
- **Update Traveler Info:** Modify the details of an existing traveler.
- **Add Booking:** Create a new booking for a traveler at a specific destination.
- **Cancel Booking:** Remove an existing booking from the travel agency’s records.
- **Add Destination:** Introduce a new destination with a name, location, description, and price per day.
- **Update Destination:** Modify details of an existing destination.
- **Remove Destination:** Delete a destination from the travel agency’s offerings.
- **Pay Expense:** Transfer funds from the travel agency’s balance to cover expenses.
- **Remove Traveler:** Delete a traveler from the travel agency’s records.

## Structs

- **TravelAgency:** Represents a travel agency with details such as name, address, balance, and associated agents, travelers, bookings, and destinations.
- **TravelAgencyCap:** Provides a capability for managing a specific travel agency.
- **TravelAgent:** Represents a travel agent with details like name, role, and hire date.
- **Traveler:** Represents a traveler with personal details and travel history.
- **Booking:** Represents a booking made by a traveler for a destination.
- **Destination:** Represents a travel destination with details like name, location, description, and price per day.

## Usage

### Adding a Travel Agency

```move
let agency_cap = travel_planner::travel_planner::add_travel_agency_info("Travel Agency Name", "Agency Address", &mut ctx);
```

### Depositing Funds

```move
travel_planner::travel_planner::deposit(&mut agency, coin_amount);
```

### Adding a Travel Agent

```move
let agent = travel_planner::travel_planner::add_travel_agent_info("Agent Name", "Agent Role", "2024-01-01", &mut ctx);
```

### Updating Travel Agent Info

```move
travel_planner::travel_planner::update_travel_agent_info(&mut agent, "New Name", "New Role", "2024-01-02", &mut ctx);
```

### Paying a Travel Agent

```move
travel_planner::travel_planner::pay_travel_agent(&mut agency, &mut agent, 1000, &mut ctx);
```

### Adding a Traveler

```move
let traveler = travel_planner::travel_planner::add_traveler_info("Traveler Name", "traveler@example.com", "Travel History", &mut ctx);
```

### Updating Traveler Info

```move
travel_planner::travel_planner::update_traveler_info(&mut traveler, "New Name", "new_email@example.com", "Updated Travel History", &mut ctx);
```

### Adding a Booking

```move
travel_planner::travel_planner::add_booking_info(&mut agency, &mut traveler, &mut destination, "2024-07-01", "2024-07-10", "Booking Details", &mut ctx);
```

### Canceling a Booking

```move
travel_planner::travel_planner::cancel_booking(&mut agency, booking_id);
```

### Adding a Destination

```move
travel_planner::travel_planner::add_destination(&mut agency, "Destination Name", "Destination Location", "Destination Description", 200, &mut ctx);
```

### Updating a Destination

```move
travel_planner::travel_planner::update_destination(&mut agency, destination_id, "New Name", "New Location", "New Description", 250);
```

### Removing a Destination

```move
travel_planner::travel_planner::remove_destination(&mut agency, destination_id);
```

### Paying an Expense

```move
let expense_payment = travel_planner::travel_planner::pay_expense(&mut agency, 500, &mut ctx);
```

### Removing a Traveler

```move
travel_planner::travel_planner::remove_traveler(&mut agency, traveler_id);
```

## Note

- This smart contract employs various structs to manage the components of a travel agency's operations.
- It includes functions for creating, updating, and managing agencies, agents, travelers, bookings, and destinations.
- The contract ensures that only authorized users can perform certain actions, such as updating personal information or making transactions.
- Transactions require sufficient gas for execution and are subject to the Sui blockchain's transaction costs and limits.

## Dependency

- This smart contract is built using the Sui blockchain framework. Ensure you have the Move compiler installed and configured for the appropriate framework.

```bash
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/devnet" }
```

## Installation

To deploy and use the Travel Planner Platform smart contract, follow these steps:

1. **Install the Move Compiler:**
   Ensure that you have the Move compiler installed. For installation instructions, refer to the [Sui documentation](https://docs.sui.io/).

2. **Compile the Smart Contract:**
   Update the dependencies in the `Sui` configuration to match your desired framework (`framework/devnet` or `framework/testnet`), then build the contract.

   ```bash
   sui move build
   ```

3. **Deploy the Contract:**
   Deploy the compiled smart contract to the Sui blockchain using the following command.

   ```bash
   sui client publish --gas-budget 100000000 --json
   ```
