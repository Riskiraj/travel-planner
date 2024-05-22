#[test_only]
module travel_planner::test_platform {
    use sui::test_scenario::{Self as ts, next_tx, Scenario};
    use sui::coin::{Self, Coin, mint_for_testing};
    use sui::sui::SUI;
    use sui::tx_context::TxContext;
    use sui::object::UID;
    use sui::test_utils::{assert_eq};
    use sui::clock::{Self, Clock};
    use sui::transfer::{Self};

    use std::vector;
    use std::string::{Self, String};

    use travel_planner::platform::{Self, Plan, new_plan};

    const ADMIN: address = @0xA;
    const TEST_ADDRESS1: address = @0xB;
    const TEST_ADDRESS2: address = @0xC;
    const TEST_ADDRESS3: address = @0xD;

    #[test]
    public fun test_platform() {

        let scenario_test = ts::begin(ADMIN);
        let scenario = &mut scenario_test;

        // Initialize the platform
        next_tx(scenario, ADMIN); 
        {
            let clock = clock::create_for_testing(ts::ctx(scenario));
            platform::init(platform::PLATFORM {}, ts::ctx(scenario));

            clock::share_for_testing(clock); 
        };

        // Create a new plan
        next_tx(scenario, TEST_ADDRESS1); 
        {
            let plan = new_plan(
                "Paris".to_string(),
                "A beautiful city known for its art and culture.".to_string(),
                vec!["Visit Louvre Museum".to_string(), "Eiffel Tower".to_string()],
                "Hotel ABC".to_string(),
                "Luxurious hotel with a view of the city.".to_string(),
                500,
                "Guided City Tour".to_string(),
                "Explore the city with a professional guide.".to_string(),
                100,
                "Train".to_string(),
                1000,
                vec![("Food".to_string(), 300), ("Transportation".to_string(), 400)],
                "John Doe".to_string(),
                "john@example.com".to_string(),
                ts::ctx(scenario)
            );

            // Assert plan details
            // Example assertions
            assert_eq(plan.itinerary.destination.name, "Paris");
            assert_eq(plan.accommodation.name, "Hotel ABC");
            assert_eq(plan.activity.name, "Guided City Tour");
            assert_eq(plan.transportation.mode, "Train");

            ts::return_to_sender(scenario, plan);
        };

        // Add more test scenarios as needed

        ts::end(scenario_test);
    }
}
