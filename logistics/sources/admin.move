module logistics::admin {
    public struct AdminCap has key {
        id: UID,
        own_address: address,
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(AdminCap {
            id: object::new(ctx),
            own_address: tx_context::sender(ctx),
        });
    }

    public fun get_address(admin: &AdminCap): address {
        admin.own_address
    }
}