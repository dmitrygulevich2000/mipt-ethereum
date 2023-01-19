const { expect } = require("chai");
const { ethers } = require("hardhat");
const nethelp = require("@nomicfoundation/hardhat-network-helpers");

const utils = require("../scripts/utils.js");

async function deployAll() {
    const impl = await utils.deployImplementation();
    const factory = await utils.deployFactory(impl.address);

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

    return { impl, factory, proxy }
}

describe("Creating Escrow", function () {
    it("should initialize proxy with passed data", async function () {
        const { impl, factory, proxy } = await deployAll();

        expect(await proxy.description()).to.equal("на отл(10)");
        expect(await proxy.cost()).to.equal(ethers.utils.parseEther("10"));
        expect(await proxy.getState()).to.equal("deal created");

        expect(await proxy.address).to.not.equal(impl.address);
        expect(await impl.state()).equal(0);
    });
});

describe("Escrow Work", function () {
    let admin, buyer, seller;
    this.beforeEach(async function () {
        [admin, buyer, seller] = await ethers.getSigners();
    });

    it("deal completed scenario", async function () {
        const { proxy } = await nethelp.loadFixture(deployAll);

        const cost = await proxy.cost();
        const freezeFee = await proxy.freezeFeeRequired();
        const deposit = await proxy.depositRequired();

        await proxy.connect(buyer).pay({ value: deposit });

        await proxy.connect(seller).freezeDeposit({ value: freezeFee });

        await expect(proxy.connect(seller).complete()).to.be.reverted;
        await expect(proxy.connect(buyer).complete()).to.changeEtherBalance(buyer, deposit.sub(cost));

        await expect(proxy.connect(seller).payToSeller()).to.changeEtherBalance(seller, cost.add(freezeFee));

        expect(await proxy.getState()).to.equal("deal completed");
        await expect(proxy.connect(seller).payToSeller()).to.reverted;
    });

    it("deal cancelled by buyer scenario", async function () {
        const { proxy } = await nethelp.loadFixture(deployAll);

        const cost = await proxy.cost();
        const freezeFee = await proxy.freezeFeeRequired();
        const deposit = await proxy.depositRequired();

        await proxy.connect(buyer).pay({ value: deposit });
        await expect(proxy.connect(buyer).cancel()).to.changeEtherBalances([buyer, seller], [deposit, 0]);

        expect(await proxy.getState()).to.equal("deal cancelled");
        await expect(proxy.connect(seller).payToSeller()).to.reverted;
    });

    it("deal cancelled by seller scenario", async function () {
        const { proxy } = await nethelp.loadFixture(deployAll);

        const cost = await proxy.cost();
        const freezeFee = await proxy.freezeFeeRequired();
        const deposit = await proxy.depositRequired();

        await proxy.connect(buyer).pay({ value: deposit });
        await proxy.connect(seller).freezeDeposit({ value: freezeFee });
        await expect(proxy.connect(buyer).cancel()).to.reverted;
        await expect(proxy.connect(seller).cancel()).to.changeEtherBalances([buyer, seller], [deposit, freezeFee]);

        expect(await proxy.getState()).to.equal("deal cancelled");
        await expect(proxy.connect(seller).payToSeller()).to.reverted;
    });

    it("test State.Created", async function () {
        var { proxy } = await nethelp.loadFixture(deployAll);

        const cost = await proxy.cost();
        const freezeFee = await proxy.freezeFeeRequired();
        const deposit = await proxy.depositRequired();

        await expect(proxy.connect(seller).pay({ value: deposit })).reverted; // wrong signer
        await expect(proxy.connect(buyer).pay({ value: deposit.sub(1) })).reverted; // wrong value
        await expect(proxy.connect(seller).freezeDeposit({ value: freezeFee })).reverted; // wrong operations
        await expect(proxy.connect(buyer).complete()).reverted;
        await expect(proxy.connect(seller).payToSeller()).reverted;

        await proxy.connect(buyer).pay({ value: deposit }); // all right: buyer pays
        expect(await proxy.getState()).to.equal("deposit made");

        ({ proxy } = await nethelp.loadFixture(deployAll));
        await expect(proxy.connect(seller).cancel()).to.changeEtherBalances([buyer, seller], [0, 0]); // all right: seller cancels
        expect(await proxy.getState()).to.equal("deal cancelled");

        ({ proxy } = await nethelp.loadFixture(deployAll));
        await expect(proxy.connect(buyer).cancel()).to.changeEtherBalances([buyer, seller], [0, 0]); // all right: buyer cancels
        expect(await proxy.getState()).to.equal("deal cancelled");
    });

    // TODO test other states?
});
