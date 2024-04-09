module logistics::company {
    // Import necessary types and functions
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::linked_table::{Self, LinkedTable};
    use std::string::String;
    use std::option;

    use logistics::admin::{Self, Admin};

    // Define error codes
    const ERROR_NOT_BALANCE: u64 = 1;
    const ERROR_NOT_ENOUGH_COIN: u64 = 2;
    const ERROR_NOT_ORDERED_COMPANY: u64 = 3;
    const ERROR_NOT_ITEM_OR_RECEIPTED: u64 = 4;
    const ERROR_NOT_REFUNDS: u64 = 5;

    // ====== Company ======

    // Define CompanyCap struct
    struct CompanyCap has key {
        id: UID,
    }

    // Define Company struct
    struct Company has key {
        id: UID,
        name: String,
        price_per_hundred_grams: u64,
        waiting_for_receipt: LinkedTable<ID, ItemInfo>,
        can_be_cashed: Balance<SUI>,
        all_profit: u64,
    }

    // ====== Transport ======

    // Define TransportItem struct
    struct TransportItem has key {
        id: UID,
        logistics_company: String,
        company_id: ID,
        weight: u64,
        price: u64,
    }

    // Define ItemInfo struct
    struct ItemInfo has store {
        epoch: u64,
        transport_price: Balance<SUI>,
    }

    // ====== Company ======

    // Function to create company
    public entry fun create_company(name: String, price_per_hundred_grams: u64, ctx: &mut TxContext) {
        // create CompanyCap and transfer it to the sender
        // this is a testament to the company's managers
        transfer::transfer(CompanyCap {
            id: object::new(ctx),
        }, tx_context::sender(ctx));

        // create Company and share it with all users
        transfer::share_object(Company {
            id: object::new(ctx),
            name,
            price_per_hundred_grams,
            waiting_for_receipt: linked_table::new<ID, ItemInfo>(ctx),
            can_be_cashed: balance::zero(),
            all_profit: 0,
        });
    }

    // Function to unconfirmed receipt items with confirmation epoch greater than 15
    // Company managers can only confirm the company's transport items
    public entry fun confirm_items(_company_cap: &CompanyCap, company: &mut Company, ctx: &mut TxContext) {
        // get the now epoch
        let now_epoch = tx_context::epoch(ctx);

        // to be confirmed list
        let items = &mut company.waiting_for_receipt;

        // theoretically, the linked table is sorted according to epoch
        // because when user call function, linked_table push_back, this is orderly in itself
        loop {
            // items need to be not empty
            if (linked_table::is_empty(items)) break;

            // linked_table::front -> &Option<Element>
            // option::borrow -> &Element
            // in this module, Element is ID
            let key = *option::borrow(linked_table::front(items));

            // linked_table::borrow -> &Value
            // in this module, Value is ItemInfo
            let transport_epoch = linked_table::borrow(items, key).epoch;

            // the front item's epoch is longer than 15
            if (transport_epoch + 15 >= now_epoch) break;

            // pop the front and get the ItemInfo
            let (_, item_info) = linked_table::pop_front(items);

            // destroy ItemInfo and get the price
            let ItemInfo {
                epoch: _,
                transport_price,
            } = item_info;

            // add to the all_profit
            company.all_profit = company.all_profit + balance::value(&transport_price);

            // add the profit
            balance::join(&mut company.can_be_cashed, transport_price);
        };
    }

    // Function to cash
    public entry fun cash(_company_cap: &CompanyCap, admin: &mut Admin, company: &mut Company, ctx: &mut TxContext) {
        // get the amount of balance
        let can_be_cashed = &mut company.can_be_cashed;
        let amount = balance::value(can_be_cashed);

        // check the amount
        assert!(amount > 0, ERROR_NOT_BALANCE);

        // admin profit: 1% of the balance
        let admin_profit = balance::split(can_be_cashed, amount / 100);

        // add to the admin balance
        let admin_balance = admin::get_balance_mut(admin);
        balance::join(admin_balance, admin_profit);

        // the remaining amount belongs to the company
        amount = balance::value(can_be_cashed);
        transfer::public_transfer(coin::take(can_be_cashed, amount, ctx), tx_context::sender(ctx));
    }

    // Function to destroy company
    public entry fun destroy_company(company_cap: CompanyCap, company: Company) {
        // deconstruct the CompanyCap
        let CompanyCap {id} = company_cap;
        // delete the id
        object::delete(id);

        // deconstruct the Company
        let Company {
            id,
            name: _,
            price_per_hundred_grams: _,
            waiting_for_receipt,
            can_be_cashed,
            all_profit: _,
        } = company;

        // delete the id
        object::delete(id);

        // destroy linked_table
        linked_table::destroy_empty(waiting_for_receipt);

        // destroy balance
        balance::destroy_zero(can_be_cashed);
    }

    // ====== Transport ======

    // Function to create transport item
    public entry fun create_item(company: &mut Company, weight: u64, sui: Coin<SUI>, ctx: &mut TxContext) {
        // if the weight is less than 100g, it will be calculated as 100g
        // in other words: weight / 100 rounded up multiply by price_per_hundred_grams
        let price = (weight + 99) / 100 * company.price_per_hundred_grams;

        // check enough price
        assert!(coin::value(&sui) >= price, ERROR_NOT_ENOUGH_COIN);

        // split the right price
        let transport_price = coin::split(&mut sui, price, ctx);

        // destroy or transfer the remaining coin to the owner
        if (coin::value(&sui) == 0) {
            coin::destroy_zero(sui);
        } else {
            transfer::public_transfer(sui, tx_context::sender(ctx));
        };

        // create TransportItem
        let transport_item = TransportItem {
            id: object::new(ctx),
            logistics_company: company.name,
            company_id: object::id(company), // corresponding company ID
            weight,
            price,
        };

        // get the ID through transport_item to achieve a one-on-one relationship
        let id = object::id(&transport_item);

        // create ItemInfo
        let item_infomation = ItemInfo {
            epoch: tx_context::epoch(ctx),
            transport_price: coin::into_balance(transport_price),
        };

        // transfer the credentials to the user
        transfer::transfer(transport_item, tx_context::sender(ctx));

        // store the item_info to the company
        linked_table::push_back(&mut company.waiting_for_receipt, id, item_infomation);
    }

    // Function to destroy TransportItem
    fun destroy_transport_item(transport_item: TransportItem) {
        let TransportItem {
            id,
            logistics_company: _,
            company_id: _,
            weight: _,
            price: _,
        } = transport_item;

        // delete id
        object::delete(id);
    }

    // Function to refunds if no more than 3 epoch
    public entry fun refunds(transport_item: TransportItem, company: &mut Company, ctx: &mut TxContext) {
        // check whether it corresponds to the company
        assert!(transport_item.company_id == object::id(company), ERROR_NOT_ORDERED_COMPANY);
        
        // get waiting_for_receipt
        let waiting_for_receipt = &mut company.waiting_for_receipt;

        // get the ID through transport_item
        let id_key = object::id(&transport_item);

        // determine whether it is the correct item or whether it is receipted
        assert!(linked_table::contains(waiting_for_receipt, id_key), ERROR_NOT_ITEM_OR_RECEIPTED);

        // must not exceed 3 epochs
        assert!(linked_table::borrow(waiting_for_receipt, id_key).epoch + 3 >= tx_context::epoch(ctx), ERROR_NOT_REFUNDS);

        // deconstruct the ItemInfo
        let ItemInfo {
            epoch: _,
            transport_price,
        } = linked_table::remove(waiting_for_receipt, id_key);

        // get the balance amount
        let amount = balance::value(&transport_price);

        // refunds
        transfer::public_transfer(coin::take(&mut transport_price, amount, ctx), tx_context::sender(ctx));

        // destroy the zero balance
        balance::destroy_zero(transport_price);

        // destroy TransportItem
        destroy_transport_item(transport_item);
    }

    // Function to confirm receipt by correct TransportItem
    public entry fun confirm_receipt(transport_item: TransportItem, company: &mut Company) {
        // check whether it corresponds to the company
        assert!(transport_item.company_id == object::id(company), ERROR_NOT_ORDERED_COMPANY);

        // get waiting_for_receipt
        let waiting_for_receipt = &mut company.waiting_for_receipt;

        // get the ID through transport_item
        let id_key = object::id(&transport_item);

        // determine whether it is the correct item or whether it is receipted
        if (linked_table::contains(waiting_for_receipt, id_key)) {
            // deconstruct the ItemInfo
            let ItemInfo {
                epoch: _,
                transport_price,
            } = linked_table::remove(waiting_for_receipt, id_key);

            // add to the all_profit
            company.all_profit = company.all_profit + balance::value(&transport_price);

            // add the profit
            balance::join(&mut company.can_be_cashed, transport_price);
        };

        // destroy TransportItem
        destroy_transport_item(transport_item);
    }
}