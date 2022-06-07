// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "./libraries/shared/structs.sol";
import "./interfaces/IStoreDeployer.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract Store {
    address public owner;
    address public admin;
    SharedStructs.StoreLocation public storeLocation;
    uint256 public startTime;
    uint256 public endTime;
    address public factory;
    uint8 public storeIndex;
    address[] public customers;
    mapping(address => mapping(uint256 => SharedStructs.AppointmentInfo))
        public customersTimeAppointment;
    mapping(address => SharedStructs.AppointmentInfo[])
        public customerAppointments;
    mapping(address => uint256) public customerAppointmentCount;
    mapping(address => bool) public customerIspaid;
    mapping(uint8 => uint256) private serviceTypePrice;

    uint256 public constant TIMEDELAY = 3600;
    uint256 public constant MIN = 60;

    address public immutable token;

    event ChangeStartTime(uint256);
    event ChangeEndTime(uint256);
    event ChangeStoreLocation(SharedStructs.StoreLocation);
    event TransferOwnership(address);

    event CreateAppointment(SharedStructs.AppointmentInfo);
    event CancelAppointment(address, uint256);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can change store information");
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == factory, "only factory can initialise store");
        _;
    }

    constructor() {
        (
            address _factory,
            address _owner,
            address _token,
            uint8 _storeIndex
        ) = IStoreDeployer(msg.sender).storeParameters();
        admin = _factory;
        factory = _factory;
        owner = _owner;
        token = _token;
        storeIndex = _storeIndex;
    }

    function setStartTime(uint256 _datetime) public onlyOwner {
        startTime = (_datetime / MIN) * MIN;
        emit ChangeStartTime(startTime);
    }

    function setEndTime(uint256 _datetime) public onlyOwner {
        endTime = (_datetime / MIN) * MIN;
        emit ChangeEndTime(endTime);
    }

    function setStoreLocation(SharedStructs.StoreLocation memory _location)
        public
        onlyOwner
    {
        storeLocation = _location;
        emit ChangeStoreLocation(storeLocation);
    }

    function transferOwnership(address _newAdmin) public onlyOwner {
        owner = _newAdmin;
        emit TransferOwnership(owner);
    }

    function createAppointment(
        address customer,
        SharedStructs.AppointmentInfo memory appointmentInfo
    ) public payable onlyFactory {
        // check if customer has booked any appointment within an hour from intended time.
        console.log("Checking is appointment collision");
        require(
            isAppointmentCollision(customer, appointmentInfo) == false,
            "Appointment already exist within 60 mins of intended time"
        );

        if (!isCustomerExist(customer)) {
            customers.push(customer);
        }

        uint256 price = serviceTypePrice[appointmentInfo.serviceType];

        // transfer amount to store
        payStore(customer, price);

        customersTimeAppointment[customer][
            (appointmentInfo.datetime / MIN) * MIN
        ] = appointmentInfo;

        console.log(appointmentInfo.datetime);
        console.log((appointmentInfo.datetime / MIN) * MIN);

        customerAppointments[customer].push(appointmentInfo);
        customerAppointmentCount[customer]++;

        emit CreateAppointment(appointmentInfo);
    }

    function cancelAppointment(address customer, uint256 datetime)
        public
        onlyFactory
    {
        if (!isCustomerExist(customer)) {
            revert("customer does not exist");
        }

        customersTimeAppointment[customer][(datetime / MIN) * MIN]
            .cancelled = true;
        customersTimeAppointment[customer][(datetime / MIN) * MIN]
            .storeAddress = address(0);
        removeAppointment(datetime, customer);
        customerAppointmentCount[customer]--;
        emit CancelAppointment(customer, datetime);
    }

    function payStore(address customer, uint256 amount) public {
        ERC20(token).transferFrom(customer, address(this), amount);
    }

    function getBalance() external view onlyOwner returns (uint256) {
        return ERC20(token).balanceOf(address(this));
    }

    function isAppointmentCollision(
        address customer,
        SharedStructs.AppointmentInfo memory appointmentInfo
    ) internal view returns (bool) {
        SharedStructs.AppointmentInfo memory _appt;
        console.log("check appt collision");
        for (uint8 i = 0; i <= TIMEDELAY / MIN; i++) {
            // Total time delay divided by 2 then added per min to check
            _appt = customersTimeAppointment[customer][
                appointmentInfo.datetime - TIMEDELAY / 2 + (i * MIN)
            ];
            console.logAddress(_appt.storeAddress);
            console.log(appointmentInfo.datetime - TIMEDELAY / 2 + (i * MIN));
            if (
                _appt.storeAddress != address(0) &&
                _appt.attended == false &&
                _appt.cancelled == false
            ) {
                console.log("return true");
                return true;
            }
        }
        console.log("return false");
        return false;
    }

    function isCustomerExist(address customer) public view returns (bool) {
        if (customers.length == 0) return false;
        for (uint8 i = 0; i <= customers.length; i++) {
            console.logAddress(customers[i]);
            if (customers[i] == customer) {
                return true;
            }
        }

        return false;
    }

    function removeAppointment(uint256 datetime, address customer) internal {
        for (
            uint256 index = 0;
            index < customerAppointmentCount[customer];
            index++
        ) {
            if (customerAppointments[customer][index].datetime == datetime) {
                delete customerAppointments[customer][index];
            }
        }
    }
}
