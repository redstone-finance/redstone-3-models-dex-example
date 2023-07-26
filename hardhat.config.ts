import {HardhatUserConfig} from 'hardhat/types';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 10000, // it slightly increases gas for contract deployment but decreases for user interactions
      },
    },
  },

  networks: {
    red: {
      url: `YOUR_SUBNET_RPC`,
      accounts: ["YOUR_SUBNET_PRIV_KEY"]
    }
  }
};
export default config;