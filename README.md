# Token ERC20

ERC20 is the most widely use standard that tokens implement in order to have the same characteristics. It makes easier for developers to implement their own token without worrying about all the other token characteristics to take account. Tokens using this standard are able to interact natively between each other so it allows people to trade a huge diversity of tokens.

For our Token ERC20, we used Openzeppelin which is a library of secured and vetted smart contracts


### [Openzeppelin](https://github.com/OpenZeppelin/openzeppelin-solidity)

    npm i openzeppelin-solidity

## Environment - Arch Linux

### [Metamask](https://metamask.io/)

#### Chrome extension allowing us to connect to the Ethereum main net, testnets (Ropsten, Rinkeby, Koven)

Just install it like any other chrome extension

### [Truffle](https://truffleframework.com/)

#### Environment that allows us to compile, deploy and migrate smart contracts

We use the truffle@4.1.15 version

    npm i -g truffle@4.1.15

#### Usage :

    truffle compile
    truffle migrate
    truffle migrate --reset if contracts have already been migrated once

#### To interact with our contracts with the [Web3.js](https://github.com/ethereum/wiki/wiki/JavaScript-API) library

    truffle develop or truffle console

### [Ganache](https://truffleframework.com/) : Local blockchain

We just need to create the package by taking it on the AUR

    git clone https://aur.archlinux.org/ganache.git
    makepkg -s
    sudo pacman -U --noconfirm file.pkg.tar.xz

### Solidity compiler v0.4.24

We also need to match the solidity compiler with the truffle one

    npm i solc@0.4.24

## Setup

    mkdir token-erc20
    cd token-erc20
    truffle init

### Configure truffle-config.js to connect to ganache running on port 7545

    networks: {
        development: {
        host: "127.0.0.1",     
        port: 7545,            
        network_id: "*",       // Any network (default: none)
        }
    }

## Ropsten - Infura

On metamask, select Ropsten and get some ether on a [faucet](https://faucet.metamask.io/)

In order to connect to the Ropsten testnet, we'll use [Infura](https://infura.io). First, we need to [register](https://infura.io/signup) in order to create our API endpoint.

#### [Dotenv](https://www.npmjs.com/package/dotenv)

Later we'll need our metamask wallet mnemonic and our Infura API key so for security reasons, we need to hide them.
We use the npm package dotenv in order to read .env files.

    npm i dotenv

Create a .env file and store the mnemonic and the Infura API key

#### Install HDWallet Provider

    npm i --save truffle-hdwallet-provider

#### Configure truffle in order to connect to Ropsten

    ropsten: {
      provider: () => new HDWalletProvider(process.env.MNEMONIC, "https://ropsten.infura.io/" + process.env.INFURA_API_KEY),
      network_id: 3,       // Ropsten's id
      gas: 5500000,        // Ropsten has a lower block limit than mainnet
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    }

