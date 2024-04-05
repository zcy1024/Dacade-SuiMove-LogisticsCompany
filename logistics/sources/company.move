module logistics::company {
    use std::string::{Self, String};

    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};
    use sui::linked_table::{Self as lt, LinkedTable};
    use sui::tx_context::{Self, TxContext, sender};
    use sui::object::{Self, UID, ID};
    use sui::transfer;

    const ERROR_NOT_COMPANY_OWNER: u64 = 0;
    const ERROR_NOT_CLEAR_ITEMS: u64 = 1;
    const ERROR_NOT_CASH_EDALL: u64 = 2;
    const ERROR_NOT_ENOUGH_COIN: u64 = 3;
    const ERROR_NOT_SAME_COMPANY: u64 = 4;
    const ERROR_NOT_ITEM_OR_RECEIPTED: u64 = 5;
    const ERROR_NOT_REFUNDS: u64 = 6;

    // === Constants ===

    const FEE: u128 = 1;

    struct Company has key {
        id: UID,
        name: String,
        price_per_hundred_grams: u64,
        waiting_for_receipt: LinkedTable<ID, ItemInfomation>,
        can_be_cashed: Balance<SUI>,
        all_profit: u64,
        owner: address,
    }

    struct TransportItem has key {
        id: UID,
        logistics_company: String,
        company_id: ID,
        weight: u64,
        price: u64,
    }

    struct ItemInfomation has store {
        epoch: u64,
        transport_price: Balance<SUI>,
        confirm: bool
    }

    struct AdminCap has key {
        id: UID,
        own_address: address,
        balance: Balance<SUI>
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(AdminCap {
            id: object::new(ctx),   
            own_address: tx_context::sender(ctx),
            balance: balance::zero()
        });
    }

    entry fun create_company(name_:String, price_per_hundred_grams: u64, ctx: &mut TxContext) {
        transfer::share_object(Company {
            id: object::new(ctx),
            name: name_,
            price_per_hundred_grams,
            waiting_for_receipt: lt::new<ID, ItemInfomation>(ctx),
            can_be_cashed: balance::zero(),
            all_profit: 0,
            owner: tx_context::sender(ctx),
        });
    }

    entry fun confirm_items(company: &mut Company, item_id :ID, ctx: &TxContext) {
        assert!(company.owner == tx_context::sender(ctx), ERROR_NOT_COMPANY_OWNER);

        let now_epoch = tx_context::epoch(ctx);
        let item = lt::borrow_mut(&mut company.waiting_for_receipt, item_id);

        item.confirm = true;
    }

    entry fun cash(admin: &mut AdminCap, company: &mut Company, ctx: &mut TxContext) {
        assert!(company.owner == tx_context::sender(ctx), ERROR_NOT_COMPANY_OWNER);
        // get total value as u64
        let value = balance::value(&company.can_be_cashed);
        // calculate the sender value 
        let sender_value = value - (((value as u128) * FEE / 100) as u64);
        // set admin fee 
        let admin_fee = value - sender_value;
        // get total balance from company
        let total_balance = balance::withdraw_all(&mut company.can_be_cashed);
        // split admin balance 
        let admin_balance = balance::split(&mut total_balance, admin_fee);
        // join admin balance 
        balance::join(&mut admin.balance, admin_balance);
        // convert the rest balance to coin 
        let coin_ = coin::from_balance( total_balance, ctx);
        // send rest of coin to sender 
        transfer::public_transfer(coin_, tx_context::sender(ctx));
    }

    entry fun destroy_company(company:Company, ctx: &mut TxContext) {
        assert!(company.owner == tx_context::sender(ctx), ERROR_NOT_COMPANY_OWNER);
        // you cant check them like this, each module has destroy_empty
        // assert!(company.waiting_for_receipt.is_empty(), ERROR_NOT_CLEAR_ITEMS);
        // assert!(company.can_be_cashed.value() == 0, ERROR_NOT_CASH_EDALL);

        let Company {
            id,
            name: _,
            price_per_hundred_grams: _,
            waiting_for_receipt,
            can_be_cashed,
            all_profit: _,
            owner: _,
        } = company;

        balance::destroy_zero( can_be_cashed);
        lt::destroy_empty(waiting_for_receipt);
        object::delete(id);
    }

    entry fun create_item(company: &mut Company, weight: u64, coin: Coin<SUI>, ctx: &mut TxContext) {
        let price = (weight + 99) / (100 * company.price_per_hundred_grams);
        let coin_ = coin::value(&coin);
        assert!(coin_ > 0 && coin_ >= price, ERROR_NOT_ENOUGH_COIN);

        let transport_price_ = coin::split(&mut coin, price, ctx);
        let transport_balance = coin::into_balance(transport_price_);

        let transport_item = TransportItem {
            id: object::new(ctx),
            logistics_company: company.name,
            company_id: object::id(company),
            weight,
            price,
        };
        
        let inner_ = object::id(&transport_item);
        let item_infomation = ItemInfomation {
            epoch: tx_context::epoch(ctx),
            transport_price: transport_balance,
            confirm: false
        };
        // transfer the item 
        transfer::transfer(transport_item, sender(ctx));
        // transfer the rest coin to sender 
        transfer::public_transfer(coin, sender(ctx));
        // add the iteminformation to LinkedTable
        lt::push_back<ID, ItemInfomation>(&mut company.waiting_for_receipt, inner_, item_infomation);
    }

    fun destroy_transport_item(transport_item: TransportItem) {
        let TransportItem {
            id,
            logistics_company: _,
            company_id: _,
            weight: _,
            price: _,
        } = transport_item;
        object::delete(id);
    }

    entry fun refunds(transport_item: &TransportItem, company: &mut Company, item_info_id: ID, ctx: &mut TxContext) {
        assert!(transport_item.company_id == object::id(company), ERROR_NOT_SAME_COMPANY);
        
        let waiting_for_receipt = lt::remove(&mut company.waiting_for_receipt, item_info_id);
        let id_key = object::id(transport_item);
        assert!(id_key == item_info_id, ERROR_NOT_ITEM_OR_RECEIPTED);
        assert!(waiting_for_receipt.epoch + 3 >= tx_context::epoch(ctx), ERROR_NOT_REFUNDS);

        let ItemInfomation {
            epoch: _,
            transport_price,
            confirm: _
        } = waiting_for_receipt;

        let coin_ = coin::from_balance(transport_price, ctx);
        transfer::public_transfer(coin_, sender(ctx));
    }

    entry fun confirm_receipt(company: &mut Company, transport_item: &TransportItem, item_info_id: ID) {
        assert!(transport_item.company_id == object::id(company), ERROR_NOT_SAME_COMPANY);

        let waiting_for_receipt = lt::remove(&mut company.waiting_for_receipt, item_info_id);
        let id_key = object::id(transport_item);

        assert!(id_key == item_info_id, ERROR_NOT_ITEM_OR_RECEIPTED);

        let ItemInfomation {
            epoch: _,
            transport_price,
            confirm: _
        } = waiting_for_receipt;

        let price_ = balance::value(&transport_price);
        company.all_profit = company.all_profit + price_;
        balance::join(&mut company.can_be_cashed, transport_price);

    }

    public entry fun admin_withdraw(admin: &mut AdminCap, ctx: &mut TxContext) {
        assert!(admin.own_address == sender(ctx), ERROR_NOT_COMPANY_OWNER);
        let balance_ = balance::withdraw_all(&mut admin.balance);
        let coin_ = coin::from_balance(balance_, ctx);

        transfer::public_transfer(coin_, sender(ctx));
    }
}
