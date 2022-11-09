import { ethers, upgrades } from "hardhat";
import { writeFileSync } from 'fs'

async function main() {
    const contractFactory = await ethers.getContractFactory("PublicMinting");
    const contract = await upgrades.deployProxy(contractFactory, ["PM-Test", "https://test-jjh.infura-ipfs.io/ipfs/"], {kind: "uups"});
    await contract.deployed();
    
    const implementation = await upgrades.erc1967.getImplementationAddress(contract.address);
    console.log("Implementation Contract", implementation)
    console.log("Proxy Contract:", contract.address);

    writeFileSync(__dirname + '/../.proxy-contract', contract.address);
    writeFileSync(__dirname + '/../.implementation-contract', implementation);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});