// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;
import "./ERC20.sol";

contract DuelGame {
    uint public duelCount;
    event DuelInitiated(uint indexed duelId, address indexed challenger, address indexed opponent, uint stakeAmount);
    event DuelResolved(uint indexed duelId, address indexed victor, uint prize);

    ERC20 tokenContract;

    struct DuelDetails {
        address challenger;
        address opponent;
        uint stakeAmount;
        bool duelEnded;
        address victor;
        uint challengerRoll;
        uint opponentRoll;
    }

    mapping(uint => DuelDetails) public duels;

    constructor() {
        tokenContract = new ERC20("AyushToken", "AYU");
    }

    function mintTokens(uint _quantity) external {
        tokenContract.mintTokens(msg.sender, _quantity);
    }

    function getBalance() external view returns (uint) {
        return tokenContract.balanceOf(msg.sender);
    }

    // Initiates a new duel between two players
    function initiateDuel(address _opponent, uint _stakeAmount) external {
        require(tokenContract.balanceOf(msg.sender) >= _stakeAmount, "Not enough tokens to stake");
        require(tokenContract.balanceOf(_opponent) >= _stakeAmount, "Opponent lacks sufficient tokens");

        duelCount++;
        DuelDetails storage newDuel = duels[duelCount];

        newDuel.challenger = msg.sender;
        newDuel.opponent = _opponent;
        newDuel.stakeAmount = _stakeAmount;

        tokenContract.burnTokens(msg.sender, _stakeAmount);
        tokenContract.burnTokens(_opponent, _stakeAmount);

        emit DuelInitiated(duelCount, msg.sender, _opponent, _stakeAmount);
    }

    // Resolves the duel with dice rolls logic for both players
    function resolveDuel(uint _duelId) external {
        DuelDetails storage duel = duels[_duelId];
        require(!duel.duelEnded, "Duel already resolved");

        // Both players roll a number between 1 and 100
        duel.challengerRoll = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, duel.challenger))) % 100 + 1;
        duel.opponentRoll = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, duel.opponent))) % 100 + 1;

        if (duel.challengerRoll > duel.opponentRoll) {
            duel.victor = duel.challenger;
        } else if (duel.opponentRoll > duel.challengerRoll) {
            duel.victor = duel.opponent;
        } else {
            duel.victor = address(0); // No winner in the case of a tie
        }

        // if (duel.victor != address(0)) {
        //     uint totalPrize = duel.stakeAmount * 2; // Winner claims all staked tokens
        //     tokenContract.mintTokens(duel.victor, totalPrize);
        // }

        duel.duelEnded = true;

        emit DuelResolved(_duelId, duel.victor, duel.stakeAmount * 2);
    }
}
