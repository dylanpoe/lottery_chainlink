require('babel-register');
require('babel-polyfill');

const HDWalletProvider = require('@truffle/hdwallet-provider');
// const mnemonic = "Your mnemonic"
const mnemonic = "e0fd94f35f341a13e00549b54d77f72a15a8ec4b5c531c8559f6c8943d91ec5a"
// const fs = require('fs');
// const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard BSC port (default: none)
      network_id: "*",       // Any network (default: none)
    },
    testnet: {
      provider: () => new HDWalletProvider("e0fd94f35f341a13e00549b54d77f72a15a8ec4b5c531c8559f6c8943d91ec5a",`https://rinkeby.infura.io/v3/4ce84106a38e4ce592e5d941ae7e97c8`),
      network_id: 4,
      confirmations: 1,
      timeoutBlocks: 30,
      skipDryRun: true
    },
    bsc: {
      provider: () => new HDWalletProvider(mnemonic, `https://bsc-dataseed1.binance.org`),
      network_id: 56,
      confirmations: 4,
      timeoutBlocks: 50,
      skipDryRun: true
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },
  // contracts_directory: './src/contracts/',
  contracts_build_directory: './src/abis/',
  // Configure your compilers
  compilers: {
    solc: {
      version: ">=0.5.0 <0.9.0", // A version or constraint - Ex. "^0.5.0",
      optimizer: {
        enabled: true,
        runs: 200
      },
    }
  }
}