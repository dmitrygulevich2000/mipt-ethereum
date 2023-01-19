const { ethers } = require("hardhat");

async function deployImplementation(signer = undefined) {
    signer = signer || (await ethers.getSigner());

    const Escrow = await ethers.getContractFactory("Escrow").then(factory => factory.connect(signer));
    const escrowImpl = await Escrow.deploy();

    await escrowImpl.deployed();
    return escrowImpl
}

async function deployFactory(implAddress, signer = undefined) {
    signer = signer || (await ethers.getSigner());

    const EscrowFactory = await ethers.getContractFactory("EscrowFactory").then(factory => factory.connect(signer));
    const factory = await EscrowFactory.deploy(implAddress);

    await factory.deployed();
    return factory
}

async function newEscrow(factoryAddress, { buyer, seller, costEther, description }, signer = undefined) {
    signer = signer || (await ethers.getSigner());

    const EscrowFactory = await ethers.getContractFactory("EscrowFactory").then(factory => factory.connect(signer));
    const factory = EscrowFactory.attach(factoryAddress);

    const cost = ethers.utils.parseEther(costEther.toString());

    const txResponse = await factory.newEscrow(buyer, seller, cost, description)
    const txReceipt = await txResponse.wait();
    const createdEvent = txReceipt.events.find(event => event.event == 'Created');

    const proxy = await ethers.getContractAt("Escrow", createdEvent.args.escrowProxy, signer);
    
    return proxy;
}

module.exports = { deployImplementation, deployFactory, newEscrow }
