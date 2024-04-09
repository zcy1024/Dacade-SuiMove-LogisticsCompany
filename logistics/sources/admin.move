module logistics::admin {
    // Import necessary types and functions
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin;
    use sui::balance::{Self, Balance};
    use sui::package::{Self, Publisher};

    // Define error code
    const ERROR_NOT_BALANCE: u64 = 0;

    // Define ADMIN(one time witness) struct
    struct ADMIN has drop {}

    // Define Admin struct
    struct Admin has key {
        id: UID,
        balance: Balance<SUI>,
    }

    // Function to init the publisher and admin
    fun init(otw: ADMIN, ctx: &mut TxContext) {
        // create Publisher and transfer it to the sender
        package::claim_and_keep(otw, ctx);

        // create Admin and share it with all users
        transfer::share_object(Admin {
            id: object::new(ctx),
            balance: balance::zero(),
        });
    }

    // Function to withdraw(only the publisher can withdraw)
    public entry fun withdraw(_publisher: &Publisher, admin: &mut Admin, ctx: &mut TxContext) {
        // get the value amount
        let amount = balance::value(&admin.balance);

        // it's necessary to make sure the amount > 0
        assert!(amount > 0, ERROR_NOT_BALANCE);

        // transfer the coin with the all balance to the sender
        transfer::public_transfer(coin::take(&mut admin.balance, amount, ctx), tx_context::sender(ctx));
    }

    // Function to get &mut Balance<SUI> in the Admin for the other module
    public fun get_balance_mut(admin: &mut Admin): &mut Balance<SUI> {
        &mut admin.balance
    }
}