// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    // State variables
    address public owner;
    string public ownerName;
    mapping(address => bool) public hasVoted;
    mapping(string => uint) public votes;
    mapping(address => string) public voterToCandidate;
    string[] public candidates;

    // Modifier to restrict functions to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    // Constructor to set the owner, owner's name, and candidates
    constructor(string memory _ownerName, string[] memory candidateNames) {
        owner = msg.sender;
        ownerName = _ownerName;
        candidates = candidateNames;
    }

    // Function to add a candidate (only owner)
    function addCandidate(string memory candidateName) public onlyOwner {
        candidates.push(candidateName);
    }

    // Function to vote for a candidate
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

    // Function to get the total votes for a candidate
    function getVotes(string memory candidateName) public view returns (uint) {
        return votes[candidateName];
    }

    // Function to get the candidate a voter voted for
    function getVoterCandidate(address voter) public view returns (string memory) {
        require(hasVoted[voter], "Voter has not voted");
        return voterToCandidate[voter];
    }

    // Function to get the total votes for multiple candidates
    function getVotesForCandidates(string[] memory candidateNames) public view returns (uint[] memory) {
        uint[] memory votesArray = new uint[](candidateNames.length);
        
        for (uint i = 0; i < candidateNames.length; i++) {
            votesArray[i] = votes[candidateNames[i]];
        }
        
        return votesArray;
    }

    // Function to assert all candidates have at least one vote
    function assertAllCandidatesHaveVotes() public view {
        for (uint i = 0; i < candidates.length; i++) {
            assert(votes[candidates[i]] > 0);
        }
    }

    // Function to revoke a vote (only owner)
    function revokeVote(address voter, string memory candidateName) public onlyOwner {
        require(hasVoted[voter], "Voter has not voted");
        require(keccak256(abi.encodePacked(voterToCandidate[voter])) == keccak256(abi.encodePacked(candidateName)), "Voter did not vote for this candidate");
        require(votes[candidateName] > 0, "No votes to revoke");
        
        hasVoted[voter] = false;
        votes[candidateName]--;
        delete voterToCandidate[voter];
    }

    // Function to reset the voting system (only owner)
    function resetVoting() public onlyOwner {
        for (uint i = 0; i < candidates.length; i++) {
            votes[candidates[i]] = 0;
        }

        for (uint i = 0; i < candidates.length; i++) {
            if (votes[candidates[i]] != 0) {
                revert("Votes were not reset properly");
            }
        }

        // Reset the hasVoted mapping
        for (uint i = 0; i < candidates.length; i++) {
            // In a real contract, you would need to track all voters to reset their status
            // This is just for testing purposes
            hasVoted[address(uint160(i))] = false;
            delete voterToCandidate[address(uint160(i))];
        }
    }

    // Function to reset the voting status of a specific address (only owner)
    function resetVoter(address voter) public onlyOwner {
        hasVoted[voter] = false;
        delete voterToCandidate[voter];
    }
}
