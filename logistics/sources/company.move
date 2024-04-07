module logistics::company {
    // Import necessary types and functions
    use std::string::{Self, String};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};
    use sui::linked_table::{Self, LinkedTable};

    use logistics::admin::AdminCap;

    // Define error codes
    const ENOTCOMPANYOWNER: u64 = 0;
    const ENOTCLEARITEMS: u64 = 1;
    const ENOTCASHEDALL: u64 = 2;
    const ENOTENOUGHCOIN: u64 = 3;
    const ENOTSAMECOMPANY: u64 = 4;
    const ENOTITEMORRECEIPTED: u64 = 5;
    const ENOTREFUNDS: u64 = 6;

    // Define Company struct
    public struct Company has key {
        id: UID,
        name: String,
        price_per_hundred_grams: u64,
        waiting_for_receipt: LinkedTable<ID, ItemInformation>,
        can_be_cashed: Balance<SUI>,
        all_profit: u64,
        owner: Principal, // Change to Principal for clarity
    }

    // Define TransportItem struct
    public struct TransportItem has key {
        id: UID,
        logistics_company: String,
        company_id: ID,
        weight: u64,
        price: u64,
    }

    // Define ItemInformation struct
    public struct ItemInformation has store {
        epoch: u64,
        transport_price: Balance<SUI>,
    }

    // Function to create a new company
    entry fun create_company(name: vector<u8>, price_per_hundred_grams: u64, ctx: &mut TxContext) {
        transfer::share_object(Company {
            id: object::new(ctx),
            name: string::utf8(name),
            price_per_hundred_grams,
            waiting_for_receipt: linked_table::new<ID, ItemInformation>(ctx),
            can_be_cashed: balance::zero(),
            all_profit: 0,
            owner: tx_context::caller(),
        });
    }

    // Function to confirm items and update profits
    entry fun confirm_items(company: &mut Company, ctx: &TxContext) {
        assert!(is_company_owner(company, ctx), ENOTCOMPANYOWNER);

        let now_epoch = tx_context::epoch(ctx);
        let items = &mut company.waiting_for_receipt;
        while !items.is_empty() && *&items[*items.front().borrow()].epoch + 15 < now_epoch {
            let (_, item_information) = items.pop_front();
            let ItemInformation {
                epoch: _,
                transport_price,
            } = item_information;
            company.all_profit += transport_price.value();
            company.can_be_cashed.join(transport_price);
        }
    }

    // Function to withdraw profits
    entry fun withdraw_profits(company: &mut Company, admin: &AdminCap, ctx: &mut TxContext) {
        assert!(is_company_owner(company, ctx), ENOTCOMPANYOWNER);
        assert!(company.can_be_cashed.value() > 0, ENOTCASHEDALL);

        let amount = company.can_be_cashed.value();
        transfer::public_transfer(coin::take(&mut company.can_be_cashed, amount, ctx), company.owner);
    }

    // Function to create a transport item
    entry fun create_item(company: &mut Company, weight: u64, mut sui: Coin<SUI>, ctx: &mut TxContext) {
        let price = (weight + 99) / 100 * company.price_per_hundred_grams;
        assert!(sui.value() >= price, ENOTENOUGHCOIN);

        let transport_price = sui.split(price, ctx);
        if sui.value() == 0 {
            sui.destroy_zero();
        } else {
            transfer::public_transfer(sui, tx_context::sender(ctx));
        };

        let transport_item = TransportItem {
            id: object::new(ctx),
            logistics_company: company.name.clone(), // Use clone to avoid ownership issues
            company_id: object::id(company),
            weight,
            price,
        };
        let id = object::id(&transport_item);
        let item_information = ItemInformation {
            epoch: tx_context::epoch(ctx),
            transport_price: transport_price.into_balance(),
        };

        transfer::transfer(transport_item, tx_context::sender(ctx));
        company.waiting_for_receipt.push_back(id, item_information);
    }

    // Function to process refunds for a transport item
    entry fun refunds(transport_item: TransportItem, company: &mut Company, ctx: &mut TxContext) {
        assert!(transport_item.company_id == object::id(company), ENOTSAMECOMPANY);
        
        let waiting_for_receipt = &mut company.waiting_for_receipt;
        let id_key = object::id(&transport_item);
        assert!(waiting_for_receipt.contains(id_key), ENOTITEMORRECEIPTED);
        assert!(*&waiting_for_receipt[id_key].epoch + 3 >= tx_context::epoch(ctx), ENOTREFUNDS);

        let ItemInformation {
            epoch: _,
            mut transport_price,
        } = waiting_for_receipt.remove(id_key);
        let amount = transport_price.value();
        transfer::public_transfer(coin::take(&mut transport_price, amount, ctx), tx_context::sender(ctx));
        transport_price.destroy_zero();

        object::delete(object::id(&transport_item));
    }

    // Function to confirm receipt of a transport item
    entry fun confirm_receipt(transport_item: TransportItem, company: &mut Company) {
        assert!(transport_item.company_id == object::id(company), ENOTSAMECOMPANY);

        let waiting_for_receipt = &mut company.waiting_for_receipt;
        let id_key = object::id(&transport_item);
        if waiting_for_receipt.contains(id_key) {
            let ItemInformation {
                epoch: _,
                transport_price,
            } = waiting_for_receipt.remove(id_key);
            company.all_profit += transport_price.value();
            company.can_be_cashed.join(transport_price);
        };

        object::delete(object::id(&transport_item));
    }

    // Function to check if the caller is the owner of the company
    private fun is_company_owner(company: &Company, ctx: &TxContext) -> bool {
        company.owner == tx_context::caller(ctx)
    }


    // Function to get company details by ID
    public fun get_company_details(company_id: ID) -> Company? {
        object::get(company_id)
    }

    // Function to check if a company exists
    public fun company_exists(company_id: ID) -> bool {
        object::exists(company_id)
    }
}