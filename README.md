# Project Initializer
A shell script that initializes a new project and sets up a Node.js environment with either MongoDB or PostgreSQL as the database.

## Usage
1. Clone the repository or download the script file.
2. In the terminal, navigate to the directory where the script file is located.
3. Make the script file executable by running `chmod +x project-initializer.sh`.
4. Run the script file by executing `./project-initializer.sh`.
5. The script will prompt you to enter the name of the project and choose a database (either MongoDB or PostgreSQL).
6. The script will create a new directory for the project and set up the Node.js environment with the chosen database.
7. The script will install necessary dependencies and set up a `server.js` file that starts an Express server on port 3000 (or the port specified in the `process.env.PORT` environment variable).

## Requirements
- Node.js and npm must be installed on the system.
- jq must be installed for the script to correctly set the "dev" script and type in the `package.json` file. jq can be installed with `brew install jq` in the terminal.

## Notes
- The MongoDB setup requires a valid connection URI. The script provides a sample URI that needs to be replaced with your own.
- The PostgreSQL setup requires the following environment variables to be set: `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, and `DB_NAME`.
