const { ethers } = require("hardhat");
const utils = require("./utils.js");

async function main() {
    const impl = await utils.deployImplementation();
    console.log(`Escrow implementation deployed to ${impl.address}`);

    const factory = await utils.deployFactory(impl.address);
    console.log(`EscrowFactory deployed to ${factory.address}`);

    const [_, buyer, seller] = await ethers.getSigners();
    const proxy = await utils.newEscrow(
        factory.address,
        {
            buyer: buyer.address,
            seller: seller.address,
            costEther: 10,
            description: "на отл(10)",
        },
        seller
    );

    console.log(`Escrow proxy created at ${proxy.address}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
