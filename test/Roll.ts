import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Characters, VRFCoordinatorV2Mock, RollMock } from "../typechain-types";

describe("Roll", async () => {
    let owner: SignerWithAddress;
    let user: SignerWithAddress;

    let characters: Characters;
    let vrfCoordinator: VRFCoordinatorV2Mock;
    let roll: RollMock;

    before(async () => {
        [owner, user] = await ethers.getSigners();

        const CharactersContract = await ethers.getContractFactory("Characters");
        const VRFContract = await ethers.getContractFactory("VRFCoordinatorV2Mock");
        const RollContract = await ethers.getContractFactory("RollMock");

        characters = await CharactersContract.deploy();
        vrfCoordinator = await VRFContract.deploy(0,0);
        roll = await RollContract.deploy(1, characters.address, vrfCoordinator.address);
    })

    it("Create Subscription", async () => {
        await characters.setupRoleMinter(roll.address);

        await vrfCoordinator.createSubscription();
        await vrfCoordinator.addConsumer(1, roll.address);

        const consumer = await vrfCoordinator.getSubscription(1);
        expect(consumer[3][0]).to.equal(roll.address);
    })

    it("Set minters and check mint", async () => {
        var requests = 0;

        while (requests < 10) {
            await roll.connect(user).requestRandomCharacter({ value: ethers.utils.parseEther("0.1")});
            await vrfCoordinator.fulfillRandomWords(requests + 1, roll.address);
            requests++;
        }

        const userCharacters = await characters.getBalanceByAddress(user.address);
        expect(userCharacters[22]).to.equal(1);
    })
})