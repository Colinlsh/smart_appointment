// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

library SharedStructs {
    struct Customer {
        address customer;
        string name;
    }

    struct AppointmentInfo {
        uint256 datetime;
        address storeAddress;
        string occasion;
        bool attended;
        bool cancelled;
    }
    struct StoreLocation {
        string streetName;
        string postalCode;
    }

    struct StoreInfo {
        StoreLocation storeLocation;
        uint256 startTime;
        uint256 endTime;
    }
}
