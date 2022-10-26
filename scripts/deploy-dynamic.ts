import { ethers, upgrades } from "hardhat";
import { writeFileSync } from 'fs'

async function main() {
    const contractFactory = await ethers.getContractFactory("DynamicHandler");
    // const contract = await contractFactory.deploy();
    // console.log(contract.address);

    const contract = await upgrades.deployProxy(contractFactory, {kind: "uups"});
    await contract.deployed();
    
    const implementation = await upgrades.erc1967.getImplementationAddress(contract.address);
    console.log("Implementation Contract", implementation);
    console.log("Proxy Contract:", contract.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});