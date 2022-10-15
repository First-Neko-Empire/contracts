import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Characters } from "../typechain-types";

describe("Characters", async () => {
  let owner: SignerWithAddress;
  let minter: SignerWithAddress;
  let user: SignerWithAddress;

  let characters: Characters;

  before(async () => {
    [owner, minter, user] = await ethers.getSigners();

    const CharactersContract = await ethers.getContractFactory("Characters");
    characters = await CharactersContract.deploy();
  })

  it("Balance is > 0", async () => {
    await characters.connect(owner).mint(user.address, 0, 10);

    const balance = await characters.balanceOf(user.address, 0);
    expect(balance).to.equal(10);
  })

  it("Set Minter", async () => {
    await characters.connect(owner).setupRoleMinter(minter.address);
    await characters.connect(minter).mint(user.address, 1, 10);

    const balance = await characters.balanceOf(user.address, 1);
    expect(balance).to.equal(10);
  })

  it("Check balance", async () => {
    await characters.connect(minter).mint(user.address, 29, 10);
    const balance = await characters.getBalanceByAddress(user.address);
    expect(balance.length).to.equal(30)
  })

  it("Check URI", async () => {
    await characters.connect(owner).setURI("ipfs://_/{id}.json");
    const uri = await characters.uri(0);
    expect(uri).to.equal("ipfs://_/{id}.json");
  })
})