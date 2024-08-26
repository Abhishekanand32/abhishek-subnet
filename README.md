# Creating EVM subnet with Ava Labs

- Created my own (custom) Subnet using the Avalanche-Cli.

## Steps to Follow

- avalanche subnet create ayush (chain ID : 10322) (Token Symbol : AYU)
- avalanche subnet deploy ayush
- Importing the account & Copying the private key in the metamask.
- Adding the network through RPC URL and chain ID
- Interacting with the game using the REMIX IDE

![App Screenshot](https://res.cloudinary.com/dsprifizw/image/upload/v1724682419/Screenshot_2024-08-26_195240_ocap23.png)

![App Screenshot](https://res.cloudinary.com/dsprifizw/image/upload/v1724682418/Screenshot_2024-08-26_195435_df12dz.png)

## Objective

Explore custom subnet and craete one using avalanche cli and deploy contracts on that and interact.

## Code by Code Explanation.

```Solidity

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

```
The number of whichever player is greater wins and gain twice amount and in case of tie , no one will be winner.

## Complete Code

### ERC20 contact

```Solidity
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";

error ERC20InvalidSender(address _nullAddress);
error ERC20InvalidReceiver(address _nullAddress);
error ERC20InsufficientBalance(address,address,uint);
error ERC20InsufficientBalances(address,uint,uint);
error ERC20InsufficientAllowance(address,uint,uint);


contract ERC20 is  IERC20 {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function mintTokens(address owner,uint _amount) external{
        _mint(owner, _amount);
    }

    function burnTokens(address account, uint256 value) external {
        _burn(account , value);
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }


    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }
    function transferFunc(address sender, address recepient, uint _amount) external{
        _transfer(sender, recepient, _amount);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalances(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal   {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
```

### Vault contact

```Solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "./ERC20.sol";

contract Vault {
    ERC20 token;
    uint public shares;
    address public _owner;

    uint public totalSupply;
    uint public totalShares;
    mapping(address => uint) public balanceOf;

    constructor() {
        token = new ERC20("Abhishek","ABH");
        // _owner = msg.sender;
        // _tokenaddress = _token;
        totalSupply = token.totalSupply();
    }

   function transferFunc(address owner,address _recepient,uint _amount) internal{
    token.transferFunc(owner,_recepient,_amount);
   }

    function _mint(address _to, uint _shares) internal {
        totalShares += _shares;
        balanceOf[_to] += _shares;
    }

    function _burn(address _from, uint _shares) internal {
        totalShares -= _shares;
        balanceOf[_from] -= _shares;
    }

    // function deposit(uint _amount) external {
    //     /*
    //     a = amount
    //     B = balance of token before deposit
    //     T = total supply
    //     s = shares to mint

    //     (T + s) / T = (a + B) / B 

    //     s = aT / B
    //     */
    //     uint shares;
    //     if (totalSupply == 0) {
    //         shares = _amount;
    //     } else {
    //         shares = (_amount  * totalSupply) / token.balanceOf(msg.sender);
    //     }

    //     require(shares >0,"Shares is 0");

    //     _mint(msg.sender, shares);
    //    bool res =  token.transferFrom(msg.sender, address(this), _amount);
    //    require(res,"faild");
    // }



  
   function deposit(uint _amount) external {
        require(_amount > 0, "Amount must be greater than 0");

        uint256 tokenBalance = token.balanceOf(msg.sender);

        if (totalSupply == 0) {
            shares = _amount;
        } else {
            require(tokenBalance > 0, "Token balance must be greater than 0");
            shares = (_amount* totalSupply)/ tokenBalance;
        }

       _mint(msg.sender,shares);
       transferFunc(msg.sender,address(this),_amount);
    }

    function balance() external view returns(uint){
        return token.balanceOf(msg.sender);
    }

    function withdraw(uint _shares) external {
        /*
        a = amount
        B = balance of token before withdraw
        T = total supply
        s = shares to burn

        (T - s) / T = (B - a) / B 

        a = sB / T
        */
        // uint amount = (_shares * token.balanceOf(msg.sender)) / totalSupply;
        _burn(msg.sender, _shares);
        transferFunc(address(this), msg.sender, shares);
    }

    function getTotalSupply() external{
          totalSupply = token.totalSupply();
    }

  
}
```

### Game contact

```Solidity
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

```

## License

This project is licensed under the MIT License - see the LICENSE.md file for details
