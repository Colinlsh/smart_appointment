import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect, util } from "chai";
import { utils } from "ethers";
import { ethers } from "hardhat";
import { AppointmentController } from "../typechain/index";

// describe("Greeter", function () {
//   it("Should return the new greeting once it's changed", async function () {
//     const Greeter = await ethers.getContractFactory("Greeter");
//     const greeter = await Greeter.deploy("Hello, world!");
//     await greeter.deployed();

//     expect(await greeter.greet()).to.equal("Hello, world!");

//     const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

//     // wait until the transaction is mined
//     await setGreetingTx.wait();

//     expect(await greeter.greet()).to.equal("Hola, mundo!");
//   });
// });

describe("AppointmentController", () => {
  let owner: SignerWithAddress,
    signer1: SignerWithAddress,
    signer2: SignerWithAddress;

  let controller: AppointmentController;

  before("before", async () => {
    const Controller = await ethers.getContractFactory("AppointmentController");
    controller = (await Controller.deploy()) as AppointmentController;
    await controller.deployed();
    [owner, signer1, signer2] = await ethers.getSigners();
  });

  it("should create store", async () => {
    expect(await controller.admin()).to.equal(owner.address);
    const storeCreate = await controller.setupStore(signer1.address);
    const _store = await ethers.getContractFactory("Store");

    const _a = utils.defaultAbiCoder.encode(["address"], [signer1.address]);
    const create2Inputs = [
      "0xff",
      controller.address,
      utils.keccak256(_a),
      utils.keccak256(_store.bytecode),
    ];
    const sanitizedInput = `0x${create2Inputs.map((i) => i.slice(2)).join("")}`;
    const _storeAddress = utils.getAddress(
      `0x${utils.keccak256(sanitizedInput).slice(-40)}`
    );

    const address = ethers.utils.getContractAddress(storeCreate);
    // const address2 = ethers.utils.getCreate2Address()

    // console.log(storeCreate);
    console.log(`signer1:${signer1.address}`);
    console.log(`owner:${owner.address}`);
    console.log(`getContractAddress method: ${address}`);
    console.log(`create2 method: ${_storeAddress}`);
    const store = _store.attach(_storeAddress);
    console.log(store.address);

    // await expect(storeCreate)
    //   .to.emit(controller, "StoreSetup")
    //   .withArgs(_storeAddress, signer1.address);

    expect(await controller.stores(0)).to.equal(_storeAddress);
    console.log(await controller.storeOwner(_storeAddress));
    expect(await controller.storeOwner(_storeAddress)).to.equal(
      signer1.address
    );
  });
});
