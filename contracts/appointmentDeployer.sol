// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./interfaces/IAppointmentDeployer.sol";
import "./appointment.sol";

contract AppointmentDeployer is IAppointmentDeployer {
    struct ApptParameters {
        address appointmentController;
        string storeName;
    }

    ApptParameters public override apptParameters;

    function deployAppointment(
        address appointmentController,
        string memory storeName
    ) internal returns (address appointment) {
        apptParameters = ApptParameters({
            appointmentController: appointmentController,
            storeName: storeName
        });
        appointment = address(
            new Appointment{
                salt: keccak256(abi.encode(appointmentController, storeName))
            }()
        );
        delete apptParameters;
    }
}
