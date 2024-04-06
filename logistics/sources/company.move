module logistics::company {
    use std::string::{Self, String};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};
    use sui::linked_table::{Self, LinkedTable};

    use logistics::admin::AdminCap;

    const ENOTCOMPANYOWNER: u64 = 0;
    const ENOTCLEARITEMS: u64 = 1;
    const ENOTCASHEDALL: u64 = 2;
    const ENOTENOUGHCOIN: u64 = 3;
    const ENOTSAMECOMPANY: u64 = 4;
    const ENOTITEMORRECEIPTED: u64 = 5;
    const ENOTREFUNDS: u64 = 6;

    public struct Company has key {
        id: UID,
        name: String,
        price_per_hundred_grams: u64,
        waiting_for_receipt: LinkedTable<ID, ItemInfo>,
        can_be_cashed: Balance<SUI>,
        all_profit: u64,
        owner: address,
    }

    public struct TransportItem has key {
        id: UID,
        logistics_company: String,
        company_id: ID,
        weight: u64,
        price: u64,
    }

    public struct ItemInfo has store {
        epoch: u64,
        transport_price: Balance<SUI>,
    }

    entry fun create_company(name: vector<u8>, price_per_hundred_grams: u64, ctx: &mut TxContext) {
        transfer::share_object(Company {
            id: object::new(ctx),
            name: string::utf8(name),
            price_per_hundred_grams,
            waiting_for_receipt: linked_table::new<ID, ItemInfo>(ctx),
            can_be_cashed: balance::zero(),
            all_profit: 0,
            owner: tx_context::sender(ctx),
        });
    }

    public fun confirm_items(company: &mut Company, ctx: &TxContext) {
        assert!(company.owner == tx_context::sender(ctx), ENOTCOMPANYOWNER);

        let now_epoch = tx_context::epoch(ctx);
        let waiting_for_receipt = &mut company.waiting_for_receipt;
        let mut items_to_confirm = vec![];

        // Collect the items to be confirmed
        waiting_for_receipt.iter(|_, item_info| {
            if *item_info.epoch + 15 < now_epoch {
                items_to_confirm.push((object::id(item_info), *item_info));
            }
        });

        // Confirm the collected items
        for (id, item_info) in items_to_confirm {
            let ItemInfo { epoch: _, transport_price } = item_info;
            company.all_profit += transport_price.value();
            company.can_be_cashed.join(transport_price);
            waiting_for_receipt.remove(&id);
        }
    }

    public entry fun cash(admin: &AdminCap, company: &mut Company, ctx: &mut TxContext) {
        assert!(company.owner == tx_context::sender(ctx), ENOTCOMPANYOWNER);

        let can_be_cashed = &mut company.can_be_cashed;
        let mut amount = can_be_cashed.value();
        if amount == 0 {
            return;
        }

        // Transfer the available cash to the admin and the company owner
        transfer::public_transfer(coin::take(can_be_cashed, amount / 100, ctx), admin.get_address());
        amount = can_be_cashed.value();
        transfer::public_transfer(coin::take(can_be_cashed, amount, ctx), tx_context::sender(ctx));
    }

    public entry fun destroy_company(company: Company, ctx: &TxContext) {
        assert!(company.owner == tx_context::sender(ctx), ENOTCOMPANYOWNER);
        assert!(company.waiting_for_receipt.is_empty(), ENOTCLEARITEMS);
        assert!(company.can_be_cashed.value() == 0, ENOTCASHEDALL);

        let Company {
            id,
            name: _,
            price_per_hundred_grams: _,
            waiting_for_receipt,
            can_be_cashed,
            all_profit: _,
            owner: _,
        } = company;
        object::delete(id);
        waiting_for_receipt.destroy_empty();
        can_be_cashed.destroy_zero();
    }

    public entry fun create_item(company: &mut Company, weight: u64, mut sui: Coin<SUI>, ctx: &mut TxContext) {
        let price = (weight + 99) / 100 * company.price_per_hundred_grams;
        assert!(sui.value() >= price, ENOTENOUGHCOIN);

        let transport_price = sui.split(price, ctx);
        if sui.value() == 0 {
            sui.destroy_zero();
        } else {
            transfer::public_transfer(sui, tx_context::sender(ctx));
        }

        let transport_item = TransportItem {
            id: object::new(ctx),
            logistics_company: company.name,
            company_id: object::id(company),
            weight,
            price,
        };
        let id = object::id(&transport_item);
        let item_info = ItemInfo {
            epoch: tx_context::epoch(ctx),
            transport_price: transport_price.into_balance(),
        };

        transfer::transfer(transport_item, tx_context::sender(ctx));
        company.waiting_for_receipt.push_back(id, item_info);
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

    public entry fun refunds(transport_item: TransportItem, company: &mut Company, ctx: &mut TxContext) {
        assert!(transport_item.company_id == object::id(company), ENOTSAMECOMPANY);

        let waiting_for_receipt = &mut company.waiting_for_receipt;
        let id_key = object::id(&transport_item);
        assert!(waiting_for_receipt.contains(id_key), ENOTITEMORRECEIPTED);
        assert!(*waiting_for_receipt[id_key].epoch + 3 >= tx_context::epoch(ctx), ENOTREFUNDS);

        let ItemInfo {
            epoch: _,
            mut transport_price,
        } = waiting_for_receipt.remove(id_key);
        let amount = transport_price.value();
        transfer::public_transfer(coin::take(&mut transport_price, amount, ctx), tx_context::sender(ctx));
        transport_price.destroy_zero();

        destroy_transport_item(transport_item);
    }

    public entry fun confirm_receipt(transport_item: TransportItem, company: &mut Company) {
        assert!(transport_item.company_id == object::id(company), ENOTSAMECOMPANY);

        let waiting_for_receipt = &mut company.waiting_for_receipt;
        let id_key = object::id(&transport_item);
        if waiting_for_receipt.contains(id_key) {
            let ItemInfo {
                epoch: _,
                transport_price,
            } = waiting_for_receipt.remove(id_key);
            company.all_profit += transport_price.value();
            company.can_be_cashed.join(transport_price);
        }

        destroy_transport_item(transport_item);
    }
}
