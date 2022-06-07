import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BigNumber, utils } from "ethers";
import { ethers, waffle } from "hardhat";
import {
  AppointmentStoreFactory,
  // eslint-disable-next-line camelcase
  AppointmentStoreFactory__factory,
  FakeToken,
  // eslint-disable-next-line camelcase
  FakeToken__factory,
  // eslint-disable-next-line camelcase
  Store__factory,
} from "../typechain/index";
import { expect } from "./utils/shared/expect";

describe("AppointmentStoreFactory", () => {
  let owner: SignerWithAddress,
    signer1: SignerWithAddress,
    signer2: SignerWithAddress;

  let factory: AppointmentStoreFactory;
  // eslint-disable-next-line camelcase
  let Factory: AppointmentStoreFactory__factory;

  let storeByteCode: string;
  const currentTimeorg = Math.floor(
    Date.parse("2022-06-07T16:30:00.000Z") / 1000
  );

  // eslint-disable-next-line camelcase
  let storeContractFactory: Store__factory;

  // eslint-disable-next-line camelcase
  let tokenFactory: FakeToken__factory;
  let fakeToken: FakeToken;

  before("before", async () => {
    [owner, signer1, signer2] = await ethers.getSigners();

    Factory = await ethers.getContractFactory("AppointmentStoreFactory");
    factory = (await Factory.deploy()) as AppointmentStoreFactory;
    await factory.deployed();

    storeContractFactory = await ethers.getContractFactory("Store");

    tokenFactory = await ethers.getContractFactory("FakeToken");
    fakeToken = (await tokenFactory.deploy()) as FakeToken;
    await fakeToken.deployed();
  });

  before("load store bytecode", async () => {
    storeByteCode = (await ethers.getContractFactory("Store")).bytecode;
  });

  // before("load apppointment bytecode", async () => {
  //   appointmentByteCode = (await ethers.getContractFactory("Appointment"))
  //     .bytecode;
  // });

  it("owner is deployer", async () => {
    expect(await factory.admin()).to.eq(owner.address);
  });

  it("factory bytecode size", async () => {
    expect(
      ((await waffle.provider.getCode(factory.address)).length - 2) / 2
    ).to.matchSnapshot();
  });

  it("store bytecode size", async () => {
    await factory.createStore(signer1.address, fakeToken.address);

    const functionParams = utils.defaultAbiCoder.encode(
      ["address", "address", "uint8"],
      [
        factory.address,
        signer1.address,
        (await factory.getStores(signer1.address)).length - 1,
      ]
    );

    const poolAddress = ethers.utils.getCreate2Address(
      factory.address,
      utils.keccak256(functionParams),
      utils.keccak256(storeByteCode)
    );
    expect(
      ((await waffle.provider.getCode(poolAddress)).length - 2) / 2
    ).to.matchSnapshot();
  });

  it("appointment bytecode size", async () => {
    // await factory.createStore(signer1.address);
    // const functionParams = utils.defaultAbiCoder.encode(
    //   ["address", "address", "uint8"],
    //   [
    //     factory.address,
    //     signer1.address,
    //     (await factory.getStores(signer1.address)).length - 1,
    //   ]
    // );
    // const poolAddress = ethers.utils.getCreate2Address(
    //   factory.address,
    //   utils.keccak256(functionParams),
    //   utils.keccak256(storeByteCode)
    // );
    // expect(
    //   ((await waffle.provider.getCode(poolAddress)).length - 2) / 2
    // ).to.matchSnapshot();
  });

  it("should create store", async () => {
    const storeCreate = await factory.createStore(
      signer1.address,
      fakeToken.address
    );

    // function params takes in factory, owner address and the index of store which is determined by (number of stores - 1)
    const functionParams = utils.defaultAbiCoder.encode(
      ["address", "address", "uint8"],
      [
        factory.address,
        signer1.address,
        (await factory.getStores(signer1.address)).length - 1,
      ]
    );
    // similar implementations with ethers.utils.getCreate2Address
    // const create2Inputs = [
    //   "0xff",
    //   factory.address,
    //   utils.keccak256(functionParams),
    //   utils.keccak256(storeByteCode),
    // ];
    // const sanitizedInput = `0x${create2Inputs.map((i) => i.slice(2)).join("")}`;
    // const _storeAddress = utils.getAddress(
    //   `0x${utils.keccak256(sanitizedInput).slice(-40)}`
    // );
    // const _address = ethers.utils.getContractAddress(storeCreate);
    // const secondStore = ethers.utils.getStoresCreate2Address()

    const storeAddress = ethers.utils.getCreate2Address(
      factory.address,
      utils.keccak256(functionParams),
      utils.keccak256(storeByteCode)
    );
    // ensure event emits the correct stores
    await expect(storeCreate)
      .to.emit(factory, "StoreCreated")
      .withArgs(
        storeAddress,
        signer1.address,
        (
          await factory.getStores(signer1.address)
        ).length
      );

    expect(await factory.storeOwner(storeAddress)).to.equal(signer1.address);
  });

  it("should return array of stores for owners with multiple stores", async () => {
    await factory.createStore(signer1.address, fakeToken.address);
    const functionParams = utils.defaultAbiCoder.encode(
      ["address", "address", "uint8"],
      [
        factory.address,
        signer1.address,
        (await factory.getStores(signer1.address)).length - 1,
      ]
    );
    const storeAddress = ethers.utils.getCreate2Address(
      factory.address,
      utils.keccak256(functionParams),
      utils.keccak256(storeByteCode)
    );

    // check if second store address if correct
    const latestStore = await factory.ownerStores(
      signer1.address,
      (await factory.getStores(signer1.address)).length - 1
    );

    expect(latestStore).to.equal(storeAddress);

    const stores = await factory.getStores(signer1.address);

    expect(stores.length).to.equal(
      (await factory.getStores(signer1.address)).length
    );
  });

  it("should create appointment", async () => {
    const _store = await factory.ownerStores(signer1.address, 0);

    const currentTime = BigNumber.from(currentTimeorg);
    console.log(currentTime);
    const appointmentCreate = await factory.connect(signer2).createAppointment({
      datetime: currentTime,
      storeAddress: _store,
      occasion: "steam hair",
      attended: false,
      cancelled: false,
    });
    console.log("created appointment");

    const store = storeContractFactory.attach(_store);

    await expect(appointmentCreate)
      .to.emit(store, "CreateAppointment")
      .withArgs([currentTime, _store, "steam hair", false, false]);

    const appointmentCount = await store.customerAppointmentCount(
      signer2.address
    );

    expect(appointmentCount).to.equal(1);
    const _time = (currentTimeorg / 60) * 60;
    console.log(_time);
    const appt = await store.customersTimeAppointment(
      signer2.address,
      currentTime
    );

    expect(appt[0]).to.equal(currentTime);
    expect(appt[1]).to.equal(store.address);
    expect(appt[2]).to.equal("steam hair");
    expect(appt[3]).to.equal(false);
    expect(appt[4]).to.equal(false);
  });

  // it("should fail creating appointment with the same time as previous", async () => {
  //   const _store = await factory.ownerStores(signer1.address, 0);
  //   console.log(`current: ${currentTimeorg}`);
  //   await expect(
  //     await factory.connect(signer2).createAppointment({
  //       datetime: BigNumber.from(currentTimeorg),
  //       storeAddress: _store,
  //       occasion: "steam hair",
  //       attended: false,
  //       cancelled: false,
  //     })
  //   ).to.be.revertedWith(
  //     "Appointment already exist within 60 mins of intended time"
  //   );
  // });

  // it("should fail creating appointment within 60 mins of previous appointment", async () => {
  //   const _store = await factory.ownerStores(signer1.address, 0);
  //   console.log(`current: ${currentTimeorg}`);
  //   await expect(
  //     await factory.connect(signer2).createAppointment({
  //       datetime: BigNumber.from(currentTimeorg - 1800),
  //       storeAddress: _store,
  //       occasion: "steam hair",
  //       attended: false,
  //       cancelled: false,
  //     })
  //   ).to.be.revertedWith(
  //     "Appointment already exist within 60 mins of intended time"
  //   );
  // });

  it("should cancel appointment", async () => {
    const _store = await factory.ownerStores(signer1.address, 0);
    await factory.connect(signer2).cancelAppointment(_store, currentTimeorg);

    const store = storeContractFactory.attach(_store);
    const appt = await store.customersTimeAppointment(
      signer2.address,
      currentTimeorg
    );

    const appt2 = await store.customerAppointments(
      signer2.address,
      await store.customerAppointmentCount(signer2.address)
    );

    expect(appt.cancelled).to.equal(true);
    expect(appt.storeAddress).to.equal(ethers.constants.AddressZero);
    expect(appt2.storeAddress).to.equal(ethers.constants.AddressZero);
  });
});
