const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MessageRouter Contract", function () {
    let messageRouter;

    before(async () => {
        // Assuming that `messageRouter` is already deployed and assigned
        // to this variable, you don't need to deploy it again.
        // You should already have the deployed contract address.
        const contractAddress = "0x6431Ab17C686FBF092dDEf83a1BcDef75ad603CE"; // Replace with the actual contract address
        const MessageRouterFactory = await ethers.getContractFactory("MessageRouter");
        messageRouter = MessageRouterFactory.attach(contractAddress);
        console.log(messageRouter.address);
    });

    it("Should send a message and pay for gas", async function () {
        const valueInFinney = 20; // 10 Finney
        const valueInWei = ethers.utils.parseUnits(valueInFinney.toString(), "finney");

        const tx = await messageRouter.sendMessage(
            "0x608060405234801561001057600080fd5b506101a1806100206000396000f3fe608060405234801561001057600080fd5b506004361061002b5760003560e01c8063a8e7946d14610030575b600080fd5b61004361003e3660046100b8565b610059565b60405161005091906100eb565b60405180910390f35b60606100658284610139565b604051602001610088919060e09190911b6001600160e01b031916815260040190565b604051602081830303815290604052905092915050565b803563ffffffff811681146100b357600080fd5b919050565b600080604083850312156100cb57600080fd5b6100d48361009f565b91506100e26020840161009f565b90509250929050565b600060208083528351808285015260005b81811015610118578581018301518582016040015282016100fc565b506000604082860101526040601f19601f8301168501019250505092915050565b63ffffffff81811683821601908082111561016457634e487b7160e01b600052601160045260246000fd5b509291505056fea264697066735822122090166c2736679ec0c6c95871accff1d675f125ef1b37cdb78f80e310aa01f63b64736f6c63430008130033",
            "0x53076e4a00000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000032",
            { value: valueInWei }
        );

        await tx.wait();
        console.log("tx:", tx);
    });
});
