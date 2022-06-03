// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IAppointmentDeployer {
    function apptParameters()
        external
        view
        returns (address controller, string memory storeName);
}
