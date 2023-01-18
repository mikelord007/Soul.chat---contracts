// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const SoulNFTContractFactory = await hre.ethers.getContractFactory("SOULNFTS");
  const soulNFTContract = await SoulNFTContractFactory.deploy("SOULNFT", "SFT");
  console.log("address: ", soulNFTContract.address)
  await soulNFTContract.deployTransaction.wait();

  const SOULTOKENContractFactory = await hre.ethers.getContractFactory("SOULTOKEN");
  const soulTokenContract = await SOULTOKENContractFactory.deploy("SOULTKN", "SOUL",soulNFTContract.address);
  console.log("address: ", soulTokenContract.address)
  await soulTokenContract.deployTransaction.wait();
  // address:  0xC3ee3D1d10b5d74A4163E43644d1A17A5445A5C0
  // address:  0xa2d93D4250fF01E84181b1937E117D8944738b49
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
