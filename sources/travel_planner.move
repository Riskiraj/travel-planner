#[allow(unused_const)]
module travel_planner::travel_planner {
    use sui::transfer;
    use sui::sui::SUI;
    use std::string::String;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::table::{Self, Table};

    // Errors
    const EInsufficientBalance: u64 = 1;
    const ENotTravelAgency: u64 = 2;
    const ENotTravelAgent: u64 = 3;
    const ENotTraveler: u64 = 4;
    const ENotBooking: u64 = 5;
    const ENotAuthorized: u64 = 6;

    // Structs
    struct TravelAgency has key, store {
        id: UID,
        name: String,
        address: String,
        balance: Balance<SUI>,
        agents: Table<ID, TravelAgent>,
        travelers: Table<ID, Traveler>,
        bookings: Table<ID, Booking>,
        destinations: Table<ID, Destination>,
        principal: address,
    }

    struct TravelAgencyCap has key {
        id: UID,
        for: ID,
    }

    struct TravelAgent has key, store {
        id: UID,
        name: String,
        role: String,
        principal: address,
        balance: Balance<SUI>,
        hireDate: String,
    }

    struct Traveler has key, store {
        id: UID,
        name: String,
        email: String,
        principal: address,
        travelHistory: String,
    }

    struct Booking has key, store {
        id: UID,
        traveler: address,
        destination: ID,
        startDate: String,
        endDate: String,
        details: String,
    }

    struct Destination has key, store {
        id: UID,
        name: String,
        location: String,
        description: String,
        price_per_day: u64,
    }

    // Travel Agency methods

    /// Adds information about a new travel agency.
    ///
    /// Returns a `TravelAgencyCap` object representing the capability to manage the travel agency.
    public fun add_travel_agency_info(
        name: String,
        address: String,
        ctx: &mut TxContext
    ) : TravelAgencyCap {
        let id = object::new(ctx);
        let inner = object::uid_to_inner(&id);
        let travel_agency = TravelAgency {
            id,
            name,
            address,
            balance: balance::zero<SUI>(),
            principal: tx_context::sender(ctx),
            agents: table::new<ID, TravelAgent>(ctx),
            travelers: table::new<ID, Traveler>(ctx),
            bookings: table::new<ID, Booking>(ctx),
            destinations: table::new<ID, Destination>(ctx),
        };
        transfer::share_object(travel_agency);

        TravelAgencyCap {
            id: object::new(ctx),
            for: inner,
        }
    }

    /// Deposits funds into the travel agency's balance.
    ///
    /// Takes a `Coin<SUI>` amount and adds it to the travel agency's balance.
    public fun deposit(
        agency: &mut TravelAgency,
        amount: Coin<SUI>,
    ) {
        let coin = coin::into_balance(amount);
        balance::join(&mut agency.balance, coin);
    }

    // Travel Agent methods

    /// Adds information about a new travel agent.
    ///
    /// Returns a `TravelAgent` object representing the newly added travel agent.
    public fun add_travel_agent_info(
        name: String,
        role: String,
        hireDate: String,
        ctx: &mut TxContext
    ) : TravelAgent {
        let id = object::new(ctx);
        TravelAgent {
            id,
            name,
            role,
            principal: tx_context::sender(ctx),
            balance: balance::zero<SUI>(),
            hireDate,
        }
    }

    /// Updates information about an existing travel agent.
    ///
    /// Requires authorization from the travel agent themselves.
    public fun update_travel_agent_info(
        agent: &mut TravelAgent,
        name: String,
        role: String,
        hireDate: String,
        ctx: &mut TxContext
    ) {
        assert!(agent.principal == tx_context::sender(ctx), ENotAuthorized);
        agent.name = name;
        agent.role = role;
        agent.hireDate = hireDate;
    }

    // Pay travel agent salary

    /// Pays salary to a travel agent from the travel agency's balance.
    ///
    /// Takes an `amount` to be paid and transfers it from travel agency to the travel agent.
    public fun pay_travel_agent(
        agency: &mut TravelAgency,
        agent: &mut TravelAgent,
        amount: u64,
        ctx: &mut TxContext
    ) {
        assert!(balance::value(&agency.balance) >= amount, EInsufficientBalance);
        let payment = coin::take(&mut agency.balance, amount, ctx);
        coin::put(&mut agent.balance, payment);
    }

    // Traveler methods

    /// Adds information about a new traveler.
    ///
    /// Returns a `Traveler` object representing the newly added traveler.
    public fun add_traveler_info(
        name: String,
        email: String,
        travelHistory: String,
        ctx: &mut TxContext
    ) : Traveler {
        let id = object::new(ctx);
        Traveler {
            id,
            name,
            email,
            principal: tx_context::sender(ctx),
            travelHistory,
        }
    }

    /// Updates information about an existing traveler.
    ///
    /// Requires authorization from the traveler themselves.
    public fun update_traveler_info(
        traveler: &mut Traveler,
        name: String,
        email: String,
        travelHistory: String,
        ctx: &mut TxContext
    ) {
        assert!(traveler.principal == tx_context::sender(ctx), ENotAuthorized);
        traveler.name = name;
        traveler.email = email;
        traveler.travelHistory = travelHistory;
    }

    // Booking methods

    /// Adds information about a new booking.
    ///
    /// Creates a new booking for a traveler at a specific destination.
    public fun add_booking_info(
        agency: &mut TravelAgency,
        traveler: &mut Traveler,
        destination: &mut Destination,
        startDate: String,
        endDate: String,
        details: String,
        ctx: &mut TxContext
    ) {
        let id = object::new(ctx);
        let booking = Booking {
            id,
            traveler: traveler.principal,
            destination: object::uid_to_inner(&destination.id),
            startDate,
            endDate,
            details,
        };

        table::add<ID, Booking>(&mut agency.bookings, object::uid_to_inner(&booking.id), booking);
    }

    /// Cancels an existing booking.
    ///
    /// Removes the booking from travel agency's records and deletes associated data.
    public fun cancel_booking(
        agency: &mut TravelAgency,
        booking: ID,
    ) {
        let booking = table::remove(&mut agency.bookings, booking);
        let Booking {
            id,
            traveler: _,
            destination: _,
            startDate: _,
            endDate: _,
            details: _,
        } = booking;
        object::delete(id);
    }

    // Destination methods

    /// Adds a new destination to the travel agency's offerings.
    ///
    /// Returns nothing.
    public fun add_destination(
        agency: &mut TravelAgency,
        name: String,
        location: String,
        description: String,
        price_per_day: u64,
        ctx: &mut TxContext
    ) {
        let id = object::new(ctx);
        let destination = Destination {
            id,
            name,
            location,
            description,
            price_per_day,
        };

        table::add<ID, Destination>(&mut agency.destinations, object::uid_to_inner(&destination.id), destination);
    }

    /// Updates an existing destination's details.
    ///
    /// Takes `destination_id`, `name`, `location`, `description`, and `price_per_day`, and updates the destination.
    public fun update_destination(
        agency: &mut TravelAgency,
        destination_id: ID,
        name: String,
        location: String,
        description: String,
        price_per_day: u64,
    ) {
        let destination = table::borrow_mut(&mut agency.destinations, destination_id);
        destination.name = name;
        destination.location = location;
        destination.description = description;
        destination.price_per_day = price_per_day;
    }

    /// Removes a destination from the travel agency's offerings.
    ///
    /// Deletes the destination from the destinations table and associated data.
    public fun remove_destination(
        agency: &mut TravelAgency,
        destination_id: ID,
    ) {
        let destination = table::remove(&mut agency.destinations, destination_id);
        let Destination { id, name: _, location: _, description: _, price_per_day: _ } = destination;
        object::delete(id);
    }

    // Handle travel agency expenses

    /// Pays an expense from travel agency's balance.
    ///
    /// Takes `amount` and transfers it out from travel agency's balance.
    public fun pay_expense(
        agency: &mut TravelAgency,
        amount: u64,
        ctx: &mut TxContext
    ) : Coin<SUI> {
        assert!(balance::value(&agency.balance) >= amount, EInsufficientBalance);
        let payment = coin::take(&mut agency.balance, amount, ctx);
        payment
    }

    /// Removes a traveler from the travel agency's records.
    ///
    /// Deletes the traveler from the travelers table and associated data.
    public fun remove_traveler(
        agency: &mut TravelAgency,
        traveler_id: ID,
    ) {
        let traveler = table::remove(&mut agency.travelers, traveler_id);
        let Traveler { id, name: _, email: _, principal: _, travelHistory: _ } = traveler;
        object::delete(id);
    } 
}
