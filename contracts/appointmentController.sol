// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./appointment.sol";
import "./store.sol";
import "./libraries/sharedStructs.sol";
import "./storeDeployer.sol";
import "./appointmentDeployer.sol";

contract AppointmentController is StoreDeployer, AppointmentDeployer {
    address[] public appointments;
    address[] public stores;
    mapping(address => address) public storeAppointment;
    mapping(address => address) public storeOwner;
    address public admin;

    event StoreSetup(address, address);

    constructor() {
        admin = msg.sender;
    }

    function setupStore(address _owner) public returns (address store) {
        store = deployStore(address(this), _owner);
        stores.push(store);
        storeOwner[store] = _owner;

        emit StoreSetup(store, _owner);
    }

    function createAppointment(
        address _store,
        SharedStructs.AppointmentInfo memory _appointmentInfo
    ) public returns (bool) {
        return true;
    }
}
