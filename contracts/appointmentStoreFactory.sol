// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./libraries/shared/structs.sol";
import "./storeDeployer.sol";
import "./interfaces/IAppointmentStoreFactory.sol";
import "hardhat/console.sol";

contract AppointmentStoreFactory is IAppointmentStoreFactory, StoreDeployer {
    address[] public stores;
    mapping(address => address) public storeOwner;
    mapping(address => address[]) public ownerStores;
    address public admin;

    modifier onlyExistingCustomer(address store) {
        Store _store = Store(store);
        require(
            _store.isCustomerExist(msg.sender) == true,
            "only customer can query their own appointments"
        );
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function getStores(address owner)
        external
        view
        override
        returns (address[] memory)
    {
        return ownerStores[owner];
    }

    /// @inheritdoc IAppointmentStoreFactory
    function createStore(address owner, address token)
        external
        override
        returns (address store)
    {
        store = deployStore(
            address(this),
            owner,
            token,
            uint8(ownerStores[owner].length)
        );
        stores.push(store);
        storeOwner[store] = owner;
        ownerStores[owner].push(store);

        emit StoreCreated(store, owner, uint8(ownerStores[owner].length));
    }

    function createAppointment(
        SharedStructs.AppointmentInfo memory _appointmentInfo
    ) external override {
        Store _store = Store(_appointmentInfo.storeAddress);
        _store.createAppointment(msg.sender, _appointmentInfo);
    }

    function cancelAppointment(address store, uint256 datetime)
        external
        override
        onlyExistingCustomer(store)
    {
        Store _store = Store(store);
        _store.cancelAppointment(msg.sender, datetime);
    }

    // function getAppointments(address store)
    //     external
    //     view
    //     returns (
    //         uint256,
    //         address,
    //         string memory,
    //         bool,
    //         bool
    //     )
    // {
    //     Store _store = Store(store);

    //     require(
    //         _store.isCustomerExist(msg.sender) == true,
    //         "only customer can query their own appointments"
    //     );

    //     return _store.customerAppointments[msg.sender];
    // }
}
