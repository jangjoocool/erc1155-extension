import { ethers, upgrades } from "hardhat";
import { writeFileSync } from 'fs'

async function main() {
    const contractFactory = await ethers.getContractFactory("BaseERC1155");
    const contract = await upgrades.deployProxy(contractFactory, ["NEW-ERC1155", "https://test-jjh.infura-ipfs.io/ipfs/"]);
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