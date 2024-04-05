# Dacade-SuiMove-LogisticsCompany

**Note:** Please confirm that the environment is supported or compatible the sui verion **1.22.0** and the edition = " **2024.beta** ".

## 1 Entity Definition

- AdminCap
- Company
- TransportItem
- ItemInfomation
- Customer

## 2 Entity Relationship

- Package publisher(`AdminCap`) will charge 1% commission.
- Any user can create or destroy their own logistics company(`Company`).
- Customers can select a logistics company and place an order. <br>At the same time, customers will receive the corresponding express delivery order(`TransportItem`).<br>Correspondingly, item information(`ItemInfomation`) is stored by the company.

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

## 5 Testing

### 5.1 publish

- **run command**

`sui client publish --gas-budget 100000000`

- **important outputs**

```bash
╭─────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                      │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                    │
│  ┌──                                                                                                │
│  │ ObjectID: 0x0399a9dbdb1c50c1c5d270c865839f0f5e6724687a664e8bb6b2c74e56cff25c                     │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                       │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )    │
│  │ ObjectType: 0x2::package::UpgradeCap                                                             │
│  │ Version: 28127559                                                                                │
│  │ Digest: HeX7Nwgffi373zyM4qx1LzbxarspBj8DgrM1StncZugb                                             │
│  └──                                                                                                │
│  ┌──                                                                                                │
│  │ ObjectID: 0xb45799f35ffe541faac0a1fd4a225d05ef0da933ef7b871605b8e3b69f870ba1                     │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                       │
│  │ Owner: Shared                                                                                    │
│  │ ObjectType: 0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719::admin::AdminCap  │
│  │ Version: 28127559                                                                                │
│  │ Digest: EUZE8krQBef9oN7eyGhRziDLZyRUqTMdgn6VQkhePemb                                             │
│  └──                                                                                                │
│ Mutated Objects:                                                                                    │
│  ┌──                                                                                                │
│  │ ObjectID: 0x266848e4e91a7a43a72b63f20760e1341e81f8970d8201a792a48959dfe2e0b9                     │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                       │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )    │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                       │
│  │ Version: 28127559                                                                                │
│  │ Digest: 6ZG1CJhJFSAQkA1gnWMhUswTf6upJTvj7ojtg9sGWrAK                                             │
│  └──                                                                                                │
│ Published Objects:                                                                                  │
│  ┌──                                                                                                │
│  │ PackageID: 0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719                    │
│  │ Version: 1                                                                                       │
│  │ Digest: HKgHQNRmYAMLYWhtNB7CDzAyh4E4uEafR65eUTMmvcqX                                             │
│  │ Modules: admin, company                                                                          │
│  └──                                                                                                │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **record  ID**

```bash
export PACKAGE_ID=0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719
export ADMINCAP=0xb45799f35ffe541faac0a1fd4a225d05ef0da933ef7b871605b8e3b69f870ba1
```

### 5.2 create_logistics_company

- **run command**

`sui client call --package $PACKAGE_ID --module company --function create_company --args NightCandle 100 --gas-budget 10000000`

- **important outputs**

```bash
╭──────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                       │
├──────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                     │
│  ┌──                                                                                                 │
│  │ ObjectID: 0x09f25c3e3da1b8affaf21da14d27a423cc9375f075c9d8f5515942d62614a218                      │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                        │
│  │ Owner: Shared                                                                                     │
│  │ ObjectType: 0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719::company::Company  │
│  │ Version: 28127560                                                                                 │
│  │ Digest: EPj2hWXndETKST4o6zX9QKYJYz2ZJcozqV8uqvNwo5v8                                              │
│  └──                                                                                                 │
│ Mutated Objects:                                                                                     │
│  ┌──                                                                                                 │
│  │ ObjectID: 0x266848e4e91a7a43a72b63f20760e1341e81f8970d8201a792a48959dfe2e0b9                      │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                        │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )     │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                        │
│  │ Version: 28127560                                                                                 │
│  │ Digest: B38fxdbjz7LzPA7CPT4ruUhmYJYPPwAMx47429UGUbkG                                              │
│  └──                                                                                                 │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **record  ID**

`export COMPANY=0x09f25c3e3da1b8affaf21da14d27a423cc9375f075c9d8f5515942d62614a218`

### 5.3 create_transport_item

- **switch the other address**

`sui client switch --address <alias>`

- **record Coin**

```bash
sui client gas
export COIN=0x82ec01655d746b42dba5c5951841472e5d1715e74238a5ef8e39d0b0566dc3be
```

- **run command**

`sui client call --package $PACKAGE_ID --module company --function create_item --args $COMPANY 1 $COIN --gas-budget 10000000`

- **important outputs**

```bash
╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                                                                                                                    │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                                                                                                                  │
│  ┌──                                                                                                                                                                                              │
│  │ ObjectID: 0x0c96fc15445d4474c439e3099f1b6212e48650a23dfc0e6f049e538b6bb12a76                                                                                                                   │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                                     │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                                                                                                  │
│  │ ObjectType: 0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719::company::TransportItem                                                                                         │
│  │ Version: 28131835                                                                                                                                                                              │
│  │ Digest: AMnX33TYttTN52WA5PSMHkyTCgUg1sLVnMHeu3kvukSn                                                                                                                                           │
│  └──                                                                                                                                                                                              │
│  ┌──                                                                                                                                                                                              │
│  │ ObjectID: 0xa3cc6836a9ce05065cd29a2ff55136ba9f5a69c0fcee0b1fc01d6d7b2eadf7eb                                                                                                                   │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                                     │
│  │ Owner: Object ID: ( 0xa7e4513d47d772ea452b9fd655b18fcfd903bc430cb1d667461b5c158fd80724 )                                                                                                       │
│  │ ObjectType: 0x2::dynamic_field::Field<0x2::object::ID, 0x2::linked_table::Node<0x2::object::ID, 0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719::company::ItemInfomation>>  │
│  │ Version: 28131835                                                                                                                                                                              │
│  │ Digest: DMrpcciLskqmsKaDDNTVeKwns4V3RRBdZqp6BQ2RU6z5                                                                                                                                           │
│  └──                                                                                                                                                                                              │
│ Mutated Objects:                                                                                                                                                                                  │
│  ┌──                                                                                                                                                                                              │
│  │ ObjectID: 0x09f25c3e3da1b8affaf21da14d27a423cc9375f075c9d8f5515942d62614a218                                                                                                                   │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                                     │
│  │ Owner: Shared                                                                                                                                                                                  │
│  │ ObjectType: 0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719::company::Company                                                                                               │
│  │ Version: 28131835                                                                                                                                                                              │
│  │ Digest: FVfcT13GrUpVxRicJ4goS1Q2qH6CCu1x9hWzttbgWFf1                                                                                                                                           │
│  └──                                                                                                                                                                                              │
│  ┌──                                                                                                                                                                                              │
│  │ ObjectID: 0x82ec01655d746b42dba5c5951841472e5d1715e74238a5ef8e39d0b0566dc3be                                                                                                                   │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                                     │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                                                                                                  │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                                                                                                     │
│  │ Version: 28131835                                                                                                                                                                              │
│  │ Digest: AZqyojtXv4dHLfcLR5WEvpjRfeeuZk5yG9NmfVMQUDbU                                                                                                                                           │
│  └──                                                                                                                                                                                              │
│  ┌──                                                                                                                                                                                              │
│  │ ObjectID: 0x8ef6503cb330c4114bc7995a403adf4015190d8effc02504fd849377caa6499b                                                                                                                   │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                                     │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                                                                                                  │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                                                                                                     │
│  │ Version: 28131835                                                                                                                                                                              │
│  │ Digest: 7PsGVWzMYLQc3yKegvrKtz6SETMa7euxGzDWoxvVhNLH                                                                                                                                           │
│  └──                                                                                                                                                                                              │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **record  ID**

`export TRANSPORTITEM=0x0c96fc15445d4474c439e3099f1b6212e48650a23dfc0e6f049e538b6bb12a76`

- **the query found that the corresponding gas was 100 less**

`sui client gas`

- **similarly, place an order for another 999g item and record its ID at the same time**

```bash
sui client call --package $PACKAGE_ID --module company --function create_item --args $COMPANY 999 $COIN --gas-budget 10000000
export TRANSPORTITEM999=0x642ca54a8ffe7ec411a412e400baadeb57d253504d375075b211790a17c9e183
```

### 5.3 refunds

- **run command**

`sui client call --package $PACKAGE_ID --module company --function refunds --args $TRANSPORTITEM $COMPANY --gas-budget 10000000`

- **important outputs**

```bash
╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                                                                                                                    │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                                                                                                                  │
│  ┌──                                                                                                                                                                                              │
│  │ ObjectID: 0x516586df0c5e9c9567696840981f720d64335ac6e8ad409f4ba4843b8dc2274a                                                                                                                   │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                                     │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                                                                                                  │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                                                                                                     │
│  │ Version: 28131837                                                                                                                                                                              │
│  │ Digest: 2HJ9QRUw1G8eyR3LZcyu2shuqypx6x56okR9GUJgquJz                                                                                                                                           │
│  └──                                                                                                                                                                                              │
│ Mutated Objects:                                                                                                                                                                                  │
│  ┌──                                                                                                                                                                                              │
│  │ ObjectID: 0x09f25c3e3da1b8affaf21da14d27a423cc9375f075c9d8f5515942d62614a218                                                                                                                   │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                                     │
│  │ Owner: Shared                                                                                                                                                                                  │
│  │ ObjectType: 0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719::company::Company                                                                                               │
│  │ Version: 28131837                                                                                                                                                                              │
│  │ Digest: FXq7AvVYh4c4Y2Y4oBkDjoMVEcNoxyKTVSQyLy292X4p                                                                                                                                           │
│  └──                                                                                                                                                                                              │
│  ┌──                                                                                                                                                                                              │
│  │ ObjectID: 0x7d5fe78c2343d01809455b967024a8f61bc3ff745383ec412d4847081b8ebb22                                                                                                                   │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                                     │
│  │ Owner: Object ID: ( 0xa7e4513d47d772ea452b9fd655b18fcfd903bc430cb1d667461b5c158fd80724 )                                                                                                       │
│  │ ObjectType: 0x2::dynamic_field::Field<0x2::object::ID, 0x2::linked_table::Node<0x2::object::ID, 0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719::company::ItemInfomation>>  │
│  │ Version: 28131837                                                                                                                                                                              │
│  │ Digest: J7GcjotAWRkMcuXagBtp5estsCWsRjdCvL3Dg7P6ahkT                                                                                                                                           │
│  └──                                                                                                                                                                                              │
│  ┌──                                                                                                                                                                                              │
│  │ ObjectID: 0x82ec01655d746b42dba5c5951841472e5d1715e74238a5ef8e39d0b0566dc3be                                                                                                                   │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                                                                                                     │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                                                                                                  │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                                                                                                     │
│  │ Version: 28131837                                                                                                                                                                              │
│  │ Digest: E3wCmWULDocFgH1G6p3PLFub2fym6WXLMhgNUHpD1m9X                                                                                                                                           │
│  └──                                                                                                                                                                                              │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **check balances**

```bash
sui client gas

# output:
╭────────────────────────────────────────────────────────────────────┬────────────────────┬──────────────────╮
│ gasCoinId                                                          │ mistBalance (MIST) │ suiBalance (SUI) │
├────────────────────────────────────────────────────────────────────┼────────────────────┼──────────────────┤
│ 0x516586df0c5e9c9567696840981f720d64335ac6e8ad409f4ba4843b8dc2274a │ 100                │ 0.00             │
│ 0x82ec01655d746b42dba5c5951841472e5d1715e74238a5ef8e39d0b0566dc3be │ 993033264          │ 0.99             │
│ 0x8ef6503cb330c4114bc7995a403adf4015190d8effc02504fd849377caa6499b │ 973787328          │ 0.97             │
│ 0xcb24b30fe196f4f2ca6d5f8d87a273bf168f7f86f6b7ae3f1f20fc5cf447e557 │ 990920960          │ 0.99             │
│ 0xe4f2d7831241583d534271d8d777d7558290124779e98e03b059a2fe108d37b0 │ 1089               │ 0.00             │
╰────────────────────────────────────────────────────────────────────┴────────────────────┴──────────────────╯
# 100 is a refund
```

### 5.4 confirm_receipt

- **run command**

`sui client call --package $PACKAGE_ID --module company --function confirm_receipt --args $TRANSPORTITEM999 $COMPANY --gas-budget 10000000`

- **important outputs**

```bash
╭──────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                       │
├──────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Mutated Objects:                                                                                     │
│  ┌──                                                                                                 │
│  │ ObjectID: 0x09f25c3e3da1b8affaf21da14d27a423cc9375f075c9d8f5515942d62614a218                      │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                        │
│  │ Owner: Shared                                                                                     │
│  │ ObjectType: 0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719::company::Company  │
│  │ Version: 28131838                                                                                 │
│  │ Digest: HyGY4fH6xYSdRdN1PaqJ8iU4J7mGLLfju6t9dQN8i4dd                                              │
│  └──                                                                                                 │
│  ┌──                                                                                                 │
│  │ ObjectID: 0x82ec01655d746b42dba5c5951841472e5d1715e74238a5ef8e39d0b0566dc3be                      │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                        │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )     │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                        │
│  │ Version: 28131838                                                                                 │
│  │ Digest: 4GCG3eEX4g3akv4oNhLkgWjoEkiMpD3ajQWe3RBDeqJi                                              │
│  └──                                                                                                 │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### 5.5 cash

- **run command**

`sui client call --package $PACKAGE_ID --module company --function cash --args $ADMINCAP $COMPANY --gas-budget 10000000`

- **error**

```bash
Error executing transaction: Failure {
    error: "MoveAbort(MoveLocation { module: ModuleId { address: 681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719, name: Identifier(\"company\") }, function: 2, instruction: 16, function_name: Some(\"cash\") }, 0) in command 0",
}
```

because you are not the owner of company, you should switch the address first.

- **run command**

```bash
sui client switch --address <alias>
sui client call --package $PACKAGE_ID --module company --function cash --args $ADMINCAP $COMPANY --gas-budget 10000000
```

- **important outputs**

```bash
╭──────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                       │
├──────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                     │
│  ┌──                                                                                                 │
│  │ ObjectID: 0x3309da2eb2919265feff786cd9167cdee8055fea52649bd33b92adfb3732e4c5                      │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                        │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )     │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                        │
│  │ Version: 28131840                                                                                 │
│  │ Digest: 3hmwiNmpCdeaTAYjbvzGsg2kHxFqpRTnLeK9bRArqzxr                                              │
│  └──                                                                                                 │
│  ┌──                                                                                                 │
│  │ ObjectID: 0xb3968ae4bf71a60d2ed4d39b2dc89cd184fca813a0a6e4d5abea26492f953ef2                      │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                        │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )     │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                        │
│  │ Version: 28131840                                                                                 │
│  │ Digest: 9ZFMBe6XPcdB8xPBrfNDbA68YYdHZj6fujepNTnHojTR                                              │
│  └──                                                                                                 │
│ Mutated Objects:                                                                                     │
│  ┌──                                                                                                 │
│  │ ObjectID: 0x09f25c3e3da1b8affaf21da14d27a423cc9375f075c9d8f5515942d62614a218                      │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                        │
│  │ Owner: Shared                                                                                     │
│  │ ObjectType: 0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719::company::Company  │
│  │ Version: 28131840                                                                                 │
│  │ Digest: 6Nx3wgtJq3FpUARSqrhY9vTyTLPSq7pRTtgLEsPVex2k                                              │
│  └──                                                                                                 │
│  ┌──                                                                                                 │
│  │ ObjectID: 0x266848e4e91a7a43a72b63f20760e1341e81f8970d8201a792a48959dfe2e0b9                      │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                        │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )     │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                        │
│  │ Version: 28131840                                                                                 │
│  │ Digest: 5vxcXmyQ5gns8UrcbNMhp7u5yv3Mh6S3mRNWWPkg95yG                                              │
│  └──                                                                                                 │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **check the company object**

```bash
sui client object $COMPANY

# outputs
╭───────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ objectId      │  0x09f25c3e3da1b8affaf21da14d27a423cc9375f075c9d8f5515942d62614a218                                                                                                                                               │
│ version       │  28131840                                                                                                                                                                                                         │
│ digest        │  6Nx3wgtJq3FpUARSqrhY9vTyTLPSq7pRTtgLEsPVex2k                                                                                                                                                                     │
│ objType       │  0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719::company::Company                                                                                                                             │
│ owner         │ ╭────────┬─────────────────────────────────────────╮                                                                                                                                                              │
│               │ │ Shared │ ╭────────────────────────┬────────────╮ │                                                                                                                                                              │
│               │ │        │ │ initial_shared_version │  28127560  │ │                                                                                                                                                              │
│               │ │        │ ╰────────────────────────┴────────────╯ │                                                                                                                                                              │
│               │ ╰────────┴─────────────────────────────────────────╯                                                                                                                                                              │
│ prevTx        │  D5EZG47JCRYY6Dwq6nvUMATTUhSMjJ24g8YeizbP7UGQ                                                                                                                                                                     │
│ storageRebate │  2135600                                                                                                                                                                                                          │
│ content       │ ╭───────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │
│               │ │ dataType          │  moveObject                                                                                                                                                                               │ │
│               │ │ type              │  0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719::company::Company                                                                                                     │ │
│               │ │ hasPublicTransfer │  false                                                                                                                                                                                    │ │
│               │ │ fields            │ ╭─────────────────────────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │ │
│               │ │                   │ │ all_profit              │  1000                                                                                                                                                       │ │ │
│               │ │                   │ │ can_be_cashed           │  0                                                                                                                                                          │ │ │
│               │ │                   │ │ id                      │ ╭────┬──────────────────────────────────────────────────────────────────────╮                                                                               │ │ │
│               │ │                   │ │                         │ │ id │  0x09f25c3e3da1b8affaf21da14d27a423cc9375f075c9d8f5515942d62614a218  │                                                                               │ │ │
│               │ │                   │ │                         │ ╰────┴──────────────────────────────────────────────────────────────────────╯                                                                               │ │ │
│               │ │                   │ │ name                    │  NightCandle                                                                                                                                                │ │ │
│               │ │                   │ │ owner                   │  0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                                                                                         │ │ │
│               │ │                   │ │ price_per_hundred_grams │  100                                                                                                                                                        │ │ │
│               │ │                   │ │ waiting_for_receipt     │ ╭────────┬────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │ │ │
│               │ │                   │ │                         │ │ type   │  0x2::linked_table::LinkedTable<0x2::object::ID, 0x681aaef1b875e0030eb11f038d33277d21bd09076df6c6de485db09afa5ee719::company::ItemInfomation>  │ │ │ │
│               │ │                   │ │                         │ │ fields │ ╭──────┬───────────────────────────────────────────────────────────────────────────────╮                                                       │ │ │ │
│               │ │                   │ │                         │ │        │ │ head │                                                                               │                                                       │ │ │ │
│               │ │                   │ │                         │ │        │ │ id   │ ╭────┬──────────────────────────────────────────────────────────────────────╮ │                                                       │ │ │ │
│               │ │                   │ │                         │ │        │ │      │ │ id │  0xa7e4513d47d772ea452b9fd655b18fcfd903bc430cb1d667461b5c158fd80724  │ │                                                       │ │ │ │
│               │ │                   │ │                         │ │        │ │      │ ╰────┴──────────────────────────────────────────────────────────────────────╯ │                                                       │ │ │ │
│               │ │                   │ │                         │ │        │ │ size │  0                                                                            │                                                       │ │ │ │
│               │ │                   │ │                         │ │        │ │ tail │                                                                               │                                                       │ │ │ │
│               │ │                   │ │                         │ │        │ ╰──────┴───────────────────────────────────────────────────────────────────────────────╯                                                       │ │ │ │
│               │ │                   │ │                         │ ╰────────┴────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯ │ │ │
│               │ │                   │ ╰─────────────────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯ │ │
│               │ ╰───────────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯ │
╰───────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

all_profit is 1000, package publisher earns 10, company owner earns 990, so when you run `sui client gas`, you will find them.

### 5.6 destroy company

- **run command**

`sui client call --package $PACKAGE_ID --module company --function destroy_company --args $COMPANY --gas-budget 10000000`

- **check the company object**

```bash
sui client object $COMPANY

# outputs
Internal error, cannot read the object: Object has been deleted object_id: 0x09f25c3e3da1b8affaf21da14d27a423cc9375f075c9d8f5515942d62614a218 at version: SequenceNumber(28131841) in digest o#7gyGAp71YXQRoxmFBaHxofQXAipvgHyBKPyxmdSJxyvz
```

## 6 Disclaimer

This project is for learning purposes only.<br>The code logic and testing are still imperfect and unsafe.<br>If you want to use it for commercial purposes, please bear the possible consequences.
