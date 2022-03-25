# Metaple Finance
## One Stop for Multiple Earning

An open and global financial system built for the internet age – an alternative to a system that’s opaque, tightly controlled, and held together by decades-old infrastructure and processes. 

Download Solidity Compiler ^0.8.11. Clean and compile the files.

```shell
npx hardhat clean
npx hardhat compile
```

# BSCScan deployment

Run the following script to deploy metaple finance token contract

```shell
npx hardhat run --network mainnet scripts/token/mlxdeploy.js
```

Run the following script to deploy metaple finance controller contracts

```shell
npx hardhat run --network mainnet scripts/mlxcontroller.js
```