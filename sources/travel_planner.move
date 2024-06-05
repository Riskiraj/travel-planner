module travel_planner::travel_planner {

    // Imports
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::transfer_policy::{Self as tp};
    use sui::package::{Self, Publisher};
    use sui::transfer;
    use std::string::{String};
    use std::vector::{self, Vector};

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
        user: UID,
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
    }

    // Module initializer
    fun init(ctx: &mut TxContext) {
        let publisher = package::claim<PLATFORM>(PLATFORM{}, ctx);
        transfer::share_object(PlatformPublisher {
            id: object::new(ctx),
            publisher,
        });
        transfer::transfer(AdminCap {
            id: object::new(ctx),
        }, tx_context::sender(ctx));
    }

    // Helper functions for creating objects
    fun new_destination(name: String, description: String, ctx: &mut TxContext) -> UID {
        let id = object::new(ctx);
        transfer::share_object(Destination {
            id,
            name,
            description,
        });
        id
    }

    fun new_itinerary(destination: UID, activities: vector<String>, ctx: &mut TxContext) -> UID {
        let id = object::new(ctx);
        transfer::share_object(Itinerary {
            id,
            destination,
            activities,
        });
        id
    }

    fun new_accommodation(name: String, description: String, price: u64, ctx: &mut TxContext) -> UID {
        let id = object::new(ctx);
        transfer::share_object(Accommodation {
            id,
            name,
            description,
            price,
        });
        id
    }

    fun new_activity(name: String, description: String, price: u64, ctx: &mut TxContext) -> UID {
        let id = object::new(ctx);
        transfer::share_object(Activity {
            id,
            name,
            description,
            price,
        });
        id
    }

    fun new_transportation(mode: String, ctx: &mut TxContext) -> UID {
        let id = object::new(ctx);
        transfer::share_object(Transportation {
            id,
            mode,
        });
        id
    }

    fun new_budget(total: u64, expenses: vector<(String, u64)>, ctx: &mut TxContext) -> UID {
        let id = object::new(ctx);
        transfer::share_object(Budget {
            id,
            total,
            expenses,
        });
        id
    }

    fun new_user(username: String, email: String, ctx: &mut TxContext) -> UID {
        let id = object::new(ctx);
        transfer::share_object(User {
            id,
            username,
            email,
        });
        id
    }

    // Public - Entry functions

    /// Create a new travel plan
    public fun new_plan(destination_name: String, destination_description: String, itinerary_activities: vector<String>, accommodation_name: String, accommodation_description: String, accommodation_price: u64, activity_name: String, activity_description: String, activity_price: u64, transportation_mode: String, budget_total: u64, budget_expenses: vector<(String, u64)>, user_username: String, user_email: String, ctx: &mut TxContext) : UID {
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
            user,
        });
        id
    }

    /// Get details of a plan
    public fun get_plan(plan_id: UID): (UID, UID, UID, UID, UID, UID) {
        let plan = borrow_global<Plan>(plan_id);
        (plan.itinerary, plan.accommodation, plan.activity, plan.transportation, plan.budget, plan.user)
    }

    /// Update the entire plan
    public fun update_plan(plan_id: UID, new_itinerary: UID, new_accommodation: UID, new_activity: UID, new_transportation: UID, new_budget: UID, new_user: UID, ctx: &mut TxContext) {
        let plan = borrow_global_mut<Plan>(plan_id);
        plan.itinerary = new_itinerary;
        plan.accommodation = new_accommodation;
        plan.activity = new_activity;
        plan.transportation = new_transportation;
        plan.budget = new_budget;
        plan.user = new_user;
    }

    /// Delete a plan
    public fun delete_plan(plan_id: UID, ctx: &mut TxContext) {
        let plan = withdraw_from_global<Plan>(plan_id);
        move_to(&ctx.sender, plan);
    }

    /// List all plans
    public fun list_all_plans(ctx: &mut TxContext) -> vector<UID> {
        // Placeholder: This should return a vector of all plan IDs in a real implementation
        vector::empty()
    }

    /// Get publisher details
    fun get_publisher(shared: &PlatformPublisher): &Publisher {
        &shared.publisher
    }

    /// Get destination details
    public fun get_destination(destination_id: UID): (String, String) {
        let destination = borrow_global<Destination>(destination_id);
        (destination.name, destination.description)
    }

    /// Get accommodation details
    public fun get_accommodation(accommodation_id: UID): (String, String, u64) {
        let accommodation = borrow_global<Accommodation>(accommodation_id);
        (accommodation.name, accommodation.description, accommodation.price)
    }

    /// Get activity details
    public fun get_activity(activity_id: UID): (String, String, u64) {
        let activity = borrow_global<Activity>(activity_id);
        (activity.name, activity.description, activity.price)
    }

    /// Get transportation details
    public fun get_transportation(transportation_id: UID): String {
        let transportation = borrow_global<Transportation>(transportation_id);
        transportation.mode
    }

    /// Get budget details
    public fun get_budget(budget_id: UID): (u64, vector<(String, u64)>) {
        let budget = borrow_global<Budget>(budget_id);
        (budget.total, budget.expenses)
    }

    /// Get user details
    public fun get_user(user_id: UID): (String, String) {
        let user = borrow_global<User>(user_id);
        (user.username, user.email)
    }

    /// Update destination details
    public fun update_destination(destination_id: UID, new_name: String, new_description: String, ctx: &mut TxContext) {
        let destination = borrow_global_mut<Destination>(destination_id);
        destination.name = new_name;
        destination.description = new_description;
    }

    /// Update accommodation details
    public fun update_accommodation(accommodation_id: UID, new_name: String, new_description: String, new_price: u64, ctx: &mut TxContext) {
        let accommodation = borrow_global_mut<Accommodation>(accommodation_id);
        accommodation.name = new_name;
        accommodation.description = new_description;
        accommodation.price = new_price;
    }

    /// Update activity details
    public fun update_activity(activity_id: UID, new_name: String, new_description: String, new_price: u64, ctx: &mut TxContext) {
        let activity = borrow_global_mut<Activity>(activity_id);
        activity.name = new_name;
        activity.description = new_description;
        activity.price = new_price;
    }

    /// Update transportation details
    public fun update_transportation(transportation_id: UID, new_mode: String, ctx: &mut TxContext) {
        let transportation = borrow_global_mut<Transportation>(transportation_id);
        transportation.mode = new_mode;
    }

    /// Update budget details
    public fun update_budget(budget_id: UID, new_total: u64, new_expenses: vector<(String, u64)>, ctx: &mut TxContext) {
        let budget = borrow_global_mut<Budget>(budget_id);
        budget.total = new_total;
        budget.expenses = new_expenses;
    }

    /// Update user details
    public fun update_user(user_id: UID, new_username: String, new_email: String, ctx: &mut TxContext) {
        let user = borrow_global_mut<User>(user_id);
        user.username = new_username;
        user.email = new_email;
    }
}
