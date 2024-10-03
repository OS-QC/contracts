import * as dotenv from 'dotenv';
import { ethers } from 'ethers';
import { parseUnits, formatUnits, defaultAbiCoder } from 'ethers';
dotenv.config();

// Configuración de la red y el proveedor
const provider = new ethers.JsonRpcProvider(`https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);

// Dirección del contrato y ABI
const contractAddress = process.env.CONTRACT_ADDRESS!;
const abi = [
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_addressProvider",
                "type": "address"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "address",
                "name": "owner",
                "type": "address"
            }
        ],
        "name": "ContractDeployed",
        "type": "event"
    },
    {
        "inputs": [],
        "name": "ADDRESSES_PROVIDER",
        "outputs": [
            {
                "internalType": "contract IPoolAddressesProvider",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "POOL",
        "outputs": [
            {
                "internalType": "contract IPool",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "asset",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "premium",
                "type": "uint256"
            },
            {
                "internalType": "address",
                "name": "initiator",
                "type": "address"
            },
            {
                "internalType": "bytes",
                "name": "params",
                "type": "bytes"
            }
        ],
        "name": "executeOperation",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_tokenAddress",
                "type": "address"
            }
        ],
        "name": "getBalance",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_token",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_amount",
                "type": "uint256"
            },
            {
                "internalType": "bytes",
                "name": "_params",
                "type": "bytes"
            }
        ],
        "name": "requestFlashLoan",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_tokenAddress",
                "type": "address"
            }
        ],
        "name": "withdraw",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "stateMutability": "payable",
        "type": "receive"
    }
];

const contract = new ethers.Contract(contractAddress, abi, wallet);

async function main() {
    // Direcciones y datos para la lógica de arbitraje
    const exchanges = ["direccion_exchange1", "direccion_exchange2"];
    const data = [
        defaultAbiCoder.encode(["address", "uint256"], ["direccion_token", parseUnits("1000", 18)]),
        defaultAbiCoder.encode(["address", "uint256"], ["direccion_token", parseUnits("1000", 18)])
    ];
    const params = defaultAbiCoder.encode(["address[]", "bytes[]"], [exchanges, data]);

    // Solicitar un préstamo flash
    const tokenAddress = "direccion_del_token";
    const amount = parseUnits("1000", 18); // Cantidad en unidades del token
    const tx = await contract.requestFlashLoan(tokenAddress, amount, params);
    console.log(`Transacción enviada: ${tx.hash}`);
    await tx.wait();
    console.log('Préstamo flash solicitado con éxito');

    // Verificar el balance del contrato
    const balance = await contract.getBalance(tokenAddress);
    console.log(`Balance del contrato: ${formatUnits(balance, 18)} tokens`);

    // Retirar tokens (solo propietario)
    const withdrawTx = await contract.withdraw(tokenAddress);
    console.log(`Transacción de retiro enviada: ${withdrawTx.hash}`);
    await withdrawTx.wait();
    console.log('Tokens retirados con éxito');
}

main().catch(console.error);
