#[allow(unused_variable)]
module travel_planner::travel_planner {

    // Imports
    use sui::transfer;
    use sui::sui::SUI;
    use std::string::{Self, String};
    use sui::coin::{Self, Coin};
    use sui::clock::{Self, Clock};
    use sui::object::{Self, UID, ID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::table::{Self, Table};
    use std::vector;

    // Errors
    const EInsufficientFunds: u64 = 1;
    const EInvalidDestination: u64 = 2;
    const EInvalidUser: u64 = 3;
    const EInvalidPlan: u64 = 4;
    const EInvalidAccommodation: u64 = 5;
    const EInvalidActivity: u64 = 6;

    // Destination

    /// Represents a destination in the travel planner system.
    struct Destination has key {
        id: UID,
        name: String,
        description: String,
    }

    // Itinerary

    /// Represents an itinerary in the travel planner system.
    struct Itinerary has key {
        id: UID,
        destination: UID,
        activities: vector<String>,
    }

    // Plan

    /// Represents a travel plan in the travel planner system.
    struct Plan has key {
        id: UID,
        itinerary: UID,
        accommodation: UID,
        activity: UID,
        transportation: UID,
        budget: UID,
        user: UID,
    }

    // Accommodation

    /// Represents an accommodation in the travel planner system.
    struct Accommodation has key {
        id: UID,
        name: String,
        description: String,
        price: u64,
    }

    // Activity

    /// Represents an activity in the travel planner system.
    struct Activity has key {
        id: UID,
        name: String,
        description: String,
        price: u64,
    }

    // Transportation

    /// Represents transportation in the travel planner system.
    struct Transportation has key {
        id: UID,
        mode: String,
    }

    // Expense

    /// Represents an expense in the budget.
    struct Expense has copy, drop, store {
        name: String,
        amount: u64,
    }

    // Budget

    /// Represents a budget in the travel planner system.
    struct Budget has key {
        id: UID,
        total: u64,
        expenses: vector<Expense>,
    }

    // User

    /// Represents a user in the travel planner system.
    struct User has key {
        id: UID,
        username: String,
        email: String,
        balance: Balance<SUI>,
    }

    // Publisher

    /// Represents a publisher in the travel planner system.
    struct Publisher has key, store {
        id: UID,
        name: String,
    }

    // PlatformPublisher

    /// Represents a platform publisher in the travel planner system.
    struct PlatformPublisher has key {
        id: UID,
        publisher: Publisher,
    }

    // AdminCap

    /// Represents admin capabilities in the travel planner system.
    struct AdminCap has key {
        id: UID,
    }

    // Create a new Destination

    /// Creates a new destination with the given name and description.
    public fun create_destination(ctx: &mut TxContext, name: String, description: String) {
        let destination = Destination {
            id: object::new(ctx),
            name: name,
            description: description,
        };
        transfer::share_object(destination);
    }

    // Create a new User

    /// Creates a new user with the given username and email.
    public fun create_user(ctx: &mut TxContext, username: String, email: String) {
        let user = User {
            id: object::new(ctx),
            username: username,
            email: email,
            balance: balance::zero(),
        };
        transfer::share_object(user);
    }

    // Create a new Itinerary

    /// Creates a new itinerary with the given destination and activities.
    public fun create_itinerary(ctx: &mut TxContext, destination: UID, activities: vector<String>) {
        let itinerary = Itinerary {
            id: object::new(ctx),
            destination: destination,
            activities: activities,
        };
        transfer::share_object(itinerary);
    }

    // Create a new Plan

    /// Creates a new plan with the given itinerary, accommodation, activity, transportation, budget, and user.
    public fun create_plan(
        ctx: &mut TxContext,
        itinerary: UID,
        accommodation: UID,
        activity: UID,
        transportation: UID,
        budget: UID,
        user: UID
    ) {
        let plan = Plan {
            id: object::new(ctx),
            itinerary: itinerary,
            accommodation: accommodation,
            activity: activity,
            transportation: transportation,
            budget: budget,
            user: user,
        };
        transfer::share_object(plan);
    }

    // Create a new Accommodation

    /// Creates a new accommodation with the given name, description, and price.
    public fun create_accommodation(ctx: &mut TxContext, name: String, description: String, price: u64) {
        let accommodation = Accommodation {
            id: object::new(ctx),
            name: name,
            description: description,
            price: price,
        };
        transfer::share_object(accommodation);
    }

    // Create a new Activity

    /// Creates a new activity with the given name, description, and price.
    public fun create_activity(ctx: &mut TxContext, name: String, description: String, price: u64) {
        let activity = Activity {
            id: object::new(ctx),
            name: name,
            description: description,
            price: price,
        };
        transfer::share_object(activity);
    }

    // Create a new Transportation

    /// Creates a new transportation with the given mode.
    public fun create_transportation(ctx: &mut TxContext, mode: String) {
        let transportation = Transportation {
            id: object::new(ctx),
            mode: mode,
        };
        transfer::share_object(transportation);
    }

    // Create a new Budget

    /// Creates a new budget with the given total amount.
    public fun create_budget(ctx: &mut TxContext, total: u64, expenses: vector<Expense>) {
        let budget = Budget {
            id: object::new(ctx),
            total: total,
            expenses: expenses,
        };
        transfer::share_object(budget);
    }

    // Add Expense

    /// Adds an expense to the budget.
    public fun add_expense(budget: &mut Budget, expense_name: String, amount: u64) {
        let expense = Expense { name: expense_name, amount: amount };
        vector::push_back(&mut budget.expenses, expense);
        budget.total = budget.total + amount;
    }

    // Get Plan Info

    /// Returns the details of the given plan.
    public fun get_plan_info(plan: &Plan): (&UID, &UID, &UID, &UID, &UID, &UID) {
        (
            &plan.itinerary,
            &plan.accommodation,
            &plan.activity,
            &plan.transportation,
            &plan.budget,
            &plan.user
        )
    }

    // Get Budget Info

    /// Returns the details of the given budget.
    public fun get_budget_info(budget: &Budget): (u64, vector<Expense>) {
        (budget.total, budget.expenses)
    }
}
