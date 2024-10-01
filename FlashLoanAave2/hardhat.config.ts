import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";

const INFURA_ENDPOINT = process.env.INFURA_GOERLY_ENDPOINT || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";

if (!INFURA_ENDPOINT || !PRIVATE_KEY) {
  throw new Error("Please set your INFURA_ENDPOINT and PRIVATE_KEY in a .env file");
}

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    goerli: {
      url: INFURA_ENDPOINT,
      accounts: [PRIVATE_KEY],
    }
  },
};

export default config;
