const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MessageMain Contract", function () {
  let messageMain;

  before(async () => {
    const MessageMainFactory = await ethers.getContractFactory("MessageMain");
    messageMain = await MessageMainFactory.deploy("0xcc737a94fecaec165abcf12ded095bb13f037685"); // Replace with your actual mailbox address
    await messageMain.deployed();
  });

  it("Should emit MessageReceived event", async function () {
    const tx = await messageMain.handle(1, "0xSenderAddress", "0xBody");
    await tx.wait();

    const events = await messageMain.queryFilter("MessageReceived", tx.blockNumber);

    expect(events.length).to.equal(1);

    const event = events[0];
    expect(event.args.origin).to.equal(1);
    expect(event.args.sender).to.equal("0xSenderAddress");
    expect(event.args.body).to.equal("0xBody");
  });
});
