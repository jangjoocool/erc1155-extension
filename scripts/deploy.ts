import { ethers, upgrades } from "hardhat";
import { writeFileSync } from 'fs'

async function main() {
    const contractFactory = await ethers.getContractFactory("GenesisNFT");
    const contract = await contractFactory.deploy("GenesisNFT", "GNFT");
    console.log(contract.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});