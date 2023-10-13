const hre = require('hardhat');

// Deployed contract address :
async function main() {
  const [lawyer, payer, payee] = await hre.ethers.getSigners();

  const P2pDex = await hre.ethers.getContractFactory('EscrowFactory');
  const p2pDex = await P2pDex.deploy();
  await p2pDex.deployed();

  console.log('Contract Address', p2pDex.address);

  const payerEscrows = await p2pDex.getEscrowsForUser(payer.address);
  console.log('Payer Escrows :', payerEscrows);

  const createEscrow = await p2pDex
    .connect(payer)
    .createEscrow(
      payer.address,
      '0x7af963cf6d228e564e2a0aa0ddbf06210b38615d',
      '0x65a5ba240CBd7fD75700836b683ba95EBb2F32bd',
      1,
      1
    );
  await createEscrow.wait();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
