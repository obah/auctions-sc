import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { vars } from "hardhat/config";

const WALLET_PRIVATE_KEY = vars.get("WALLET_PRIVATE_KEY");

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    "lisk-sepolia": {
      url: "https://rpc.sepolia-api.lisk.com",
      accounts: [WALLET_PRIVATE_KEY],
      gasPrice: 1000000000,
    },
  },
  etherscan: {
    apiKey: {
      "lisk-sepolia": "123",
    },
    customChains: [
      {
        network: "lisk-sepolia",
        chainId: 4202,
        urls: {
          apiURL: "https://sepolia-blockscout.lisk.com/api",
          browserURL: "https://sepolia-blockscout.lisk.com",
        },
      },
    ],
  },
};

export default config;
