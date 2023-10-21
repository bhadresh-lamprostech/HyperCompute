const { ethers } = require("hardhat");
require("dotenv").config(); // Ensure that your .env file is correctly configured

async function main() {
    // Replace with the actual contract address
    const contractAddress = "0x46C7f99cc0733F4800C4D54B06A0328194C51EB1";

    // Replace with the contract's ABI
    const contractABI = require("../src/artifacts/contracts/MessageMain.sol/MessageMain.json").abi;

    const providerUrl = process.env.MUMBAI_PROVIDER_URL; // Use your provider URL

    const provider = new ethers.providers.JsonRpcProvider(providerUrl);

    // Replace with your private key or mnemonic phrase
    const privateKey = process.env.PRIVATE_KEY;
    console.log(privateKey)

    // Create a signer with the private key
    const wallet = new ethers.Wallet(privateKey, provider);

    // Connect to the deployed contract using the wallet
    const messageMain = new ethers.Contract(contractAddress, contractABI, wallet);

    // Mock data for byteCode and encodedFunctionData
    const byteCode = "0x608060405234801561000f575f80fd5b5061029f8061001d5f395ff3fe608060405234801561000f575f80fd5b5060043610610029575f3560e01c8063a8e7946d1461002d575b5f80fd5b610047600480360381019061004291906100cf565b61005d565b6040516100549190610197565b60405180910390f35b6060818361006b91906101e4565b60405160200161007b919061024f565b604051602081830303815290604052905092915050565b5f80fd5b5f63ffffffff82169050919050565b6100ae81610096565b81146100b8575f80fd5b50565b5f813590506100c9816100a5565b92915050565b5f80604083850312156100e5576100e4610092565b5b5f6100f2858286016100bb565b9250506020610103858286016100bb565b9150509250929050565b5f81519050919050565b5f82825260208201905092915050565b5f5b83811015610144578082015181840152602081019050610129565b5f8484015250505050565b5f601f19601f8301169050919050565b5f6101698261010d565b6101738185610117565b9350610183818560208601610127565b61018c8161014f565b840191505092915050565b5f6020820190508181035f8301526101af818461015f565b905092915050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601160045260245ffd5b5f6101ee82610096565b91506101f983610096565b9250828201905063ffffffff811115610215576102146101b7565b5b92915050565b5f8160e01b9050919050565b5f6102318261021b565b9050919050565b61024961024482610096565b610227565b82525050565b5f61025a8284610238565b6004820191508190509291505056fea2646970667358221220433907f7847ccab458e9aa1bb84694671d4b1040a5b6daceef52188ee72bfc8764736f6c63430008150033";
    const encodedFunctionData = "0x53076e4a0000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000a";
    const uuid = "0xf9c909a1668dcea37747b35f54f55c46514135aa340b28ee96c72030e49a4954";

    console.log("Contract Address:", contractAddress);

    const gasLimit = 300000000;
    const valueInFinney = 10; // 10 Finney
    const valueInWei = ethers.utils.parseUnits(valueInFinney.toString(), "finney");
    // Send a transaction to the receiveData function
    const tx = await messageMain.receiveData({ value: valueInWei });
    console.log(tx)
    // Wait for the transaction to be mined
    const receipt = await tx.wait();

    // Debug output
    console.log("Transaction Hash:", tx.hash);
    console.log("Deployed Address:", receipt.to);
    console.log("Success:", receipt.status);
    console.log("Data:", receipt.data);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
