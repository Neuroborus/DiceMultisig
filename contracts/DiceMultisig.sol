pragma solidity >=0.4.25 <=0.7.4;
//pragma experimental ABIEncoderV2; //    to use Structs as Function parameters

/** 
 * @title DiceMultisig
 * @dev Implements logic of 12-sided dice with multisig
 */
contract DiceMultisig {
   enum RollType{JOIN_FIRST, ROLL_AGAIN}
   struct RollLog{
       RollType rollType;
       address from;
       uint numConfirmations;
   }

   event NewRollRequest(uint indexed _actionId);
   event RollConfirmedByAddress(uint indexed _actionId, address indexed _address);
   event RollUnconfirmedByAddress(uint indexed _actionId, address indexed _address);
   event EnoughConfirmsToCreatorsApprove(uint indexed _actionId);
   event RollApprovedByCreator(uint indexed _actionId, uint indexed _newScore);

   modifier onlyPlayer(){
       require(score[msg.sender]!=0, "not a player");
       _;
   }
   
   uint public playersCount = 0;
   uint private action = 0;
   mapping(address => uint) public score;
   mapping(uint=>RollLog) RollLogs;   //action=>log
   mapping(uint => mapping(address => bool)) public isConfirmed;

   constructor() public{
       score[msg.sender] = 12;
       playersCount++;
   }

    function playSide(address _address) private {
        score[_address] = uint(keccak256(abi.encodePacked(block.timestamp,  
                                          _address,  
                                          action)))%11+1;
    }

   function roll() public {
        action++;
        RollType rollType;

        if(score[msg.sender]==0){
            rollType = RollType.JOIN_FIRST;
        }else{
            rollType = RollType.ROLL_AGAIN;
        }
        RollLogs[action] = RollLog(rollType, msg.sender,0);

        emit NewRollRequest(action);
   }

   function confirmRoll(uint _actionId) public onlyPlayer {
       require(!isConfirmed[_actionId][msg.sender], "already confirmed from this address");

       RollLog memory log = RollLogs[_actionId];
       log.numConfirmations++;
       RollLogs[_actionId] = log;

       if(log.numConfirmations == playersCount){
           emit EnoughConfirmsToCreatorsApprove(_actionId);
       }

       emit RollConfirmedByAddress(_actionId, msg.sender);
   }
   function unconfirmRoll(uint _actionId) public onlyPlayer {
       require(isConfirmed[_actionId][msg.sender], "already unconfirmed by this address");

       RollLog memory log = RollLogs[_actionId];
       log.numConfirmations--;
       RollLogs[_actionId] = log;
       
       emit RollUnconfirmedByAddress(_actionId, msg.sender);
   }

   function approveMyRoll(uint _actionId) public {
        RollLog memory log = RollLogs[_actionId];
        require(log.from==msg.sender, "not a creator of action");
        require(log.numConfirmations==playersCount, "not enough confirms");

        playSide(msg.sender);
        if(log.rollType==RollType.JOIN_FIRST){
            playersCount++;
        }

        emit RollApprovedByCreator(_actionId, score[msg.sender]);
   }

   
   function getMyScore() public view returns(uint){
       return(score[msg.sender]);
   }




}