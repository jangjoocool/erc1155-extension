import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades"
import "@nomiclabs/hardhat-etherscan"

import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.2",
  networks: {
    mumbai: {
      url: process.env.MUMBAI_URL || "" ,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    zk: {
      url: "https://public.zkevm-test.net:2083" || "",
      accounts: [process.env.PRIVATE_KEY || ""],
    }
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY
  }
};

export default config;
