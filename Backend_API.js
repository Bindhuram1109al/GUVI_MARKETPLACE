const express = require('express');
const Web3 = require('web3');
const app = express();

const web3 = new Web3(new Web3.providers.HttpProvider('https://ropsten.infura.io/v3/YOUR_PROJECT_ID'));

const nftContractAddress = '0x...';
const nftContractABI = [...];

app.post('/create-nft', async (req, res) => {
    const { name, description, price } = req.body;
    const nftContract = new web3.eth.Contract(nftContractABI, nftContractAddress);
    try {
        const txCount = await web3.eth.getTransactionCount();
        const tx = {
            from: '0x...', // Your Ethereum account address
            to: nftContractAddress,
            value: web3.utils.toWei(price, 'ether'),
            gas: '20000',
            gasPrice: web3.utils.toWei('20', 'gwei'),
            data: nftContract.methods.createNFT(name, description, price).encodeABI()
        };
        const signedTx = await web3.eth.accounts.signTransaction(tx, '0x...'); // Your Ethereum account private key
        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
        res.json({ message: 'NFT created successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error creating NFT' });
    }
});

app.get('/nfts', async (req, res) => {
    const nftContract = new web3.eth.Contract(nftContractABI, nftContractAddress);
    try {
        const nfts = await nftContract.methods.getNFTs().call();
        res.json(nfts);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching NFTs' });
    }
});

app.listen(3000, () => {
    console.log('Server listening on port 3000');
});