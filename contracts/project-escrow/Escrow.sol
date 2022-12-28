pragma solidity ^0.8.2;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Escrow is Initializable  {
    enum State {
        Created,
        Payed,
        DepositFrozen,
        Completed,
        Cancelled
    }
    mapping (State => string) stateDescription;

    event Payment(address _escrow);
    event Completion(address _escrow);
    event Cancellation(address _escrow);

    State public state = State.Created;
    uint public deposit = 0;
    uint public freezeFee = 0;
    bool payedToSeller = false;

    address public buyer;
    address public seller;
    uint public cost;
    string public description;

    uint8 public constant overpaymentPercent = 5;
    uint8 public constant freezeFeePercent = 1;

    function initialize(address _buyer, address _seller, uint _costEther, string calldata _description) public initializer {
        stateDescription[State.Created] = "deal created";
        stateDescription[State.Payed] = "deposit made";
        stateDescription[State.DepositFrozen] = "seller confirmed delivery, deposit frozen";
        stateDescription[State.Completed] = "deal completed";
        stateDescription[State.Cancelled] = "deal cancelled";
        
        buyer = _buyer;
        seller = _seller;
        cost = _costEther * 1 ether;
        description = _description;
    }

    function getState() external view returns (string memory) {
        return stateDescription[state];
    }

    function depositRequired() public view returns (uint) {
        return cost + cost * overpaymentPercent / 100;
    }

    function freezeFeeRequired() public view returns (uint) {
        return cost * freezeFeePercent / 100;
    }

    function pay() external payable {
        require(msg.sender == buyer, "not buyer");
        require(state == State.Created, "is not waiting for payment");
        require(msg.value >= depositRequired(), "not enough value sent");
        
        deposit += msg.value;
        state = State.Payed;
        emit Payment(address(this));
    }

    function freezeDeposit() external payable {
        require(msg.sender == seller, "not seller");
        require(state == State.Payed, "deposit not made");
        require(msg.value >= freezeFeeRequired(), "not enough value sent");

        freezeFee += msg.value;
        state = State.DepositFrozen;
    }

    function complete() external {
        require(msg.sender == buyer, "not buyer");
        require(state == State.Payed || state == State.DepositFrozen, "is not waiting for delivery");

        state = State.Completed;  
        returnOverpayment();
        emit Completion(address(this));
    }

    function cancel() external {
        require(msg.sender == seller || (msg.sender == buyer && state != State.DepositFrozen), "not seller, not buyer, or deposit is frozen");
        require(state != State.Completed && state != State.Cancelled, "cannot cancel: escrow completed or cancelled");

        returnFullDeposit();
        returnFreezeFee();
        state = State.Cancelled;
        emit Cancellation(address(this));
    }

    function payToSeller() external {
        require(msg.sender == seller, "not seller");
        require(state == State.Completed, "deal is not completed");
        require(!payedToSeller, "operation has already been done");

        uint forTransfer = cost + freezeFee;
        deposit -= cost;
        freezeFee = 0;
        payedToSeller = true;

        if (forTransfer > 0) {
            payable(seller).transfer(forTransfer);
        }
    }

    function returnFreezeFee() internal {
        uint forTransfer = freezeFee;
        freezeFee = 0;

        if (forTransfer > 0) {
            payable(seller).transfer(forTransfer);
        }
    }

    function returnFullDeposit() internal {
        uint forTransfer = deposit;
        deposit = 0;
        if (forTransfer > 0) {
            payable(buyer).transfer(forTransfer);
        }
    }
 
    function returnOverpayment() internal {
        uint forTransfer = deposit;
        if (!payedToSeller) {
            forTransfer -= cost;
        }
        deposit -= forTransfer;

        if (forTransfer > 0) {
            payable(buyer).transfer(forTransfer);
        }
    }
}