const fs = require("fs");

const collectionName = "BNE DAO Series1";
const collectionSize = 6;

const imageIpfs =
  "ipfs://bafybeibcq43x3ezyhtja66a3bmbidjrgv72vqglgu6o7qdql3bqqcszq3q";
const description = "BNE DAO First NFT Collection";

for (num = 1; num <= collectionSize; num++) {
  const metadata = {
    name: `${collectionName} #${num}`,
    description: `${description}`,
    image: `${imageIpfs}(${num}).jpeg`,
  };

  // convert JSON object to string
  const data = JSON.stringify(metadata);

  fs.mkdirSync("metadata", { recursive: true });
  // write JSON string to a file
  fs.writeFile(`./metadata/${num}.json`, data, (err) => {
    if (err) {
      throw err;
    }
    console.log("JSON datas are saved.");
  });
}
