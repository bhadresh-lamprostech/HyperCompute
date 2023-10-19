const fs = require("fs");
const hre = require("hardhat");

async function main() {
  const network = hre.network.name;
  const timestamp = new Date().toISOString();

  // contract name here
  const contractName = "MessageRouter";
  const MessageRouterFactory = await hre.ethers.getContractFactory(
    "MessageRouter"
  );
  const messagerouter = await MessageRouterFactory.deploy(
    "0xCC737a94FecaeC165AbCf12dED095BB13F037685",
    "0x8f9C3888bFC8a5B25AED115A82eCbb788b196d2a",
    "11155111",
    "0x0dA52157B9B3AF14fb95EBe0D07F7FF0006c42F3"
  );

  const contractAddress = messagerouter.address;
  console.log(contractAddress)

  const contractInfo = { contractName, network, timestamp, contractAddress };

  // Load existing JSON data or initialize an empty array
  let contractData = [];
  try {
    const existingData = fs.readFileSync("contracts.json", "utf8");
    contractData = JSON.parse(existingData);
  } catch (error) {
    // File doesn't exist or is empty, initialize with an empty array
    contractData = [];
  }

  contractData.push(contractInfo);

  // Write the updated array back to the JSON file
  fs.writeFileSync("contracts.json", JSON.stringify(contractData, null, 2));

  console.log(`Contract "${contractName}" deployed to:`, contractAddress);
  console.log("Network:", network);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
