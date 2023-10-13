const hre = require('hardhat');

// Deployed contract address :
async function main() {
  const P2pDex = await hre.ethers.getContractFactory('EscrowFactory');
  const p2pDex = await P2pDex.deploy();
  await p2pDex.deployed();

  console.log('Contract Address', p2pDex.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
