require('@nomicfoundation/hardhat-toolbox');
require('@openzeppelin/hardhat-upgrades');
require('dotenv').config();

// console.log(process.env);
// const GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY;
// const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;

const GOERLI_PRIVATE_KEY =
  'b16732b7a6de3d38ff021707d2ab55dc3b00b902c1ae5bbdc3b4950959d0ab6b';
const ALCHEMY_API_KEY = 'zsEYV0UsYF2iT-cTHsBEcqWRjvob3svP';

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: '0.8.17',
  networks: {
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY],
    },
  },
};
