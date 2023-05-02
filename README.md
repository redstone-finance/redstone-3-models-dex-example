# Redstone Oracles Workshop

This project demonstrates how to integrate with Redstone Oracles on an Avalanche subnet.

It's based on a very simple exchange contract that allows user to swap their AVAX to USD-based stable coin. 

It compares two models of integration: 
1. [Core](/contracts/DexCore.sol) - where price data is injected to transactions executed by users ([learn more](https://docs.redstone.finance/docs/smart-contract-devs/get-started/redstone-core))
2. [Classic](/contracts/DexClassic.sol) - where price data is periodically pushed into on-chain storage ([learn more](https://docs.redstone.finance/docs/smart-contract-devs/get-started/redstone-classic))

## Step by step guide

### 1. Install dependencies

```
npm install
```

### 2. Launch avalanche subnet

* Install and configure the [avalanche-cli](https://docs.avax.network/subnets/install-avalanche-cli)

* Deply the subnet named 'red' to the local environment: 

```
avalanche subnet deploy red
```

You can find a step by step tutorial in the avalanche subnet [docs](https://docs.avax.network/subnets/create-a-local-subnet).

### 3. Deploy smart contracts

* Add the rpc endpoint of your subnet and the private key of the subnet account that holds the native tokens to the [hardhat](./hardhat.config.ts) config file.

Deploy the contract using hardhat deploy plugin: 

```
npx hardhat deploy --network red
```

### 4. Execute a swap in the Core model

Execute a script that will deploy mock USD coin to the DEX and perform the swap: 

```
npx hardhat run ./scripts/core-deposit-and-swap.ts --network red
```

### 4. Execute a swap in the Classic model

#### Deploying the relayer

In order to operate properly the Classic model requires a relayer service that will periodically push AVAX price to on-chain smart storage. 

The code for relayer is located in the RedStone [repository](https://github.com/redstone-finance/redstone-oracles-monorepo/tree/main/packages/on-chain-relayer). 

In order to run the code you need to: 
1. Put the details of your subnet into the hardhat [config](https://github.com/redstone-finance/redstone-oracles-monorepo/blob/main/packages/on-chain-relayer/hardhat.config.ts) file.
2. Deploy the on-chain adapter and price-feed contracts by running: 

```
npx hardhat run ./scripts/price-feeds/deploy-price-feeds-contracts.ts --network red
```

3. Create a new .env file using the [sample](https://github.com/redstone-finance/redstone-oracles-monorepo/blob/main/packages/on-chain-relayer/.env.example) and put the details of your network (privateKey and RPC url) and addresses of the adapter contract deployed in the previous step

4. Run the relayer service:

```
yarn run start:dev
```

#### Executing a swap

1. Put the address of newly deployed PriceFeed contract into the code of the [DEXClassic.sol](./contracts/DexClassic.sol) contract: 

```
priceFeed = AggregatorV3Interface(PRICE_FEED_ADDRESS);
```

2. Redeploy the DEXClassic contract: 

```
npx hardhat deploy --network red
```


3. Execute a script that will deploy mock USD coin to the DEX and perform the swap: 

```
npx hardhat run ./scripts/classic-deposit-and-swap.ts --network red
```




