/// Rideshare Decentralize application by Renat Norderhaug 9/03/19
pragma solidity ^0.5.8;

import './zeppelin/lifecycle/Killable.sol';

contract Rideshare is Killable {
  struct Passenger {
    uint price;
    string state; // initial, driverConfirmed, passengerConfirmed, enRoute, completion, canceled
  }

  struct Ride {
    address payable driver;
    uint drivingCost;
    uint capacity;
    string originAddress;
    string destAddress;
    uint createdAt;
    uint confirmedAt;
    uint departAt;
    mapping (address => Passenger) passengers;
    address payable[] passengerAccts;
  }
  /// array holding the rides that are kept track of in the application
  Ride[] public rides;
  /// # of rides
  uint public rideCount = 4;

  mapping (address => uint) reputation;
  
  
  /// only drivers can create Rides
  /// algorithm: createRide
  /// Result: an Ride object is made 
  /// initialize Ride[] public rides;
  /// while (rides =) do
  /// push 
  
  function createRide(uint _driverCost, uint _capacity, string memory _originAddress, string memory _destAddress, uint _confirmedAt, uint _departAt) public payable {
    address payable[] memory _passengerAccts;
    rides.push(Ride(msg.sender, _driverCost, _capacity, _originAddress, _destAddress, block.timestamp, _confirmedAt, _departAt, _passengerAccts));
  }
  
  // called by passenger
  function joinRide(uint rideNumber) public payable {
    Ride storage curRide = rides[rideNumber];
    require(msg.value == curRide.drivingCost);
    // curRide is a Ride storage variable
    Passenger storage passenger = curRide.passengers[msg.sender];    
    
    passenger.price = msg.value;
    passenger.state = "initial";
    /// make - 1
    rides[rideNumber].passengerAccts.push(msg.sender); //***
  }
  /// function to return the passenger accounts
  function getPassengers(uint rideNumber) public view returns(address payable[] memory ) {
    return rides[rideNumber].passengerAccts;
  }

  function getPassengerRideState(uint rideNumber, address passenger) view public returns(string memory) {
    return rides[rideNumber].passengers[passenger].state;
  }

  function getRide(uint rideNumber) public view returns (
    address payable _driver,
    uint _drivingCost,
    uint _capacity,
    string memory _originAddress,
    string memory _destAddress,
    uint _createdAt,
    uint _confirmedAt,
    uint _departAt
  ) {
    Ride storage ride = rides[rideNumber];
    return (
      ride.driver,
      ride.drivingCost,
      ride.capacity,
      ride.originAddress,
      ride.destAddress,
      ride.createdAt,
      ride.confirmedAt,
      ride.departAt
    );
  }

  function getRideCount() public view returns(uint) {
    return rides.length;
  }
  
  function passengerInRide(uint rideNumber, address passengerAcct) public view returns (bool) {
    Ride storage curRide = rides[rideNumber];
    for(uint i = 0; i < curRide.passengerAccts.length; i++) {
      if (curRide.passengerAccts[i] == passengerAcct) {
        return true;
      }
    }
    return false;
  }
  
  function cancelRide(uint rideNumber) public payable {
    Ride storage curRide = rides[rideNumber];
    require(block.timestamp < curRide.confirmedAt);
    if (msg.sender == curRide.driver) {
      for (uint i = 0; i < curRide.passengerAccts.length; i++) {
        curRide.passengerAccts[i].transfer(curRide.passengers[curRide.passengerAccts[i]].price);
      }
    } else if (passengerInRide(rideNumber, msg.sender)) {
      msg.sender.transfer(curRide.passengers[msg.sender].price);
    }
  }
  
  // called by passenger
  function confirmDriverMet(uint rideNumber) public payable {
    require(passengerInRide(rideNumber, msg.sender));
    Ride storage curRide = rides[rideNumber];
    if (keccak256(bytes(curRide.passengers[msg.sender].state)) == keccak256("passengersConfirmed")) {
      curRide.passengers[msg.sender].state = "enRoute";
    } else {
      curRide.passengers[msg.sender].state = "driverConfirmed";
    }
  }
  
  // called by driver
  function confirmPassengersMet(uint rideNumber, address[] memory passengerAddresses) public payable {
    Ride storage curRide = rides[rideNumber];
    require(msg.sender == curRide.driver);
    for(uint i=0; i < passengerAddresses.length; i++) {
      //string memory curState = curRide.passengers[passengerAddresses[i]].state;
      if (keccak256(bytes(curRide.passengers[passengerAddresses[i]].state)) == keccak256("driverConfirmed")) {
        curRide.passengers[passengerAddresses[i]].state = "enRoute";
      } else {
        curRide.passengers[passengerAddresses[i]].state = "passengersConfirmed";
      }
    }
    // require(rides[rideNumber].state == "confirmed");
  }
  
  function enRouteList(uint rideNumber) public view returns(address[] memory) {
    Ride storage curRide = rides[rideNumber];
    uint256 count = 0;
    /// should use a memory array b.ut it cant be dynamically sized
    for(uint i = 0; i < curRide.passengerAccts.length; i++) {
      if (keccak256(bytes(curRide.passengers[curRide.passengerAccts[i]].state)) == keccak256("enRoute")) {
        count += 1;
      }
    }
    address[] memory addressesEnRoute = new address[](count);
    uint256 index = 0;
    for(uint256 i = 0; i <curRide.passengerAccts.length; i++) {
      if(keccak256(bytes(curRide.passengers[curRide.passengerAccts[i]].state)) == keccak256("enRoute")) {
        addressesEnRoute[index] = curRide.passengerAccts[i];
        index +=1;
      }
    }
  }
  
  // called by passenger to the blockchain 
  function arrived(uint rideNumber) public payable{
    require(passengerInRide(rideNumber, msg.sender));
    Ride storage curRide = rides[rideNumber];
    curRide.driver.transfer(curRide.passengers[msg.sender].price);
    curRide.passengers[msg.sender].state = "completion";
  }
}