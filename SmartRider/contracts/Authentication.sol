pragma solidity ^0.5.8;

import './zeppelin/lifecycle/Killable.sol';

contract Authentication is Killable {
  struct User {
    bytes32 name;
  }

  mapping (address => User) public users;

  uint private id; // Stores user id temporarily

  modifier onlyExistingUser {
    // Check if user exists or terminate

    require(!(users[msg.sender].name == 0x0));
    _;
  }

  modifier onlyValidName(bytes32 name) {
    // Only valid names allowed

    require(!(name == 0x0));
    _;
  }

  function login() view
  public
  onlyExistingUser
  returns (bytes32) {
    return (users[msg.sender].name);
  }
  /// algorithm: Registration
  /// Result: successful registration
  /// intiialize user object { identity; name;  }
  /// if name != 0x0 and identity != 0x0 do
  /// call authenticate()
  /// if authenticate returns true
  /// assign nameri = name
  /// assign idri = an unique id generated from the smart contract
  /// assign Ari = location of rider
  /// returns PKri and SKri and IDri 
  
  

  function signup(bytes32 name)
  public
  payable
  onlyValidName(name)
  returns (bytes32) {
    // Check if user exists.
    // If yes, return user name.
    // If no, check if name was sent.
    // If yes, create and return user.

    if (users[msg.sender].name == 0x0)
    {
        users[msg.sender].name = name;

        return (users[msg.sender].name);
    }

    return (users[msg.sender].name);
  }

  function update(bytes32 name)
  public
  payable
  onlyValidName(name)
  onlyExistingUser
  returns (bytes32) {
    // Update user name.

    if (users[msg.sender].name != 0x0)
    {
        users[msg.sender].name = name;

        return (users[msg.sender].name);
    }
  }
}
