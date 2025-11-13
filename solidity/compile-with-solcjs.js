#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const solc = require('solc');

// Directories
const contractsDir = path.join(__dirname, 'contracts');
const artifactsDir = path.join(__dirname, 'artifacts', 'contracts');

// Create artifacts directory
if (!fs.existsSync(artifactsDir)) {
  fs.mkdirSync(artifactsDir, { recursive: true });
}

// Function to find all imports
function findImports(importPath) {
  try {
    // Check if it's an OpenZeppelin import
    if (importPath.startsWith('@openzeppelin/')) {
      const ozPath = path.join(__dirname, 'node_modules', importPath);
      if (fs.existsSync(ozPath)) {
        return { contents: fs.readFileSync(ozPath, 'utf8') };
      }
    }

    // Check local imports
    const localPath = path.join(contractsDir, importPath);
    if (fs.existsSync(localPath)) {
      return { contents: fs.readFileSync(localPath, 'utf8') };
    }

    return { error: 'File not found: ' + importPath };
  } catch (error) {
    return { error: error.message };
  }
}

// Get all Solidity files
const files = fs.readdirSync(contractsDir)
  .filter(file => file.endsWith('.sol'));

console.log(`Found ${files.length} Solidity files to compile`);

// Prepare input for compiler
const sources = {};
files.forEach(file => {
  const filePath = path.join(contractsDir, file);
  sources[file] = {
    content: fs.readFileSync(filePath, 'utf8')
  };
});

// Compiler input
const input = {
  language: 'Solidity',
  sources: sources,
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    },
    viaIR: true,
    outputSelection: {
      '*': {
        '*': ['abi', 'evm.bytecode', 'evm.deployedBytecode']
      }
    }
  }
};

console.log('Compiling contracts...');

// Compile
const output = JSON.parse(
  solc.compile(JSON.stringify(input), { import: findImports })
);

// Check for errors
if (output.errors) {
  const hasErrors = output.errors.some(error => error.severity === 'error');

  output.errors.forEach(error => {
    if (error.severity === 'error') {
      console.error(`ERROR: ${error.formattedMessage}`);
    } else {
      console.warn(`WARNING: ${error.formattedMessage}`);
    }
  });

  if (hasErrors) {
    process.exit(1);
  }
}

// Save compiled contracts
console.log('Writing artifacts...');
let compiledCount = 0;

for (const sourceFile in output.contracts) {
  for (const contractName in output.contracts[sourceFile]) {
    const contract = output.contracts[sourceFile][contractName];

    // Create contract directory
    const contractDir = path.join(artifactsDir, sourceFile);
    if (!fs.existsSync(contractDir)) {
      fs.mkdirSync(contractDir, { recursive: true });
    }

    // Prepare artifact
    const artifact = {
      _format: 'hh-sol-artifact-1',
      contractName: contractName,
      sourceName: `contracts/${sourceFile}`,
      abi: contract.abi,
      bytecode: contract.evm.bytecode.object,
      deployedBytecode: contract.evm.deployedBytecode.object,
      linkReferences: contract.evm.bytecode.linkReferences || {},
      deployedLinkReferences: contract.evm.deployedBytecode.linkReferences || {}
    };

    // Write artifact file
    const artifactPath = path.join(contractDir, `${contractName}.json`);
    fs.writeFileSync(artifactPath, JSON.stringify(artifact, null, 2));

    compiledCount++;
    console.log(`✓ Compiled ${contractName}`);
  }
}

console.log(`\nSuccessfully compiled ${compiledCount} contracts`);
console.log(`Artifacts written to: ${artifactsDir}`);
