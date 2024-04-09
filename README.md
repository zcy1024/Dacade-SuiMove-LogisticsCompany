# Dacade-SuiMove-LogisticsCompany

~~**Note:** Please confirm that the environment is supported or compatible the sui verion **1.22.0** and the edition = " **2024.beta** ".~~

## 1 Entity Definition

- ADMIN
- AdminCap
- CompanyCap
- Company
- TransportItem
- ItemInfo
- Customer

## 2 Entity Relationship

- Package publisher(`AdminCap`) will charge 1% commission.
- use One-Time-Witness(`ADMIN`) to create `Publisher`, use this as a voucher when the publisher withdraws money.
- Any user can create or destroy their own logistics company(`Company`).
- Only company administrators with credentials(`CompanyCap`) can withdraw cash.
- Customers can select a logistics company and place an order. <br>At the same time, customers will receive the corresponding express delivery order(`TransportItem`).<br>Correspondingly, item information(`ItemInfo`) is stored by the company.

## 3 Economic Design

- Every logistics company can customize its price and publish it based on the unit price per hundred grams. If the weight is less than 100g, it will be calculated as 100g.
- Customers need to pay in full when placing an order, but this amount will not directly arrive in the account of the founder of the logistics company.
  Only when the customer confirms receipt of the goods with the courier order, or after the express delivery exceeds a certain period and the logistics company defaults to receiving the goods, will the money actually arrive in the account.
- Whthin 3 epoch, customers can refunds their items, of course, they need to hold the correct courier order.
- Logistics companies can only withdraw confirmed funds, but this process requires paying a 1% commission to the package publisher.

## 4 API Definition

- **create_company:** Create a new logistics company and initializes its fields.
- **confirm_items:** Logistics companies can confirm orders that have not been confirmed for a long time.
- **cash:** The logistics company withdraws the confirmed funds.
- **destroy_company:** On the premise that all orders have been processed and the funds have been withdrawn, cancel the company.
- **create_item:** The customer places an order, and the system generates express order, cargo information.
- **refunds:** Refunds will be processed for orders no more than 3 epoch and for which receipt has not been confirmed.
- **confirm_receipt:** Customer confirms receipt.
- **withdraw:** Publisher withdraws earnings.

## 5 Testing

### 5.1 publish

- **run command**

`sui client publish --gas-budget 100000000`

- **important outputs**

```bash
╭──────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                   │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0x64adbd96a562851de6dc79eeec7f5b8c173914aa667083693aa295f162deeb0d                  │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                    │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 ) │
│  │ ObjectType: 0x2::package::Publisher                                                           │
│  │ Version: 81313247                                                                             │
│  │ Digest: H9BpBvmMayuLeGwbrtMXgmQiYVFT6LjscSiwpxaRp1jm                                          │
│  └──                                                                                             │
│  ┌──                                                                                             │
│  │ ObjectID: 0xa9c37253c81a63606a697eb6d249790aac5443b2c9063fd61ea7a2072498e010                  │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                    │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 ) │
│  │ ObjectType: 0x2::package::UpgradeCap                                                          │
│  │ Version: 81313247                                                                             │
│  │ Digest: H2b31NtMkE4PhtZ1e3VhjS5YqKH8HkpewgyYjHkpqUVT                                          │
│  └──                                                                                             │
│  ┌──                                                                                             │
│  │ ObjectID: 0xd5785555e3c0d1745a502633353cf9aaad1b79d1fd04fb0fa4943bdea98006af                  │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                    │
│  │ Owner: Shared                                                                                 │
│  │ ObjectType: 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::admin::Admin  │
│  │ Version: 81313247                                                                             │
│  │ Digest: 5FPD5bwqPENjnH2TpmKw4pt2pgGyZprteSE5besGyAiC                                          │
│  └──                                                                                             │
│ Mutated Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0x6a8d2d47ad669e0ff5d4c4d32ddb282014daca375f3eabf454a42701beb1ec06                  │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                    │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 81313247                                                                             │
│  │ Digest: 8RKM8DLrFPWMLFjaE4k5yNCvfbwXFfE57mJFxucUbLLw                                          │
│  └──                                                                                             │
│ Published Objects:                                                                               │
│  ┌──                                                                                             │
│  │ PackageID: 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6                 │
│  │ Version: 1                                                                                    │
│  │ Digest: 8u1KT2dfoqfkFk7C5eoFVkMH7czoph4LoNsY8HupUHiY                                          │
│  │ Modules: admin, company                                                                       │
│  └──                                                                                             │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **record  ID**

```bash
export PACKAGE_ID=0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6
export PUBLISHER=0x64adbd96a562851de6dc79eeec7f5b8c173914aa667083693aa295f162deeb0d
export ADMIN=0xd5785555e3c0d1745a502633353cf9aaad1b79d1fd04fb0fa4943bdea98006af
```

### 5.2 create_logistics_company

- **run command**

`sui client call --package $PACKAGE_ID --module company --function create_company --args NightCandle 100 --gas-budget 10000000`

- **important outputs**

```bash
╭─────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                          │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                        │
│  ┌──                                                                                                    │
│  │ ObjectID: 0xbb83fb182eaaa0054dd465eb0f600056b0e81aa600b053b1577cf49ce0c54898                         │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                           │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )        │
│  │ ObjectType: 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::company::CompanyCap  │
│  │ Version: 81313248                                                                                    │
│  │ Digest: 7ZRmFTb4Xe2idgiw3PM5qMEUGGJ5ieg1xeEaepwoyRGZ                                                 │
│  └──                                                                                                    │
│  ┌──                                                                                                    │
│  │ ObjectID: 0xcab6bc0ebef6ccf8cd18fcb424e3b5ee5d35544e03536aac66a0f8b0738363a2                         │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                           │
│  │ Owner: Shared                                                                                        │
│  │ ObjectType: 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::company::Company     │
│  │ Version: 81313248                                                                                    │
│  │ Digest: DZqQn4hw6koM6fjrKUYTDHe7TJnAfPbp7hP9jA93L3Lr                                                 │
│  └──                                                                                                    │
│ Mutated Objects:                                                                                        │
│  ┌──                                                                                                    │
│  │ ObjectID: 0x6a8d2d47ad669e0ff5d4c4d32ddb282014daca375f3eabf454a42701beb1ec06                         │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                           │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )        │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                           │
│  │ Version: 81313248                                                                                    │
│  │ Digest: 2Z2CDce9ck99QwMT7UtqeAQK4Trr9iLgysnXqF4gjr37                                                 │
│  └──                                                                                                    │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **record  ID**

```bash
export COMPANYCAP=0xbb83fb182eaaa0054dd465eb0f600056b0e81aa600b053b1577cf49ce0c54898
export COMPANY=0xcab6bc0ebef6ccf8cd18fcb424e3b5ee5d35544e03536aac66a0f8b0738363a2
```

### 5.3 create_transport_item

- **switch the other address**

`sui client switch --address <alias>`

- **record Coin**

```bash
sui client gas
export COIN=0xca1e96b358f722d601accc962d54460068244d4f7f75ee122d50e1132d25ee36
```

- **run command**

`sui client call --package $PACKAGE_ID --module company --function create_item --args $COMPANY 1 $COIN --gas-budget 10000000`

- **important outputs**

```bash
╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                                                                                                              │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                                                                                                            │
│  ┌──                                                                                                                                                                                        │
│  │ ObjectID: 0x9128a11aae6362040052e943098e12d8a8e625a3fd164aa0772cdb7c6209c0f7                                                                                                             │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                               │
│  │ Owner: Object ID: ( 0xfb39822d0d3883ed1a02d720ed6bc1f38a09b8c2b7ad33d00a466d28306860c5 )                                                                                                 │
│  │ ObjectType: 0x2::dynamic_field::Field<0x2::object::ID, 0x2::linked_table::Node<0x2::object::ID, 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::company::ItemInfo>>  │
│  │ Version: 81313254                                                                                                                                                                        │
│  │ Digest: 3EzLVtMtZj88Q3JzqQU3SkARE6ZBLiwou7csLiJkATdT                                                                                                                                     │
│  └──                                                                                                                                                                                        │
│  ┌──                                                                                                                                                                                        │
│  │ ObjectID: 0xcc9581fae40a69c7e8681a0f497a900a38cc1379abf420039a2ce783a0d9cb28                                                                                                             │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                               │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                                                                                            │
│  │ ObjectType: 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::company::TransportItem                                                                                   │
│  │ Version: 81313254                                                                                                                                                                        │
│  │ Digest: EAtDCZAR8vZiAZ7FWy4bTU2kQn7KUYnT8uRSeUH6bdpQ                                                                                                                                     │
│  └──                                                                                                                                                                                        │
│ Mutated Objects:                                                                                                                                                                            │
│  ┌──                                                                                                                                                                                        │
│  │ ObjectID: 0xa5e9cc06d7bfb34b49fd2f6631e0580129fa8124a36030ae5107ebf785fca37c                                                                                                             │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                               │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                                                                                            │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                                                                                               │
│  │ Version: 81313254                                                                                                                                                                        │
│  │ Digest: J9w5dNToKgigdoc3VtM5KucRKbMZkyVzqM4cuLeLBUDm                                                                                                                                     │
│  └──                                                                                                                                                                                        │
│  ┌──                                                                                                                                                                                        │
│  │ ObjectID: 0xca1e96b358f722d601accc962d54460068244d4f7f75ee122d50e1132d25ee36                                                                                                             │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                               │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                                                                                            │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                                                                                               │
│  │ Version: 81313254                                                                                                                                                                        │
│  │ Digest: 97oxDW1DDton7k1S81HgkoC9rexw7YGvUDXw1aMGKjXd                                                                                                                                     │
│  └──                                                                                                                                                                                        │
│  ┌──                                                                                                                                                                                        │
│  │ ObjectID: 0xcab6bc0ebef6ccf8cd18fcb424e3b5ee5d35544e03536aac66a0f8b0738363a2                                                                                                             │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                               │
│  │ Owner: Shared                                                                                                                                                                            │
│  │ ObjectType: 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::company::Company                                                                                         │
│  │ Version: 81313254                                                                                                                                                                        │
│  │ Digest: 5hTdm7unYsfMEiopZwHwDDanfvEDwW2cSaY8GtvA462D                                                                                                                                     │
│  └──                                                                                                                                                                                        │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **record  ID**

`export TRANSPORTITEM=0xcc9581fae40a69c7e8681a0f497a900a38cc1379abf420039a2ce783a0d9cb28`

- **the query found that the corresponding gas was 100 less**

`sui client gas`

- **similarly, place an order for another 999g item and record its ID at the same time**

```bash
sui client call --package $PACKAGE_ID --module company --function create_item --args $COMPANY 999 $COIN --gas-budget 10000000
export TRANSPORTITEM999=0x73a317b42fe947049085edca5117a49e59e8d17f8c90cecd8437fbaeb73b20a2
```

### 5.4 refunds

- **run command**

`sui client call --package $PACKAGE_ID --module company --function refunds --args $TRANSPORTITEM $COMPANY --gas-budget 10000000`

- **important outputs**

```bash
╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                                                                                                              │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                                                                                                            │
│  ┌──                                                                                                                                                                                        │
│  │ ObjectID: 0x990be8a45b632a81cf7e5ed6dc763b195edbaa994d827e5d6ac6f0db1eedc3d5                                                                                                             │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                               │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                                                                                            │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                                                                                               │
│  │ Version: 81313256                                                                                                                                                                        │
│  │ Digest: Eo4kQG93h8nUwYCmJbkQ2J7spFPgtZpdx2dWhtvRUp4f                                                                                                                                     │
│  └──                                                                                                                                                                                        │
│ Mutated Objects:                                                                                                                                                                            │
│  ┌──                                                                                                                                                                                        │
│  │ ObjectID: 0x393096cbb4b767cc89988c7ef1566b30ce0ed69f367c1a2dc46a394e33c4a358                                                                                                             │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                               │
│  │ Owner: Object ID: ( 0xfb39822d0d3883ed1a02d720ed6bc1f38a09b8c2b7ad33d00a466d28306860c5 )                                                                                                 │
│  │ ObjectType: 0x2::dynamic_field::Field<0x2::object::ID, 0x2::linked_table::Node<0x2::object::ID, 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::company::ItemInfo>>  │
│  │ Version: 81313256                                                                                                                                                                        │
│  │ Digest: BX5RYwdf94HGfqyxqj49LdoxDxFHf19YaSezM6ZLysup                                                                                                                                     │
│  └──                                                                                                                                                                                        │
│  ┌──                                                                                                                                                                                        │
│  │ ObjectID: 0xa5e9cc06d7bfb34b49fd2f6631e0580129fa8124a36030ae5107ebf785fca37c                                                                                                             │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                               │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                                                                                            │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                                                                                               │
│  │ Version: 81313256                                                                                                                                                                        │
│  │ Digest: bAY6jemHXqpQ7B9P234ueRHC76mz9sE6FxoYUdjXtP9                                                                                                                                      │
│  └──                                                                                                                                                                                        │
│  ┌──                                                                                                                                                                                        │
│  │ ObjectID: 0xcab6bc0ebef6ccf8cd18fcb424e3b5ee5d35544e03536aac66a0f8b0738363a2                                                                                                             │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                               │
│  │ Owner: Shared                                                                                                                                                                            │
│  │ ObjectType: 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::company::Company                                                                                         │
│  │ Version: 81313256                                                                                                                                                                        │
│  │ Digest: 5WNobseyxFD5isae3QDzY4aaT18ysesgfLVbzXfBJK5C                                                                                                                                     │
│  └──                                                                                                                                                                                        │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **check balances**

```bash
sui client gas

# output:
╭────────────────────────────────────────────────────────────────────┬────────────────────┬──────────────────╮
│ gasCoinId                                                          │ mistBalance (MIST) │ suiBalance (SUI) │
├────────────────────────────────────────────────────────────────────┼────────────────────┼──────────────────┤
│ 0x990be8a45b632a81cf7e5ed6dc763b195edbaa994d827e5d6ac6f0db1eedc3d5 │ 100                │ 0.00             │
│ 0xa5e9cc06d7bfb34b49fd2f6631e0580129fa8124a36030ae5107ebf785fca37c │ 40997689           │ 0.04             │
│ 0xca1e96b358f722d601accc962d54460068244d4f7f75ee122d50e1132d25ee36 │ 8241140            │ 0.00             │
╰────────────────────────────────────────────────────────────────────┴────────────────────┴──────────────────╯
# 100 is a refund
```

### 5.5 confirm_receipt

- **run command**

`sui client call --package $PACKAGE_ID --module company --function confirm_receipt --args $TRANSPORTITEM999 $COMPANY --gas-budget 10000000`

- **important outputs**

```bash
╭──────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                       │
├──────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Mutated Objects:                                                                                     │
│  ┌──                                                                                                 │
│  │ ObjectID: 0xa5e9cc06d7bfb34b49fd2f6631e0580129fa8124a36030ae5107ebf785fca37c                      │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                        │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )     │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                        │
│  │ Version: 81313257                                                                                 │
│  │ Digest: 51dpW1fdGD8N4gNNscivJ1Bj4xH6NbviAknscBWJK2U1                                              │
│  └──                                                                                                 │
│  ┌──                                                                                                 │
│  │ ObjectID: 0xcab6bc0ebef6ccf8cd18fcb424e3b5ee5d35544e03536aac66a0f8b0738363a2                      │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                        │
│  │ Owner: Shared                                                                                     │
│  │ ObjectType: 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::company::Company  │
│  │ Version: 81313257                                                                                 │
│  │ Digest: 5VGyDPiy1eQAG41j7QrKtWrUpu3tfsP34d1697B3efys                                              │
│  └──                                                                                                 │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### 5.6 cash

- **run command**

`sui client call --package $PACKAGE_ID --module company --function cash --args $COMPANYCAP $ADMIN $COMPANY --gas-budget 10000000`

- **error**

```bash
RPC call failed: ErrorObject { code: ServerError(-32002), message: "Transaction execution failed due to issues with transaction inputs, please review the errors and try again: Transaction was not signed by the correct sender: Object 0xbb83fb182eaaa0054dd465eb0f600056b0e81aa600b053b1577cf49ce0c54898 is owned by account address 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67, but given owner/signer address is 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b.", data: None }

Caused by:
    RPC call failed: ErrorObject { code: ServerError(-32002), message: "Transaction execution failed due to issues with transaction inputs, please review the errors and try again: Transaction was not signed by the correct sender: Object 0xbb83fb182eaaa0054dd465eb0f600056b0e81aa600b053b1577cf49ce0c54898 is owned by account address 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67, but given owner/signer address is 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b.", data: None }
```

because you are not the owner of company, you should switch the address first.

- **run command**

```bash
sui client switch --address <alias>
sui client call --package $PACKAGE_ID --module company --function cash --args $COMPANYCAP $ADMIN $COMPANY --gas-budget 10000000
```

- **important outputs**

```bash
╭─────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                          │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                        │
│  ┌──                                                                                                    │
│  │ ObjectID: 0xb24851602eeb642a28821f6608f74f4137c7657f0a2ef51fe8081fe680dc275f                         │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                           │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )        │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                           │
│  │ Version: 81313258                                                                                    │
│  │ Digest: 8K3U4WEqjzMhjh2RhWFwVYpr35jkroAtXUoHEtSzxdqD                                                 │
│  └──                                                                                                    │
│ Mutated Objects:                                                                                        │
│  ┌──                                                                                                    │
│  │ ObjectID: 0x6a8d2d47ad669e0ff5d4c4d32ddb282014daca375f3eabf454a42701beb1ec06                         │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                           │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )        │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                           │
│  │ Version: 81313258                                                                                    │
│  │ Digest: CPzvjMrt83jp6UhdpMaJMkid5Z3uqQa46uVGYWBkvzYM                                                 │
│  └──                                                                                                    │
│  ┌──                                                                                                    │
│  │ ObjectID: 0xbb83fb182eaaa0054dd465eb0f600056b0e81aa600b053b1577cf49ce0c54898                         │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                           │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )        │
│  │ ObjectType: 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::company::CompanyCap  │
│  │ Version: 81313258                                                                                    │
│  │ Digest: 9xw1ApyAkSEZjQA24ixvK4h5CGvdpQHxRTLS81SXRNYp                                                 │
│  └──                                                                                                    │
│  ┌──                                                                                                    │
│  │ ObjectID: 0xcab6bc0ebef6ccf8cd18fcb424e3b5ee5d35544e03536aac66a0f8b0738363a2                         │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                           │
│  │ Owner: Shared                                                                                        │
│  │ ObjectType: 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::company::Company     │
│  │ Version: 81313258                                                                                    │
│  │ Digest: AEnTkUuctn8S7eGhDVdhMCBb49pttjjyivBJksqpg9a2                                                 │
│  └──                                                                                                    │
│  ┌──                                                                                                    │
│  │ ObjectID: 0xd5785555e3c0d1745a502633353cf9aaad1b79d1fd04fb0fa4943bdea98006af                         │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                           │
│  │ Owner: Shared                                                                                        │
│  │ ObjectType: 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::admin::Admin         │
│  │ Version: 81313258                                                                                    │
│  │ Digest: 5zoMeLAmpr29RFUxMbAvdNethPXbreEnpJdhzdxFu9kv                                                 │
│  └──                                                                                                    │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **check the company object**

```bash
sui client object $COMPANY

# outputs
╭───────────────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ objectId      │  0xcab6bc0ebef6ccf8cd18fcb424e3b5ee5d35544e03536aac66a0f8b0738363a2                                                                                                                                         │
│ version       │  81313258                                                                                                                                                                                                   │
│ digest        │  AEnTkUuctn8S7eGhDVdhMCBb49pttjjyivBJksqpg9a2                                                                                                                                                               │
│ objType       │  0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::company::Company                                                                                                                       │
│ owner         │ ╭────────┬─────────────────────────────────────────╮                                                                                                                                                        │
│               │ │ Shared │ ╭────────────────────────┬────────────╮ │                                                                                                                                                        │
│               │ │        │ │ initial_shared_version │  81313248  │ │                                                                                                                                                        │
│               │ │        │ ╰────────────────────────┴────────────╯ │                                                                                                                                                        │
│               │ ╰────────┴─────────────────────────────────────────╯                                                                                                                                                        │
│ prevTx        │  HL7sXWFe2bGSHd7sE8VCkksBBzQP3VwuS3NVwWdiRvyM                                                                                                                                                               │
│ storageRebate │  1892400                                                                                                                                                                                                    │
│ content       │ ╭───────────────────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │
│               │ │ dataType          │  moveObject                                                                                                                                                                         │ │
│               │ │ type              │  0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::company::Company                                                                                               │ │
│               │ │ hasPublicTransfer │  false                                                                                                                                                                              │ │
│               │ │ fields            │ ╭─────────────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │ │
│               │ │                   │ │ all_profit              │  1000                                                                                                                                                 │ │ │
│               │ │                   │ │ can_be_cashed           │  0                                                                                                                                                    │ │ │
│               │ │                   │ │ id                      │ ╭────┬──────────────────────────────────────────────────────────────────────╮                                                                         │ │ │
│               │ │                   │ │                         │ │ id │  0xcab6bc0ebef6ccf8cd18fcb424e3b5ee5d35544e03536aac66a0f8b0738363a2  │                                                                         │ │ │
│               │ │                   │ │                         │ ╰────┴──────────────────────────────────────────────────────────────────────╯                                                                         │ │ │
│               │ │                   │ │ name                    │  NightCandle                                                                                                                                          │ │ │
│               │ │                   │ │ price_per_hundred_grams │  100                                                                                                                                                  │ │ │
│               │ │                   │ │ waiting_for_receipt     │ ╭────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │ │ │
│               │ │                   │ │                         │ │ type   │  0x2::linked_table::LinkedTable<0x2::object::ID, 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::company::ItemInfo>  │ │ │ │
│               │ │                   │ │                         │ │ fields │ ╭──────┬───────────────────────────────────────────────────────────────────────────────╮                                                 │ │ │ │
│               │ │                   │ │                         │ │        │ │ head │                                                                               │                                                 │ │ │ │
│               │ │                   │ │                         │ │        │ │ id   │ ╭────┬──────────────────────────────────────────────────────────────────────╮ │                                                 │ │ │ │
│               │ │                   │ │                         │ │        │ │      │ │ id │  0xfb39822d0d3883ed1a02d720ed6bc1f38a09b8c2b7ad33d00a466d28306860c5  │ │                                                 │ │ │ │
│               │ │                   │ │                         │ │        │ │      │ ╰────┴──────────────────────────────────────────────────────────────────────╯ │                                                 │ │ │ │
│               │ │                   │ │                         │ │        │ │ size │  0                                                                            │                                                 │ │ │ │
│               │ │                   │ │                         │ │        │ │ tail │                                                                               │                                                 │ │ │ │
│               │ │                   │ │                         │ │        │ ╰──────┴───────────────────────────────────────────────────────────────────────────────╯                                                 │ │ │ │
│               │ │                   │ │                         │ ╰────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯ │ │ │
│               │ │                   │ ╰─────────────────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯ │ │
│               │ ╰───────────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯ │
╰───────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

all_profit is 1000, package publisher earns 10, company owner earns 990, so when you run `sui client gas`, you will find them, of course, you need to witheraw the publisher profit first.

- **run command**

`sui client call --package $PACKAGE_ID --module admin --function withdraw --args $PUBLISHER $ADMIN --gas-budget 10000000`

- **important outputs**

```bash
╭──────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                   │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0xfcf76783c005cd1119624a38c7fea70508eb6f6e8e3998dc3f08cb454ec58341                  │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                    │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 81313259                                                                             │
│  │ Digest: 31FWkR7WmpdBEgZCaSsh28Ffs8AFLJQMMz2T7vQT1bHz                                          │
│  └──                                                                                             │
│ Mutated Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0x64adbd96a562851de6dc79eeec7f5b8c173914aa667083693aa295f162deeb0d                  │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                    │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 ) │
│  │ ObjectType: 0x2::package::Publisher                                                           │
│  │ Version: 81313259                                                                             │
│  │ Digest: 6XkP1sj42fcPY413r6TrVWxgwCv9qa2ic8wc95t5cgBM                                          │
│  └──                                                                                             │
│  ┌──                                                                                             │
│  │ ObjectID: 0x6a8d2d47ad669e0ff5d4c4d32ddb282014daca375f3eabf454a42701beb1ec06                  │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                    │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 81313259                                                                             │
│  │ Digest: UfJzotSMJAFTPQRqtsVwdKpX3qfxcEyVhxa5ZfvJdkU                                           │
│  └──                                                                                             │
│  ┌──                                                                                             │
│  │ ObjectID: 0xd5785555e3c0d1745a502633353cf9aaad1b79d1fd04fb0fa4943bdea98006af                  │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                    │
│  │ Owner: Shared                                                                                 │
│  │ ObjectType: 0x9bf00314ecf5c82bce70a7afac8905960734d600e76ac31d78588d81ed63d2d6::admin::Admin  │
│  │ Version: 81313259                                                                             │
│  │ Digest: EMiBCe4QXLrhEpexZaiV8FGyHVbi6WYnAwCZ1dSvwCxq                                          │
│  └──                                                                                             │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### 5.7 destroy company

- **run command**

`sui client call --package $PACKAGE_ID --module company --function destroy_company --args $COMPANYCAP $COMPANY --gas-budget 10000000`

- **check the company object**

```bash
sui client object $COMPANY

# outputs
Internal error, cannot read the object: Object has been deleted object_id: 0xcab6bc0ebef6ccf8cd18fcb424e3b5ee5d35544e03536aac66a0f8b0738363a2 at version: SequenceNumber(81313260) in digest o#7gyGAp71YXQRoxmFBaHxofQXAipvgHyBKPyxmdSJxyvz
```

## 6 Disclaimer

This project is for learning purposes only.<br>The code logic and testing are still imperfect and unsafe.<br>If you want to use it for commercial purposes, please bear the possible consequences.
