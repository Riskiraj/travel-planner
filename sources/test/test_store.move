// #[test_only]
// module travel_planner::test_platform {
//     use sui::test_scenario::{Self as ts, next_tx, Scenario};
//     use sui::coin::{Self, Coin, mint_for_testing};
//     use sui::sui::SUI;
//     use sui::tx_context::TxContext;
//     use sui::object::UID;
//     use sui::test_utils::{assert_eq};
//     use sui::clock::{Self, Clock};
//     use sui::transfer::{Self};

//     use std::vector;
//     use std::string::{Self, String};

//     use travel_planner::travel_planner::{Self, Plan, new_plan, get_plan, update_plan, delete_plan, list_all_plans, get_destination, get_accommodation, get_activity, get_transportation, get_budget, get_user};

//     const ADMIN: address = @0xA;
//     const TEST_ADDRESS1: address = @0xB;
//     const TEST_ADDRESS2: address = @0xC;
//     const TEST_ADDRESS3: address = @0xD;

//     #[test]
//     public fun test_platform() {
//         let scenario_test = ts::begin(ADMIN);
//         let scenario = &mut scenario_test;

//         // Initialize the platform
//         next_tx(scenario, ADMIN); 
//         {
//             let clock = clock::create_for_testing(ts::ctx(scenario));
//             travel_planner::init(ts::ctx(scenario));
//             clock::share_for_testing(clock); 
//         };

//         // Create a new plan
//         let plan_id: UID;
//         next_tx(scenario, TEST_ADDRESS1); 
//         {
//             plan_id = new_plan(
//                 "Paris".to_string(),
//                 "A beautiful city known for its art and culture.".to_string(),
//                 vec!["Visit Louvre Museum".to_string(), "Eiffel Tower".to_string()],
//                 "Hotel ABC".to_string(),
//                 "Luxurious hotel with a view of the city.".to_string(),
//                 500,
//                 "Guided City Tour".to_string(),
//                 "Explore the city with a professional guide.".to_string(),
//                 100,
//                 "Train".to_string(),
//                 1000,
//                 vec![("Food".to_string(), 300), ("Transportation".to_string(), 400)],
//                 "John Doe".to_string(),
//                 "john@example.com".to_string(),
//                 ts::ctx(scenario)
//             );

//             // Assert plan details
//             let (itinerary_id, accommodation_id, activity_id, transportation_id, budget_id, user_id) = get_plan(plan_id);

//             let (destination_name, destination_description) = get_destination(itinerary_id);
//             assert_eq(destination_name, "Paris");
//             assert_eq(destination_description, "A beautiful city known for its art and culture.");

//             let (accommodation_name, accommodation_description, accommodation_price) = get_accommodation(accommodation_id);
//             assert_eq(accommodation_name, "Hotel ABC");
//             assert_eq(accommodation_description, "Luxurious hotel with a view of the city.");
//             assert_eq(accommodation_price, 500);

//             let (activity_name, activity_description, activity_price) = get_activity(activity_id);
//             assert_eq(activity_name, "Guided City Tour");
//             assert_eq(activity_description, "Explore the city with a professional guide.");
//             assert_eq(activity_price, 100);

//             let transportation_mode = get_transportation(transportation_id);
//             assert_eq(transportation_mode, "Train");

//             let (budget_total, budget_expenses) = get_budget(budget_id);
//             assert_eq(budget_total, 1000);
//             assert_eq(budget_expenses[0], ("Food".to_string(), 300));
//             assert_eq(budget_expenses[1], ("Transportation".to_string(), 400));

//             let (username, email) = get_user(user_id);
//             assert_eq(username, "John Doe");
//             assert_eq(email, "john@example.com");
//         };

//         // Update the plan
//         next_tx(scenario, TEST_ADDRESS1); 
//         {
//             let new_itinerary_id = new_itinerary(
//                 plan_id,
//                 vec!["Visit Notre Dame".to_string(), "Cruise on the Seine".to_string()],
//                 ts::ctx(scenario)
//             );
//             update_plan(
//                 plan_id,
//                 new_itinerary_id,
//                 accommodation_id,
//                 activity_id,
//                 transportation_id,
//                 budget_id,
//                 user_id,
//                 ts::ctx(scenario)
//             );

//             // Assert updated itinerary
//             let (updated_itinerary_id, _, _, _, _, _) = get_plan(plan_id);
//             let (_, updated_activities) = get_itinerary(updated_itinerary_id);
//             assert_eq(updated_activities[0], "Visit Notre Dame".to_string());
//             assert_eq(updated_activities[1], "Cruise on the Seine".to_string());
//         };

//         // List all plans
//         next_tx(scenario, ADMIN); 
//         {
//             let all_plans = list_all_plans(ts::ctx(scenario));
//             assert_eq(vector::contains(all_plans, plan_id), true);
//         };

//         // Delete the plan
//         next_tx(scenario, TEST_ADDRESS1); 
//         {
//             delete_plan(plan_id, ts::ctx(scenario));
//             let all_plans_after_delete = list_all_plans(ts::ctx(scenario));
//             assert_eq(vector::contains(all_plans_after_delete, plan_id), false);
//         };

//         ts::end(scenario_test);
//     }
// }
