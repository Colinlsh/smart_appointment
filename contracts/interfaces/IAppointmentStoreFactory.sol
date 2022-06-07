// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

import "../libraries/shared/structs.sol";

interface IAppointmentStoreFactory {
    event StoreCreated(address store, address owner, uint8 storeIndex);
    event AppointmentCreated(
        address store,
        address customer,
        uint256 datetime,
        string occasion
    );
    event AppointmentCancelled(
        address store,
        address customer,
        uint256 datetime,
        string occasion
    );

    function createStore(address owner, address token)
        external
        returns (address store);

    function getStores(address owner)
        external
        view
        returns (address[] memory stores);

    function createAppointment(
        SharedStructs.AppointmentInfo memory _appointmentInfo
    ) external;

    function cancelAppointment(address store, uint256 datetime) external;
}
