# Voting System Smart Contract

This repository contains a smart contract for a decentralized voting system implemented in Solidity. The contract allows users to vote for candidates, revoke their votes, and manage the voting process securely on the blockchain.

## Features

* Voting: Users can cast their votes for a candidate of their choice.
* Revoking Votes: Contract owner can revoke votes if necessary.
* Candidate Management: Owner can add candidates dynamically.
* Auditability: Transparent and auditable voting process on the blockchain.
* Security: Built-in protections to prevent double voting and ensure integrity.

## Contract Details

The main contract **VotingSystem.sol** includes the following functionalities:

* Constructor: Initializes the contract with the owner's name and initial candidate list.
* Vote: Allows users to vote for a candidate.
* RevokeVote: Allows the contract owner to revoke a vote cast by a user.
* Getters: Functions to retrieve vote counts, check who a user voted for, and ensure all candidates have votes.
* Reset: Functions to reset the voting system (for testing purposes).

## Getting Started

### Prerequisites

* Use Remix IDE or another Solidity development environment for contract deployment and testing.

### Deployment

* Deploy the contract **VotingSystem.sol** on your preferred Ethereum network or locally using Remix or Truffle.
* Provide initial parameters such as owner's name and candidate list during deployment.

## Interacting with the Contract

* Use Ethereum accounts to interact with the deployed contract:
 *   Vote for candidates using the ```vote``` function.
 *   Revoke votes using the ```revokeVote``` function (owner-only).
 *   Retrieve voting results and voter information using getter functions.

### Example Usage

```
// Example of voting for a candidate
VotingSystem.vote("CandidateName");

// Example of revoking a vote (owner-only)
VotingSystem.revokeVote(address, "CandidateName");

// Example of getting votes for a candidate
uint votes = VotingSystem.getVotes("CandidateName");
```
## Smart Contract Explanation

### State Variables

* ```owner```: Stores the address of the contract owner who deploys the contract and manages voting operations.
* ```ownerName```: Stores the name of the contract owner for identification purposes.
* ```candidates```: An array that stores the names of all candidates participating in the election.
* ```hasVoted```: A mapping that tracks whether a specific address has already voted.
* ```votes```: A mapping that keeps count of the votes received by each candidate.
* ```voterToCandidate```: A mapping that associates each voter's address with the candidate they voted for.

```
address public owner;
string public ownerName;
string[] public candidates;
mapping(address => bool) public hasVoted;
mapping(string => uint) public votes;
mapping(address => string) public voterToCandidate;
```
### Constructor 

The constructor initializes the contract with the owner's name and initializes the candidate list with an initial set of candidates.

```
constructor(string memory _ownerName, string[] memory candidateNames) {
    owner = msg.sender;
    ownerName = _ownerName;
    candidates = candidateNames;
}
```
### Voting Function

The ```vote``` function allows any Ethereum address to vote for a candidate. It checks if the voter has already voted and verifies that the candidate exists in the ```candidates``` array.

```
function vote(string memory candidateName) public {
    require(!hasVoted[msg.sender], "Already voted");
    bool validCandidate = false;
    
    for (uint i = 0; i < candidates.length; i++) {
        if (keccak256(abi.encodePacked(candidates[i])) == keccak256(abi.encodePacked(candidateName))) {
            validCandidate = true;
            break;
        }
    }

    require(validCandidate, "Candidate does not exist");
    hasVoted[msg.sender] = true;
    votes[candidateName]++;
    voterToCandidate[msg.sender] = candidateName;
}
```
## Revoking a Vote

The ```revokeVote``` function allows the contract owner to revoke a vote that was previously cast by a voter. It checks if the owner is calling the function and ensures that the voter indeed voted for the specified candidate.

```
function revokeVote(address voter, string memory candidateName) public onlyOwner {
    require(hasVoted[voter], "Voter has not voted");
    require(keccak256(abi.encodePacked(voterToCandidate[voter])) == keccak256(abi.encodePacked(candidateName)), "Voter did not vote for this candidate");
    require(votes[candidateName] > 0, "No votes to revoke");
    
    hasVoted[voter] = false;
    votes[candidateName]--;
    delete voterToCandidate[voter];
}
```
## Additional Functionality

* **Getters**: Various getter functions (```getVotes```, ```getVoterCandidate```, etc.) are provided to retrieve voting-related information, such as total votes for a candidate and which candidate a voter voted for.
* **Reset Functions**: Functions (```resetVoting```, ```resetVoter```) are available to reset the voting system for testing purposes, clearing all votes and voter records.

