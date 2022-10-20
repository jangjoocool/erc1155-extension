import hre, { upgrades } from 'hardhat';
import { readFileSync } from 'fs'

async function main() {
    const address = readFileSync(__dirname + '/../.proxy-contract', 'utf8').toString();
    const implementation = await upgrades.erc1967.getImplementationAddress(address);
    
    await hre.run("verify:verify", {
        address: implementation,
        contract: "contracts/ERC1155V2.sol:ERC1155V2",
    });
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});