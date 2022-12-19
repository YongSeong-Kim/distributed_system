// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// 자식 컨트랙트를 위한 틀이며, 추상 함수로만 구성되어야 한다. 
// 해당 내용을 구현하지는 않고 이를 상속하는 쪽에서 구현하게 하되, 
// 다른 컨트랙트들에게 이 컨트랙트는 이런 함수들을 포함하니 안심하고 호출하라는 정보를 주는 역할을 한다
interface IRoomShare {
    struct Room {
        uint id;
        string name;
        string location;
        bool isActive;
        uint price;
        address owner;
        bool[] isRented;
    }

    struct Rent {
        uint id;
        uint rId;
        uint checkInDate;
        uint checkOutDate;
        address renter;
    }
    // emit과 관련있음.
    event NewRoom ( 
        uint256 indexed roomId
    );
    event NewRent (
        uint indexed roomId,
        uint256 indexed rentId
    );
    event Transfer(
      address sender, 
      address recipient, 
      uint amount
    );


    function getMyRents() external view returns(Rent[] memory); // msg.sender

    function getRoomRentHistory(uint _roomId) external view returns(Rent[] memory);

    
    function shareRoom( string calldata name, string calldata location, uint price ) external;

    function rentRoom(uint _roomId, uint checkInDate, uint checkOutDate) payable external;
        function _createRent(uint256 _roomId, uint256 checkInDate, uint256 checkoutDate) external ; // internal
        function _sendFunds (address owner, uint256 value) external ; // internal


    function recommendDate(uint _roomId, uint checkInDate, uint checkOutDate) external view returns(uint[2] memory);
    

    // optional 1
    // caution: 방의 소유자를 먼저 체크해야한다.
    // isActive 필드만 변경한다.
    function markRoomAsInactive(uint256 _roomId) external;

    // optional 2
    // caution: 변수의 저장공간에 유의한다.
    // 첫날부터 시작해 함수를 실행한 날짜까지 isRented 필드의 초기화를 진행한다.
    function initializeRoomShare(uint _roomId, uint day) external;
}