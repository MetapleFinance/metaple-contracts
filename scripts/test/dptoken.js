// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const metapleDP = await hre.ethers.getContractFactory("TTPLDP");
  const mtplDP = await metapleDP.deploy("0x0771c52744D0338ab23473b746097f1F75D34bE9");

  await mtplDP.deployed();

  console.log("+ Metaple Token Deployed to :", mtplDP.address);

  const metapleDPoS = await hre.ethers.getContractFactory("TTPLDPoS");
  const mtplDPoS = await metapleDPoS.deploy(mtplDP.address);

  console.log("+ Metaple DPoS Deployed to :", mtplDPoS.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
