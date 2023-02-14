#!/bin/sh

# Prompt for the name of the project
echo -n "What would you like to name your project? "
read project_name

echo "Creating a new directory for the project..."

# Create a new directory for the project
cd ..
mkdir $project_name

# Navigate to the new directory
cd $project_name

echo "Initializing the Node.js project..."

# Initialize the Node.js project
npm init -y

mkdir -p src/{server/{database,models,routes,middleware},pages,views,assets,services}

echo "Choose a database: "
echo "1) MongoDB"
echo "2) PostgreSQL"
read -p "Enter the number of your choice: " choice

if [ $choice -eq 1 ]; then
  echo "Setting up MongoDB..."
  npm install mongodb
  npm install mongoose
  cd src/server/database 

echo "import mongoose from 'mongoose';

const db = async () => {
  try {
    const connection = await mongoose.connect(process.env.LIVE_DATABASE_URL, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log(`MongoDB connected to ${connection.connection.host}`);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

export default db;" > connection.js

cd ../../..

elif [ $choice -eq 2 ]; then
  db="postgresql"
  echo "Setting up PostgreSQL..."
  npm install pg
  cd src/server/database 

  echo "import { Client } from 'pg';

const db = new Client({
host: process.env.DB_HOST,
port: process.env.DB_PORT,
user: process.env.DB_USER,
password: process.env.DB_PASSWORD,
database: process.env.DB_NAME
});

db.connect(async (err) => {
if (err) {
console.error('connection error', err.stack)
} else {
console.log('connected to PostgreSQL');
}
});

export default db;" > connection.js

  cd ../../..
else
  echo "Invalid choice. Exiting."
  exit 1
fi

echo "You selected $db"


echo "Installing dependencies..."

# Install dependencies
npm install express morgan helmet cors body-parser dotenv jsonwebtoken bcrypt

echo "Installing dev dependencies..."

# Install dev dependencies
npm install -D nodemon

echo "Creating the server.js file..."

# Create the server.js file
touch server.js

echo "// Importing necessary modules
import express from 'express';
import morgan from 'morgan';
import helmet from 'helmet';
import cors from 'cors';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';

// Importing database connection file
import db from './src/server/database/connection.js'

// Initializing Express server
const server = express();

// Setting port
const port = process.env.PORT ?? 3000;

// Configuring environment variables
dotenv.config();

// Using security-related middlewares
server.use(helmet());
server.use(helmet.crossOriginResourcePolicy({policy:'cross-origin'}));

// Using middlewares for body parsing
server.use(bodyParser.json());
server.use(bodyParser.urlencoded({extended:false}));

// Using morgan for logging HTTP requests
server.use(morgan('dev'));

// Using CORS
server.use(cors());

// Route for root directory
server.get('/', (req, res) => res.send('Hello World!'));

// Starting the Express server
server.listen(port, () => console.log('Example server listening on port ', port));

" > server.js

echo "Setting the 'dev' script and the type to 'module' in the package.json file..."

# Set the "dev" script in package.json and set the type to "module"
# jq is required for this operation and can be installed with brew by running "brew install jq" in the terminal
jq '.scripts.dev = "nodemon server.js" | .type = "module"' package.json > tmp.$$.json && mv tmp.$$.json package.json

echo Creating a .env file

# Create a .env file
touch .env

echo Initializing a Git repository

# Initialize a Git repository
git init

echo Createing a .gitignore file

# Create a .gitignore file
echo "node_modules
*.env

" > .gitignore


# Open the project in Visual Studio Code

echo "Opening the project in Visual Studio Code..."

# Open the project in Visual Studio Code
code .

echo "Project ready! Open in Visual Studio Code."
