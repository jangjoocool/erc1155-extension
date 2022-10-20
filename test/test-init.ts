import { expect } from "chai";
import { Contract } from "ethers";
import { ethers, upgrades } from "hardhat";

describe("Base ERC1155", () => {
    let contract: Contract;

    beforeEach(async () => {
        const Contract = await ethers.getContractFactory("BaseERC1155");
        contract = await upgrades.deployProxy(Contract, ["NEW-ERC1155", "https://ipfs.io/ipfs/"], {
            kind: "uups",
        });
    });

    it("deploy", async () => {
        console.log(contract.address)
        expect(contract.address).to.not.undefined;
    });
});