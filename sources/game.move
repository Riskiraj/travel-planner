module travel_planner::platform {

    // Imports
    use sui::object::{Self, UID, ObjectRef};
    use sui::tx_context::{Self, TxContext};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::transfer_policy::{Self as tp};
    use sui::package::{Self, Publisher};
    use sui::transfer;
    use std::string::{String};
    use sui::event::emit;
    use sui::errors::{assert, abort};
    use sui::clock::{Clock, timestamp_ms};
    use sui::vector;

    // Error codes
    const EUnauthorized: u64 = 1;
    const EPlanNotFound: u64 = 2;
    const EInvalidInput: u64 = 3;

    // Struct definitions
    struct Destination has key {
        id: UID,
        name: String,
        description: String,
    }

    struct Itinerary has key {
        id: UID,
        destination: UID,
        activities: vector<String>,
    }

    struct Plan has key {
        id: UID,
        itinerary: UID,
        accommodation: UID,
        activity: UID,
        transportation: UID,
        budget: UID,
        user: address,
    }

    struct Accommodation has key {
        id: UID,
        name: String,
        description: String,
        price: u64,
    }

    struct Activity has key {
        id: UID,
        name: String,
        description: String,
        price: u64,
    }

    struct Transportation has key {
        id: UID,
        mode: String,
    }

    struct Budget has key {
        id: UID,
        total: u64,
        expenses: vector<(String, u64)>,
    }

    struct User has key {
        id: UID,
        username: String,
        email: String,
    }

    struct PlatformPublisher has key {
        id: UID,
        publisher: Publisher,
    }

    struct AdminCap has key {
        id: UID,
        admin: address,
    }

    // Module initializer
    public fun init(ctx: &mut TxContext) {
        let publisher = package::claim<PLATFORM>(PLATFORM{}, ctx);
        let admin = tx_context::sender(ctx);
        transfer::share_object(PlatformPublisher {
            id: object::new(ctx),
            publisher,
        });
        transfer::transfer(AdminCap {
            id: object::new(ctx),
            admin,
        }, admin);
    }

    // Helper functions for creating objects
    fun validate_non_empty_string(s: &String, error_code: u64) {
        assert!(string::length(s) > 0, error_code);
    }

    fun validate_price(price: u64, error_code: u64) {
        assert!(price >= 0, error_code);
    }

    public fun new_destination(name: String, description: String, ctx: &mut TxContext) -> UID {
        validate_non_empty_string(&name, EInvalidInput);
        validate_non_empty_string(&description, EInvalidInput);
        let id = object::new(ctx);
        transfer::share_object(Destination {
            id,
            name,
            description,
        });
        id
    }

    public fun new_itinerary(destination: UID, activities: vector<String>, ctx: &mut TxContext) -> UID {
        let id = object::new(ctx);
        transfer::share_object(Itinerary {
            id,
            destination,
            activities,
        });
        id
    }

    public fun new_accommodation(name: String, description: String, price: u64, ctx: &mut TxContext) -> UID {
        validate_non_empty_string(&name, EInvalidInput);
        validate_non_empty_string(&description, EInvalidInput);
        validate_price(price, EInvalidInput);
        let id = object::new(ctx);
        transfer::share_object(Accommodation {
            id,
            name,
            description,
            price,
        });
        id
    }

    public fun new_activity(name: String, description: String, price: u64, ctx: &mut TxContext) -> UID {
        validate_non_empty_string(&name, EInvalidInput);
        validate_non_empty_string(&description, EInvalidInput);
        validate_price(price, EInvalidInput);
        let id = object::new(ctx);
        transfer::share_object(Activity {
            id,
            name,
            description,
            price,
        });
        id
    }

    public fun new_transportation(mode: String, ctx: &mut TxContext) -> UID {
        validate_non_empty_string(&mode, EInvalidInput);
        let id = object::new(ctx);
        transfer::share_object(Transportation {
            id,
            mode,
        });
        id
    }

    public fun new_budget(total: u64, expenses: vector<(String, u64)>, ctx: &mut TxContext) -> UID {
        validate_price(total, EInvalidInput);
        let id = object::new(ctx);
        transfer::share_object(Budget {
            id,
            total,
            expenses,
        });
        id
    }

    public fun new_user(username: String, email: String, ctx: &mut TxContext) -> UID {
        validate_non_empty_string(&username, EInvalidInput);
        validate_non_empty_string(&email, EInvalidInput);
        let id = object::new(ctx);
        transfer::share_object(User {
            id,
            username,
            email,
        });
        id
    }

    // Event logging function
    public fun emit_event(description: String, timestamp: u64) {
        emit!(Event {
            id: object::new(),
            description,
            timestamp,
        });
    }

    // Public - Entry functions
    public fun new_plan(destination_name: String, destination_description: String, itinerary_activities: vector<String>, accommodation_name: String, accommodation_description: String, accommodation_price: u64, activity_name: String, activity_description: String, activity_price: u64, transportation_mode: String, budget_total: u64, budget_expenses: vector<(String, u64)>, user_username: String, user_email: String, ctx: &mut TxContext, clock: &Clock) : UID {
        let timestamp = timestamp_ms(clock);
        let sender = tx_context::sender(ctx);
        let destination = new_destination(destination_name, destination_description, ctx);
        let itinerary = new_itinerary(destination, itinerary_activities, ctx);
        let accommodation = new_accommodation(accommodation_name, accommodation_description, accommodation_price, ctx);
        let activity = new_activity(activity_name, activity_description, activity_price, ctx);
        let transportation = new_transportation(transportation_mode, ctx);
        let budget = new_budget(budget_total, budget_expenses, ctx);
        let user = new_user(user_username, user_email, ctx);

        let id = object::new(ctx);
        transfer::share_object(Plan {
            id,
            itinerary,
            accommodation,
            activity,
            transportation,
            budget,
            user: sender,
        });
        emit_event("New plan created", timestamp);
        id
    }

    public fun get_plan(plan_id: UID): (UID, UID, UID, UID, UID, UID) {
        let plan = borrow_global<Plan>(plan_id);
        (plan.itinerary, plan.accommodation, plan.activity, plan.transportation, plan.budget, plan.user)
    }

    public fun update_plan(plan_id: UID, new_itinerary: UID, new_accommodation: UID, new_activity: UID, new_transportation: UID, new_budget: UID, ctx: &mut TxContext, clock: &Clock) {
        let sender = tx_context::sender(ctx);
        let plan = borrow_global<Plan>(plan_id);
        assert!(plan.user == sender, EUnauthorized);
        let timestamp = timestamp_ms(clock);
        let mut plan = borrow_global_mut<Plan>(plan_id);
        plan.itinerary = new_itinerary;
        plan.accommodation = new_accommodation;
        plan.activity = new_activity;
        plan.transportation = new_transportation;
        plan.budget = new_budget;
        emit_event("Plan updated", timestamp);
    }

    public fun delete_plan(plan_id: UID, ctx: &mut TxContext, clock: &Clock) {
        let sender = tx_context::sender(ctx);
        let plan = borrow_global<Plan>(plan_id);
        assert!(plan.user == sender, EUnauthorized);
        let timestamp = timestamp_ms(clock);
        move_to(&ctx.sender, withdraw_from_global<Plan>(plan_id));
        emit_event("Plan deleted", timestamp);
    }

    public fun list_all_plans(ctx: &mut TxContext) -> vector<UID> {
        // Placeholder: This would return a vector of all plan IDs
        // Implementing this function may require iterating through all Plan objects in storage
        // For simplicity, I returned an empty vector here.
        vector::empty()
    }

    // Helper function to get the publisher
    fun get_publisher(shared: &PlatformPublisher): &Publisher {
        &shared.publisher
    }
}
