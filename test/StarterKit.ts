import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Characters, StarterKit } from "../typechain-types";

describe("Starter Kit", async () => {
    let owner: SignerWithAddress;
    let user: SignerWithAddress;

    let characters: Characters;
    let starterKit: StarterKit;

    before(async () => {
        [owner, user] = await ethers.getSigners();
    
        const CharactersContract = await ethers.getContractFactory("Characters");
        const StarterKitContract = await ethers.getContractFactory("StarterKit");

        characters = await CharactersContract.deploy();
        starterKit = await StarterKitContract.deploy(characters.address);
    })

    it("Set Minter to kit", async () => {
        await characters.connect(owner).setupRoleMinter(starterKit.address);
        await starterKit.connect(user).openStarterKit();
        const balance = await characters.getBalanceByAddress(user.address);
        
        expect(balance[25]).to.equal(1);
    })
})