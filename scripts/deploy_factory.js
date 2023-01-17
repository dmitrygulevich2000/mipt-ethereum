const utils = require("./utils.js");

async function main() {
  const impl = await utils.deployImplementation();
  console.log(`Escrow implementation deployed to ${impl.address}`);

  const factory = await utils.deployFactory(impl.address);
  console.log(`EscrowFactory deployed to ${factory.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});