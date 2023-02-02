// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const pushContractAddress = '0xEFDeb468C681EEF5Df33E58920B3027B52d525D7';

  const SoulNFTContractFactory = await hre.ethers.getContractFactory("SOULNFTS");
  const soulNFTContract = await SoulNFTContractFactory.deploy("SOULNFT", "SFT");
  console.log("address: ", soulNFTContract.address)
  await soulNFTContract.deployTransaction.wait();

  const SOULTOKENContractFactory = await hre.ethers.getContractFactory("SOULTOKEN");
  const soulTokenContract = await SOULTOKENContractFactory.deploy("SOULTKN", "SOUL",soulNFTContract.address, pushContractAddress);
  console.log("address: ", soulTokenContract.address)
  await soulTokenContract.deployTransaction.wait();
  // address:  0x5FbDB2315678afecb367f032d93F642f64180aa3
  // address:  0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
