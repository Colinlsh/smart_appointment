// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./libraries/sharedStructs.sol";
import "./interfaces/IAppointmentDeployer.sol";

error AppointmentTooClose(
    uint256 datetime,
    string location,
    string occasion,
    bool attended
);

contract Appointment {
    event CreateAppointment(SharedStructs.AppointmentInfo);
    event CancelAppointment(SharedStructs.AppointmentInfo);

    SharedStructs.Customer[] public customers;
    mapping(address => mapping(uint256 => SharedStructs.AppointmentInfo))
        public customersTimeAppointment;
    address public store;
    address public controller;
    string public storeName;
    uint256 public constant TIMEDELAY = 3600;

    modifier onlyController() {
        require(
            msg.sender == controller,
            "Only controller is allowed to execute this method"
        );
        _;
    }

    constructor() {
        (address _controller, string memory _storeName) = IAppointmentDeployer(
            msg.sender
        ).apptParameters();
        storeName = _storeName;
        controller = _controller;
    }

    function initialise(address _store, string memory _storeName)
        public
        onlyController
        returns (bool)
    {
        store = _store;
        storeName = _storeName;
        return true;
    }

    function cancelAppointment(
        address _customer,
        SharedStructs.AppointmentInfo memory _appointmentInfo
    ) public onlyController {
        if (!isCustomerExist(_customer)) {
            revert("customer does not exist");
        }

        customersTimeAppointment[_customer][_appointmentInfo.datetime]
            .cancelled = true;
        emit CancelAppointment(_appointmentInfo);
    }

    function createAppointment(
        SharedStructs.Customer memory _customer,
        SharedStructs.AppointmentInfo memory _appointmentInfo
    ) public onlyController {
        // check if customer has booked any appointment within an hour from intended time.
        require(
            isAppointmentCollision(_customer.customer, _appointmentInfo) ==
                false,
            "Appointment already exist within 60 mins of intended time"
        );

        if (!isCustomerExist(_customer.customer)) {
            customers.push(_customer);
        }

        customersTimeAppointment[_customer.customer][
            _appointmentInfo.datetime
        ] = _appointmentInfo;
        emit CreateAppointment(_appointmentInfo);
    }

    function isAppointmentCollision(
        address _customer,
        SharedStructs.AppointmentInfo memory _appointmentInfo
    ) internal view returns (bool) {
        SharedStructs.AppointmentInfo memory _appt;
        for (uint8 i = 0; i <= TIMEDELAY; i++) {
            _appt = customersTimeAppointment[_customer][
                _appointmentInfo.datetime - TIMEDELAY / 2 + i
            ];
            if (_appt.attended == false && _appt.cancelled == false) {
                return true;
            }
        }

        return false;
    }

    function isCustomerExist(address _customer) internal view returns (bool) {
        for (uint8 i = 0; i <= customers.length; i++) {
            if (customers[i].customer == _customer) {
                return true;
            }
        }

        return false;
    }
}
