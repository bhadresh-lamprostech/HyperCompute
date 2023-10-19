const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MessageRouter Contract", function () {
    let messageRouter;

    before(async () => {
        // Assuming that `messageRouter` is already deployed and assigned
        // to this variable, you don't need to deploy it again.
        // You should already have the deployed contract address.
        const contractAddress = "0x9fF0443cdc87d20De5123E4c71f8836af149DcA9"; // Replace with the actual contract address
        const MessageRouterFactory = await ethers.getContractFactory("MessageRouter");
        messageRouter = MessageRouterFactory.attach(contractAddress);
        console.log(messageRouter.address);
    });

    it("Should send a message and pay for gas", async function () {
        const valueInFinney = 10; // 10 Finney
        const valueInWei = ethers.utils.parseUnits(valueInFinney.toString(), "finney");

        const tx = await messageRouter.sendMessage(
            "0x48656c6c6f2c20746869732069732061206d6573736167652e",
            { value: valueInWei }
        );

        await tx.wait();
        console.log("tx:", tx);
    });
});
