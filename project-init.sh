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

mkdir -p src/{server/{database/schemas,controllers,routes,middleware},views,assets,services}
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
  console.log(process.env.LIVE_DATABASE_URL)
  try {
        const connection = await mongoose.connect(process.env.LIVE_DATABASE_URL,
            {
                useNewUrlParser:true,
                useUnifiedTopology:true,
            })
            console.log(`mongoDB connected to ${connection.connection.host}`);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

export default db;
" > connection.js

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
import { User } from '../database/schemas/user.js';
import { Role } from '../database/schemas/roles.js';

// Register a new user
const registerUser = async (req, res) => {
  const { firstName, lastName, username, email, password } = req.body;

  try {
    const user = await User.findOne({ \$or: [{ email }, { username }] });

    if (user) {
      return res.status(400).json({ message: 'User already exists' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Find the role with the name 'public' and assign it to the user
    const role = await Role.findOne({ name: 'public' });
    if (!role) {
      return res.status(500).json({ message: 'Role not found' });
    }

    const newUser = new User({
      firstName,
      lastName,
      username,
      email,
      password: hashedPassword,
      role: role,
    });

    await newUser.save();

    res.status(201).json({ message: 'Registration successful', user: newUser });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};


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



cd ../..

# Set a random port number between 1001 and 9999
port='' #/$((RANDOM % 9000 + 1001))

# Set a random 6-character string for the dbname
dbname=$(echo $RANDOM | tr '[0-9]' '[a-z]' | head -c 6)

# Prompt the user for the MongoDB connection information
clear
read -p "Enter the MongoDB host: " host
if [ -z "$host" ]; then
  host="localhost"
fi
clear
read -p "Enter the MongoDB port [$port]: " user_port
if [ -n "$user_port" ]; then
  port=":$user_port"
fi
clear
read -p "Enter the MongoDB username: " username
clear
read -p "Enter the MongoDB password: " password
clear
read -p "Enter the MongoDB database name [$dbname]: " user_dbname
if [ -n "$user_dbname" ]; then
  dbname="$user_dbname"
fi

# Ask the user if the `+srv` option is enabled
read -p "Is the +srv option enabled? (y/n) " srv
# Build the MongoDB URI based on the user input
if [ "$srv" = "y" ]; then
  uri="mongodb+srv://$username:$password@$host/$dbname"
else
  # Check if username and password are empty
  if [ -z "$username" ] || [ -z "$password" ]; then
    uri="mongodb://$host$port/$dbname"
  else
    uri="mongodb://$username:$password@$host:$port/$dbname"
  fi
fi

# Save the MongoDB URI as an environment variable in the server.env file
echo "LIVE_DATABASE_URL=$uri" >> server.env

echo "MongoDB URI saved to server.env as LIVE_DATABASE_URL"





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

# Write the values to the server.env file
echo "DB_HOST=$DB_HOST" >> server.env
echo "DB_PORT=$DB_PORT" >> server.env
echo "DB_USER=$DB_USER" >> server.env
echo "DB_PASSWORD=$DB_PASSWORD" >> server.env
echo "DB_NAME=$DB_NAME" >> server.env

# Confirm the values have been saved
echo "Saved DB credentials to server.env file:"
cat server.env
else
  echo "Invalid choice. Exiting."
  exit 1
fi

echo "import express from 'express';
import { loginUser, registerUser } from '../controllers/auth.js';

const authRouter = express.Router();

// Register a new user
authRouter.post('/register', registerUser);

// Login an existing user
authRouter.post('/login', loginUser);

export { authRouter };
" > src/server/routes/auth.js


echo "Installing dependencies..."

# Install dependencies
npm install express morgan helmet cors body-parser dotenv jsonwebtoken bcrypt react react-dom babel express-react-views
clear

echo "Installing dev dependencies..."

# Install dev dependencies
npm install -D nodemon @babel/core @babel/preset-react @babel/register
clear

echo "Setting Up React..."

# set up react
echo "creating Index.jsx file..."
echo "
import React from 'react';
import App from './App';

const Index = () => {
  return (
    <html>
      <head>
        <title>Hello, world!</title>
      </head>
      <body>
        <div id='root'>
          <App />
        </div>
        <script src='/bundle.js'></script>
      </body>
    </html>
  );
};

export default Index;
"> src/views/Index.jsx

echo "creating App.jsx file..."

echo "import React from 'react';

const App = () => {
  return (
    <div>
      <h1>Hello, world!</h1>
    </div>
  );
};

export default App;
"> src/views/App.jsx

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
import  path  from 'path';
import React from 'react';
import ReactDOMServer from 'react-dom/server';
import reactViews from 'express-react-views';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
//import App from './src/views/Index.jsx'

const __dirname = dirname(fileURLToPath(import.meta.url));


// Configuring environment variables
dotenv.config({path:'server.env'});



// Importing database connection file
import db from './src/server/database/connection.js'
db()

//import routers
import { authRouter } from './src/server/routes/auth.js'

// Initializing Express server
const server = express();

// Setting port
const port = process.env.PORT ?? 3000;


server.use('/static', express.static('public'));

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
server.use('/api/v1', authRouter)

//use react 

server.set('views',path.join(__dirname, 'src/views'));
server.set('view engine', 'jsx');
server.engine('jsx', reactViews.createEngine());



// Route for root directory
server.get('/', (req, res) => {
  //const html = ReactDOMServer.renderToString(App );
  res.render('index',{hello:'hello'});
});

// Starting the Express server
server.listen(port, () => console.log('Example server listening on port ', port));




"> server.js
clear

echo "Setting the 'dev' script and the type to 'module' in the package.json file..."

# Set the "dev" script in package.json and set the type to "module"
# jq is required for this operation and can be installed with brew by running "brew install jq" in the terminal
jq '.scripts.dev = "nodemon server.js" | .type = "module"' package.json > tmp.$$.json && mv tmp.$$.json package.json

clear
echo Creating a server.env file

# Create a server.env file
touch server.env

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

