import dotenv from 'dotenv'

dotenv.config()

const AppConfig = {
  API_PREFIX: process.env.API_PREFIX,
  NODE_ENV: process.env.NODE_ENV || 'development',
  MY_PORT: process.env.MY_PORT || 5000,
  JWT_SECRET_KEY: process.env.JWT_SECRET_KEY || 'MyS3cr3t_JWT$ecret!2024.',
  JWT_EXPIRES: process.env.JWT_EXPIRES,
  DIALECT: process.env.SQL_DIALECT,
  DB_USER: process.env.DB_USER || '',
  DB_PASSWORD: process.env.DB_PASSWORD,
  DB_HOST: process.env.DB_HOST,
  DB_PORT: process.env.DB_PORT,
  DB_NAME: process.env.DB_NAME || '',
  PROVIDER_CONTEXT: process.env.PROVIDER_CONTEXT || '',
  COINBASE_API_URL: process.env.COINBASE_API_URL || '',
  COINGECKO_API_URL: process.env.COINGECKO_API_URL || '',
  USDT_CONTRACT_ADDRESS: process.env.USDT_CONTRACT_ADDRESS || '',
  ETH_ADDRESS: process.env.ETH_ADDRESS || '',
  GANACHE_RUL: process.env.GANACHE_RUL || 'http://localhost:7545',
  INFURA_API_KEY: process.env.INFURA_API_KEY || 'http://localhost:7545',
  PRIVATE_KEY: process.env.PRIVATE_KEY || 'http://localhost:7545',
}

export default Object.freeze(AppConfig)