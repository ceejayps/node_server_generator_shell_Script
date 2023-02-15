#!/bin/sh
clear
# Prompt for the name of the project
echo "What would you like to name your project? "
read project_name

echo "Creating a new directory for the project..."

# Create a new directory for the project
#cd ..
mkdir $project_name

# Navigate to the new directory
cd $project_name

echo "Initializing the Node.js project..."

# Initialize the Node.js project
clear
npm init -y

mkdir -p src/{server/{database/schemas,models,routes,middleware},pages,views,assets,services}
clear
echo "Choose a database: "
echo "1) MongoDB"
echo "2) PostgreSQL"
read -p "Enter the number of your choice: " choice

if [ $choice -eq 1 ]; then
  echo "Setting up MongoDB..."
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

#create user schema

echo "import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
  firstName: {
    type: String,
    required: true
  },
  lastName: {
    type: String,
    required: true
  },
  username: {
    type: String,
    required: true,
    unique: true
  },
  email: {
    type: String,
    required: true,
    unique: true
  },
  password: {
    type: String,
    required: true
  },
  role: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Role',
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const User = mongoose.model('User', userSchema);

export { User };

"> schemas/user.js

echo "import mongoose from 'mongoose';

const roleSchema = new mongoose.Schema({
  name: {
    type: String,
    enum: ['public', 'authenticated', 'admin', 'superadmin'],
    required: true,
    unique: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Role = mongoose.model('Role', roleSchema);

export { Role };
"> schemas/roles.js


cd ..

echo "Setting up Auth..."

echo "
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { User } from './userSchema.js';
import { Role } from './roleSchema.js';

// Register a new user
async function registerUser(req, res) {
  try {
    // Check if the user already exists
    const existingUser = await User.findOne({
      \$or: [{ email: req.body.email }, { username: req.body.username }]
    });
    if (existingUser) {
      return res.status(409).json({ message: 'User already exists' });
    }

    // Hash the password using bcrypt
    const salt = await bcrypt.genSalt();
    const hashedPassword = await bcrypt.hash(req.body.password, salt);

    // Find the role with the name 'public' and assign it to the user
    const role = await Role.findOne({ name: 'public' });
    if (!role) {
      return res.status(500).json({ message: 'Role not found' });
    }

    // Create a new user and save it to the database
    const newUser = new User({
      firstName: req.body.firstName,
      lastName: req.body.lastName,
      username: req.body.username,
      email: req.body.email,
      password: hashedPassword,
      role: role._id // Assign the role's ID to the user
    });
    const savedUser = await newUser.save();

    // Create a JWT token for the new user
    const token = jwt.sign({ userId: savedUser._id }, 'mysecretkey');

    res.status(201).json({ token });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

const loginUser = async (req, res) => {
  const { identifier, password } = req.body;

  try {
    const user = await User.findOne({
      \$or: [{ username: identifier }, { email: identifier }],
    }).populate('role');

    if (!user) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

    const accessToken = jwt.sign({ userId: user._id }, process.env.ACCESS_TOKEN_SECRET);

    res.json({ message: 'Login successful', accessToken, user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};


export { registerUser, loginUser };
"> controllers/auth.js


# Prompt the user for the MongoDB connection information
clear
read -p "Enter the MongoDB host: " host
clear
read -p "Enter the MongoDB port: " port
clear
read -p "Enter the MongoDB username: " username
clear
read -p "Enter the MongoDB password: " password
clear
read -p "Enter the MongoDB database name: " dbname
clear

# Ask the user if the `+srv` option is enabled
read -p "Is the +srv option enabled? (y/n) " srv

# Build the MongoDB URI based on the user input
if [ "$srv" = "y" ]; then
  uri="mongodb+srv://$username:$password@$host/$dbname"
else
  uri="mongodb://$username:$password@$host:$port/$dbname"
fi

# Save the MongoDB URI as an environment variable in the .env file
echo "LIVE_DATABASE_URL=$uri" >> .env

echo "MongoDB URI saved to .env as LIVE_DATABASE_URL"



elif [ $choice -eq 2 ]; then
  db="postgresql"
  echo "Setting up PostgreSQL..."
  npm install pg
  cd src/server

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

# Prompt the user for the DB host
clear
read -p "Enter DB host: " DB_HOST
clear

# Prompt the user for the DB port
read -p "Enter DB port: " DB_PORT
clear

# Prompt the user for the DB username
read -p "Enter DB username: " DB_USER
clear

# Prompt the user for the DB password
read -p "Enter DB password: " DB_PASSWORD
clear

# Prompt the user for the DB name
read -p "Enter DB name: " DB_NAME
clear

# Write the values to the .env file
echo "DB_HOST=$DB_HOST" >> .env
echo "DB_PORT=$DB_PORT" >> .env
echo "DB_USER=$DB_USER" >> .env
echo "DB_PASSWORD=$DB_PASSWORD" >> .env
echo "DB_NAME=$DB_NAME" >> .env

# Confirm the values have been saved
echo "Saved DB credentials to .env file:"
cat .env
else
  echo "Invalid choice. Exiting."
  exit 1
fi


echo "Installing dependencies..."

# Install dependencies
npm install express morgan helmet cors body-parser dotenv jsonwebtoken bcrypt
clear

echo "Installing dev dependencies..."

# Install dev dependencies
npm install -D nodemon
clear

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

// Importing schemas connection file
import { User } from './src/server/database/schemas/user.js';
import { Role } from './src/server/database/schemas/role.js';

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
clear

echo "Setting the 'dev' script and the type to 'module' in the package.json file..."

# Set the "dev" script in package.json and set the type to "module"
# jq is required for this operation and can be installed with brew by running "brew install jq" in the terminal
jq '.scripts.dev = "nodemon server.js" | .type = "module"' package.json > tmp.$$.json && mv tmp.$$.json package.json

clear
echo Creating a .env file

# Create a .env file
touch .env

clear
echo Initializing a Git repository

# Initialize a Git repository
git init

clear
echo Createing a .gitignore file

# Create a .gitignore file
echo "node_modules
*.env

" > .gitignore

clear
# Open the project in Visual Studio Code

echo "Project ready! Opening the project in Visual Studio Code..."

# Open the project in Visual Studio Code
code .

