// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BankSystem {
    
    address public admin;

  
    mapping(address => uint256) public customers;
    mapping(address => bool) public isActiveCustomers;
    mapping(address => uint256) public employees;
    mapping(address => bool) public isActiveEmployees;
    mapping(address => uint256) public managers;
    mapping(address => bool) public isActiveManagers;

    
    enum Status { Pending, Executed, Rejected }

    
    struct Transfer {
        uint256 amount;
        uint256 customerID;   
        uint256 receiverID; 
        uint256 employeeID; 
        Status status;
    }

   
    mapping(uint256 => Transfer) private transfers;
    uint256 public transferCount;

   
    event RoleStatusChanged(uint256 indexed id, string roleType, bool isActive, uint256 timestamp);
    event TransferCreated(uint256 indexed id, uint256 indexed clientID, uint256 amount, uint256 receiverID);
    event TransferStatusUpdated(uint256 indexed id, uint256 indexed employeeID, Status status, uint256 timestamp);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Cancellation: Lack of administrator rights!");
        _;
    }

    constructor() {
        admin = msg.sender; 
    }

  
    function registerCustomer(address _hardwareAddress, uint256 _customerID) external onlyAdmin {
        customers[_hardwareAddress] = _customerID;
        isActiveCustomers[_hardwareAddress] = true;
        emit RoleStatusChanged(_customerID, "Customer", true, block.timestamp);
    }

    function registerEmployee(address _hardwareAddress, uint256 _employeeID) external onlyAdmin {
        employees[_hardwareAddress] = _employeeID;
        isActiveEmployees[_hardwareAddress] = true;
        emit RoleStatusChanged(_employeeID, "Employee", true, block.timestamp);
    }

    function registerManager(address _hardwareAddress, uint256 _managerID) external onlyAdmin {
        managers[_hardwareAddress] = _managerID;
        isActiveManagers[_hardwareAddress] = true;
        emit RoleStatusChanged(_managerID, "Manager", true, block.timestamp);
    }


    function setCustomerActiveStatus(address _hardwareAddress, bool _status) external onlyAdmin {
        isActiveCustomers[_hardwareAddress] = _status;
        emit RoleStatusChanged(customers[_hardwareAddress], "Customer", _status, block.timestamp);
    }

    function setEmployeeActiveStatus(address _hardwareAddress, bool _status) external onlyAdmin {
        isActiveEmployees[_hardwareAddress] = _status;
        emit RoleStatusChanged(employees[_hardwareAddress], "Employee", _status, block.timestamp);
    }

    function setManagerActiveStatus(address _hardwareAddress, bool _status) external onlyAdmin {
        isActiveManagers[_hardwareAddress] = _status;
        emit RoleStatusChanged(managers[_hardwareAddress], "Manager", _status, block.timestamp);
    }

    function createTransfer(uint256 _receiverID) external  payable{
      
        require(customers[msg.sender] > 0 && isActiveCustomers[msg.sender], "Rejection: Unauthorized or inactive customer!");
        require(msg.value > 0, "Cancellation: Transaction amount must be greater than 0!");

        transferCount++;
        transfers[transferCount] = Transfer({
            amount: msg.value,
            customerID: customers[msg.sender],
            receiverID: _receiverID,
            employeeID: 0,
            status: Status.Pending
        });

        emit TransferCreated(transferCount, customers[msg.sender], msg.value, _receiverID);
    }

    function approveTransfer(uint256 _id) external {     
        require(isActiveEmployees[msg.sender], "Rejection: Inactive employee!");
        require(employees[msg.sender] != 0, "Rejection: Unauthorized employee!");
        Transfer storage t = transfers[_id];
        require(t.status == Status.Pending, "Cancellation: The transaction is not waiting for approval!");

        t.status = Status.Executed;
        t.employeeID = employees[msg.sender];  

        emit TransferStatusUpdated(_id, employees[msg.sender], Status.Executed, block.timestamp);
    }

  
    function getTransferDetails(uint256 _id) external view returns (
        uint256 amount, 
        uint256 customer, 
        uint256 receiver, 
        Status status
    ) {
        Transfer memory t = transfers[_id];

        require(
            (customers[msg.sender] > 0 && isActiveCustomers[msg.sender] && customers[msg.sender] == t.customerID) || 
            (employees[msg.sender] > 0 && isActiveEmployees[msg.sender] && employees[msg.sender] == t.employeeID) || 
            (managers[msg.sender] > 0 && isActiveManagers[msg.sender]), 
            "Cancellation: Insufficient rights to view transaction data!"
        );

        return (t.amount, t.customerID, t.receiverID, t.status);
    }
}

