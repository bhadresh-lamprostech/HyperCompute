const fs = require("fs");
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: __dirname + "/.env" });

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.14",
  paths: {
    artifacts: "./src/artifacts",
  },
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_PROVIDER_URL, //Your RPC URL
      accounts: [process.env.PRIVATE_KEY], //Your private key
    },
    mumbai: {
      url: process.env.MUMBAI_PROVIDER_URL, //Your RPC URL
      accounts: [process.env.PRIVATE_KEY], //Your private key
    },
  },
};
