pragma solidity ^0.4.18;
// Created by Roman Oznobin - www.code-expert.pro
// Owner is Alexey Malashkin - www.ruarmatura.ru
// Smart contract for BasisToken of Ltd "KKM"



import './Ownable_and_SaveMath.sol';

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant public returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}



/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);

  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() internal onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

}


contract BasisToken is MintableToken {

// Created by Roman Oznobin
// Owner is Alexey Malashkin
// Smart contract for BasisToken of Ltd "KKM"

    string public constant name = "Basis Token";

    string public constant symbol = "BSS";

    uint32 public constant decimals = 0;

    address public ico_creator;

    uint cats_set_time;



    function BasisToken ( address _owner) public {
        owner = _owner;
        ico_creator = msg.sender;
    }

    function mint( address _to, uint256 _amount) public canMint returns (bool) {
        require (ico_creator == msg.sender);
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        writeTranzaction (_to);
        Mint(_to, _amount);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require (balances[msg.sender] > 0);
        writeTranzaction (msg.sender);
        writeTranzaction (_to);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        writeTranzaction (_from);
        writeTranzaction(_to);
        return super.transferFrom(_from, _to, _value);
    }



/// Devidends calculation part

    // uint internal devider;

    uint internal undelivered_balance = 0;

    bool internal stop_for_devidends_calculation = false;

    uint public date_of_casting = 0;
    uint public date_of_dividend_calculation = 1;
    uint public totalDevidendsSended = 0;

    struct Investor {
        address holder;
        uint tokens_cast;
        uint holder_devidends;
    }

    address[] public tranzaction_Arr;
    Investor[] internal Cast_Arr;
    mapping (address => uint) check_dowble;
    event DevidendSendToAll(address indexed pusher, uint256 undelivered, uint256 total_delivered);
    event DevidendIsTaken(address indexed holder, uint256 devident_taken);
    event DevidendDonat(address indexed donator, uint256 devident_given);
    mapping(address => uint) devidents_cast;
    //mapping (address => uint256 )  investor_Cast;



    function writeTranzaction (address _address) internal {
        tranzaction_Arr.push(_address);
    }

    address[] public clear_Arr;

    function makeDevidentsCast () public returns (bool) {
        require (!stop_for_devidends_calculation);
        require (msg.sender == owner
                && date_of_casting  < date_of_dividend_calculation);
        address[] memory tmp_tranzaction_Arr = tranzaction_Arr;
        address tmp_investor = tmp_tranzaction_Arr[0];
        address[] storage tmp_clear_invArr = clear_Arr;
        //check_dowble[tmp_investor] = 0;

        uint tranzaction_count = tmp_tranzaction_Arr.length;

        uint cheker = 0;
        Investor memory tmp_holder;
        for (uint i = 0; i < tranzaction_count; i++) {
            tmp_investor = tmp_tranzaction_Arr[i];
            cheker = check_dowble[tmp_investor];
            if ( cheker < 1){
//                investor_Cast(tmp_investor)= balances(tmp_investor);
                tmp_holder.holder = tmp_investor;
                tmp_holder.tokens_cast = balances[tmp_investor];
                Cast_Arr.push(tmp_holder);
                check_dowble[tmp_investor] = Cast_Arr.length;
                tmp_clear_invArr.push(tmp_investor);
            }
            else {
                cheker = cheker.sub(1);
               Cast_Arr[cheker].tokens_cast = balances[tmp_investor];
                //return false;
                //check_dowble(tmp_investor)= i + 1;
            }
        }
        tranzaction_Arr = tmp_clear_invArr;
        date_of_casting = now;
        stop_for_devidends_calculation = true;
        totalDevidendsSended = 0;
        delete clear_Arr;
        return true;
    }

    uint internal balance_for_devidends_calculation = 0;

    function devident_Culculation (uint _place_holder) view internal returns(uint) {
        uint tmp_tokens = Cast_Arr[_place_holder].tokens_cast;
        //address tmp_investor = Cast_Arr[_place_holder].holder;

        uint tmp_dolya = balance_for_devidends_calculation.mul(tmp_tokens).div(totalSupply);
        return tmp_dolya;
    }

    function devident_Casting() public {
        require (msg.sender == owner
                && date_of_casting  > date_of_dividend_calculation);
        uint tmp_balance = this.balance;
        balance_for_devidends_calculation = tmp_balance.sub(undelivered_balance);
        uint tmp_count = countOfHolders();
        for (uint i = 0; i< tmp_count; i++) {
            address tmp_investor = Cast_Arr[i].holder;
            uint tmp_devidends = devident_Culculation(i);
            Cast_Arr[i].holder_devidends = tmp_devidends;
            devidents_cast[tmp_investor] = tmp_devidends;
        }
        date_of_dividend_calculation = now;
        stop_for_devidends_calculation = false;


    }

    function send_Devidends () public payable {
        require (msg.sender == owner
                && date_of_casting  < date_of_dividend_calculation);

        totalDevidendsSended = 0;
        uint tmp_count = countOfHolders();
        uint wei_to_send;
        address holder_address;
        uint devidends_cheker;
        for (uint i = 0; i< tmp_count; i++) {
            holder_address = Cast_Arr[i].holder;
            devidends_cheker = devidents_cast[holder_address];
            if (devidends_cheker > 0) {
            wei_to_send = Cast_Arr[i].holder_devidends;
            holder_address.transfer(wei_to_send);
            Cast_Arr[i].holder_devidends = 0;
            totalDevidendsSended = totalDevidendsSended.add(wei_to_send);
            }
            else {
                Cast_Arr[i].holder_devidends = 0;
            }
        }
        undelivered_balance = balance_for_devidends_calculation.sub(totalDevidendsSended);
        DevidendSendToAll(msg.sender, undelivered_balance, totalDevidendsSended);
    }

    function takeYouProfit () public payable {
        require (devidents_cast[msg.sender] > 0 );
        uint tmp_devidends = devidents_cast[msg.sender];
        address tmp_address = msg.sender;
        tmp_address.transfer(tmp_devidends);
        devidents_cast[msg.sender] = 0;
        DevidendIsTaken(msg.sender,tmp_devidends);

    }



    function getTranzactionArr() view public returns (address[]) {
        require (tranzaction_Arr.length > 0);
        return tranzaction_Arr;
    }

    function countOfHolders() view public returns (uint) {
        require (Cast_Arr.length > 0);
        return Cast_Arr.length;
    }

    function getSelfBalance () view public returns (uint) {
        uint tmp_balance = this.balance;
        return tmp_balance;
    }

    function devidendsDonat () public payable {
        DevidendDonat(msg.sender,msg.value);
    }

}
