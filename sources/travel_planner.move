module travel_planner::travel_planner {

    // Imports
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::package::{Self, Publisher};
    use sui::transfer;
    use sui::table::{Self, Table};

    use std::string::{String};
 
    // Struct definitions
    struct Destination has key {
        id: UID,
        name: String,
        description: String,
    }

    struct Itinerary has key {
        id: UID,
        destination: ID,
        activities: vector<String>,
    }

    struct Plan has key {
        id: UID,
        itinerary: ID,
        accommodation: ID,
        activity: ID,
        transportation: ID,
        budget: ID,
        user: ID,
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
        expenses: Table<String, u64>,
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

    struct TRAVEL_PLANNER has drop {}

    // Module initializer
    fun init(otw: TRAVEL_PLANNER, ctx: &mut TxContext) {
        let publisher = package::claim<TRAVEL_PLANNER>(otw, ctx);
        transfer::share_object(PlatformPublisher {
            id: object::new(ctx),
            publisher,
        });
        transfer::transfer(AdminCap {
            id: object::new(ctx),
        }, tx_context::sender(ctx));
    }

    // Helper functions for creating objects
    fun new_destination(name: String, description: String, ctx: &mut TxContext) : ID {
        let id = object::new(ctx);
        let inner_ = object::uid_to_inner(&id);
        transfer::share_object(Destination {
            id,
            name,
            description,
        });
        inner_
    }

    fun new_itinerary(destination: ID, activities: vector<String>, ctx: &mut TxContext) : ID {
        let id = object::new(ctx);
        let inner_ = object::uid_to_inner(&id);
        transfer::share_object(Itinerary {
            id,
            destination,
            activities,
        });
        inner_
    }

    fun new_accommodation(name: String, description: String, price: u64, ctx: &mut TxContext) : ID {
        let id = object::new(ctx);
        let inner_ = object::uid_to_inner(&id);
        transfer::share_object(Accommodation {
            id,
            name,
            description,
            price,
        });
        inner_
    }

    fun new_activity(name: String, description: String, price: u64, ctx: &mut TxContext) : ID {
        let id = object::new(ctx);
        let inner_ = object::uid_to_inner(&id);
        transfer::share_object(Activity {
            id,
            name,
            description,
            price,
        });
        inner_

    }

    fun new_transportation(mode: String, ctx: &mut TxContext) : ID {
        let id = object::new(ctx);
        let inner_ = object::uid_to_inner(&id);
        transfer::share_object(Transportation {
            id,
            mode,
        });
        inner_
    }

    fun new_budget(total: u64, ctx: &mut TxContext) : ID {
        let id = object::new(ctx);
        let inner_ = object::uid_to_inner(&id);

        transfer::share_object(Budget {
            id,
            total,
            expenses: table::new(ctx),
        });
        inner_
    }

    fun new_user(username: String, email: String, ctx: &mut TxContext) : ID  {
        let id = object::new(ctx);
        let inner_ = object::uid_to_inner(&id);
        transfer::share_object(User {
            id,
            username,
            email,
        });
        inner_
    }

    // Public - Entry functions

    // Create a new travel plan
    public fun new_plan(destination_name: String, destination_description: String, itinerary_activities: vector<String>, accommodation_name: String, accommodation_description: String, accommodation_price: u64, activity_name: String, activity_description: String, activity_price: u64, transportation_mode: String, budget_total: u64, user_username: String, user_email: String, ctx: &mut TxContext) : ID {
        let destination = new_destination(destination_name, destination_description, ctx);
        let itinerary = new_itinerary(destination, itinerary_activities, ctx);
        let accommodation = new_accommodation(accommodation_name, accommodation_description, accommodation_price, ctx);
        let activity = new_activity(activity_name, activity_description, activity_price, ctx);
        let transportation = new_transportation(transportation_mode, ctx);
        let budget = new_budget(budget_total, ctx);
        let user = new_user(user_username, user_email, ctx);

        let id = object::new(ctx);
        let inner_ = object::uid_to_inner(&id);

        transfer::share_object(Plan {
            id,
            itinerary,
            accommodation,
            activity,
            transportation,
            budget,
            user,
        });
        inner_
    }

    // Get publisher details
    fun get_publisher(shared: &PlatformPublisher): &Publisher {
        &shared.publisher
    }
}
