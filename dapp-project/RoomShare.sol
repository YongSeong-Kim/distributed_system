// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./IRoomShare.sol";

contract RoomShare is IRoomShare{


  uint public roomId = 0; // 현재 등록된 룸 아이디.
  uint public rentId = 0; // 현재 얼마나 많은 rent가 들어왔는지
  Room[] public rooms; // 등록한 방들이 있음.
  Rent[] public rents;
  mapping (uint => Room) public roomId2room; // ro
  mapping (address => Rent[]) public renter2rent;
  mapping (uint => Rent[]) public roomId2rent;


  function getRooms() external view returns(Room[] memory){
    return rooms;
  }

  function getMyRents() external override view returns(Rent[] memory) {
    /* 함수를 호출한 유저의 대여 목록을 가져온다. */
    Rent[] memory rent = renter2rent[msg.sender];
    return rent;

  }

  function getRoomRentHistory(uint _roomId) external override view returns(Rent[] memory) {
    /* 특정 방의 대여 히스토리를 보여준다. */
    Rent[] memory rent = roomId2rent[_roomId];
    return rent;
  }

  function shareRoom( string calldata name, 
                      string calldata location, 
                      uint price ) external {
    /**
     * 1. isActive 초기값은 true로 활성화, 함수를 호출한 유저가 방의 소유자이며, 365 크기의 boolean 배열을 생성하여 방 객체를 만든다.
     * 2. 방의 id와 방 객체를 매핑한다.
     */
    bool[] memory availability = new bool[](365);
    rooms.push(Room(roomId, name, location, true, price, msg.sender, availability));
    roomId2room[roomId] = rooms[rooms.length-1];
    emit NewRoom(roomId++);
  }

  function rentRoom(uint _roomId, uint checkInDate, uint checkOutDate) payable external override{
    
    
    Room memory room = roomId2room[_roomId];
    require(room.isActive, "Room is not Active");

    for (uint i = checkInDate; i < checkOutDate; i++) {
      require(!room.isRented[i], "Room is already reserverd");
    }

    require(room.price * (checkOutDate - checkInDate) == msg.value, "The error occur in price");
    Rent memory rent = Rent(rentId, _roomId, checkInDate, checkOutDate, msg.sender);
    rents.push(rent);
    roomId2rent[_roomId].push(rent);
    renter2rent[msg.sender].push(rent);
    this._createRent(_roomId, checkInDate, checkOutDate);

    /**
     * 1. roomId에 해당하는 방을 조회하여 아래와 같은 조건을 만족하는지 체크한다.
     *    a. 현재 활성화(isActive) 되어 있는지
     *    b. 체크인날짜와 체크아웃날짜 사이에 예약된 날이 있는지 
     *    c. 함수를 호출한 유저가 보낸 이더리움 값이 대여한 날에 맞게 지불되었는지(단위는 1 Finney, 10^15 Wei) 
     * 2. 방의 소유자에게 값을 지불하고 (msg.value 사용) createRent를 호출한다.
     * *** 체크아웃 날짜에는 퇴실하여야하며, 해당일까지 숙박을 이용하려면 체크아웃날짜는 그 다음날로 변경하여야한다. ***
     */
  }

  function _createRent(uint256 _roomId, uint256 checkInDate, uint256 checkoutDate) external override {
    /**
     * 1. 함수를 호출한 사용자 계정으로 대여 객체를 만들고, 변수 저장 공간에 유의하며 체크인날짜부터 체크아웃날짜에 해당하는 배열 인덱스를 체크한다(초기값은 false이다.).
     * 2. 계정과 대여 객체들을 매핑한다. (대여 목록)
     * 3. 방 id와 대여 객체들을 매핑한다. (대여 히스토리)
     */
    Room storage room = roomId2room[_roomId];
    for(uint256 i = checkInDate; i < checkoutDate; i++)
    {
      room.isRented[i] = true;
    }
    emit NewRent(_roomId, rentId++);
  }

  function _sendFunds (address owner, uint256 value) external {
      payable(owner).transfer(value);
  }
  
  function recommendDate(uint _roomId, uint checkInDate, uint checkOutDate) external view returns(uint[2] memory) {
    /**
     * 대여가 이미 진행되어 해당 날짜에 대여가 불가능 할 경우, 
     * 기존에 예약된 날짜가 언제부터 언제까지인지 반환한다.
     * checkInDate(체크인하려는 날짜) <= 대여된 체크인 날짜 , 대여된 체크아웃 날짜 < checkOutDate(체크아웃하려는 날짜)
     */
    uint i = 0;
    uint checkIn = 0;
    uint checkOut = 0;
    uint[] memory recommend = new uint[](2);
    Room memory room = roomId2room[_roomId];
    for (i = checkInDate; i < checkOutDate; i++) {
      if (room.isRented[i] == true)
      {
        recommend[0] = i;
        break;
      }
    }
    for (i = checkOutDate; i >= checkInDate; i--) {
      if (room.isRented[i] == true)
      {
        recommend[1] = i;
        break;
      }
    }
    return [recommend[0], recommend[1]];
  }

  // ...

      // optional 1
    // caution: 방의 소유자를 먼저 체크해야한다.
    // isActive 필드만 변경한다.
    function markRoomAsInactive(uint256 _roomId) external override
    {

    }

    // optional 2
    // caution: 변수의 저장공간에 유의한다.
    // 첫날부터 시작해 함수를 실행한 날짜까지 isRented 필드의 초기화를 진행한다.
    function initializeRoomShare(uint _roomId, uint day) external override
    {


    }

}