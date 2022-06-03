// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "./libraries/sharedStructs.sol";
import "./interfaces/IStoreDeployer.sol";

contract Store {
    address public owner;
    address public admin;
    SharedStructs.StoreLocation public storeLocation;
    uint256 public startTime;
    uint256 public endTime;
    address public controller;

    event ChangeStartTime(uint256);
    event ChangeEndTime(uint256);
    event ChangeStoreLocation(SharedStructs.StoreLocation);
    event TransferOwnership(address);

    modifier onlyStoreOwner() {
        require(msg.sender == owner, "only owner can change store information");
        _;
    }

    modifier onlyApptController() {
        require(
            msg.sender == controller,
            "only controller can initialise store"
        );
        _;
    }

    constructor() {
        (address _controller, address _owner) = IStoreDeployer(msg.sender)
            .storeParameters();
        admin = _controller;
        controller = _controller;
        owner = _owner;
    }

    // function initialise(SharedStructs.StoreInfo memory _storeInfo, address _owner) public onlyApptController returns (bool) {
    //     owner = _owner;

    //     startTime = _storeInfo.startTime;
    //     endTime = _storeInfo.endTime;
    //     storeLocation = _storeInfo.storeLocation;

    //     return true;
    // }

    function setStartTime(uint256 _datetime) public onlyStoreOwner {
        startTime = _datetime;
        emit ChangeStartTime(startTime);
    }

    function setEndTime(uint256 _datetime) public onlyStoreOwner {
        endTime = _datetime;
        emit ChangeEndTime(endTime);
    }

    function setStoreLocation(SharedStructs.StoreLocation memory _location)
        public
        onlyStoreOwner
    {
        storeLocation = _location;
        emit ChangeStoreLocation(storeLocation);
    }

    function transferAdminship(address _newAdmin) public onlyStoreOwner {
        owner = _newAdmin;
        emit TransferOwnership(owner);
    }
}
