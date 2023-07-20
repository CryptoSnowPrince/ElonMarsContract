import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.19",
      },
      {
        version: "0.8.17",
      },
      {
        version: "0.8.7",
      },
      {
        version: "0.7.4",
      },
      {
        version: "0.7.0",
      },
      {
        version: "0.6.12",
      },
      {
        version: "0.6.7",
        settings: {},
      },
      {
        version: "0.5.6",
      },
      {
        version: "0.5.5",
        settings: {},
      },
    ],
  },
};

export default config;
