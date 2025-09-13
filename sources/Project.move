module MyModule::HabitTracker {
    use aptos_framework::signer;
    use aptos_framework::timestamp;

    /// Struct representing a user's habit tracking data.
    struct HabitData has store, key {
        habit_name: vector<u8>,     // Name of the habit being tracked
        streak_count: u64,          // Current consecutive streak
        last_check_in: u64,         // Timestamp of last check-in
        total_completions: u64,     // Total number of completions
    }

    /// Error codes
    const E_HABIT_NOT_FOUND: u64 = 1;
    const E_ALREADY_CHECKED_IN_TODAY: u64 = 2;

    /// Function to create a new habit for tracking.
    public fun create_habit(user: &signer, habit_name: vector<u8>) {
        let habit_data = HabitData {
            habit_name,
            streak_count: 0,
            last_check_in: 0,
            total_completions: 0,
        };
        move_to(user, habit_data);
    }

    /// Function to check in and update habit progress.
    public fun check_in_habit(user: &signer) acquires HabitData {
        let user_addr = signer::address_of(user);
        assert!(exists<HabitData>(user_addr), E_HABIT_NOT_FOUND);
        
        let habit_data = borrow_global_mut<HabitData>(user_addr);
        let current_time = timestamp::now_seconds();
        let one_day = 86400; // 24 hours in seconds
        
        // Check if already checked in today
        assert!(current_time > habit_data.last_check_in + one_day, E_ALREADY_CHECKED_IN_TODAY);
        
        // Update streak: reset if more than 2 days since last check-in, otherwise increment
        if (current_time > habit_data.last_check_in + (2 * one_day)) {
            habit_data.streak_count = 1;
        } else {
            habit_data.streak_count = habit_data.streak_count + 1;
        };
        
        // Update tracking data
        habit_data.last_check_in = current_time;
        habit_data.total_completions = habit_data.total_completions + 1;
    }
}