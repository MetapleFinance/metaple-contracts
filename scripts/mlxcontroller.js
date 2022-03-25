const hre = require("hardhat");

async function main() {  

    const mlxpos = await hre.ethers.getContractFactory("MLXPOS");
    const _mlxpos = await mlxpos.deploy("mlx.address"); // mlx token address

    await _mlxpos.deployed();
    console.log("+ Metaple POS Token Deployed to :", _mlxpos.address);

    const mlxController = await hre.ethers.getContractFactory("MLXController");
    const _mlxCtrl = await mlxController.deploy(
        mlx.address,
        _mlxpos.address,
        "17833719"
    )

    await _mlxCtrl.deployed();
    console.log("+ Metaple Controller Deployed to :", _mlxCtrl.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
