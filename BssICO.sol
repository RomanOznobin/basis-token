pragma solidity ^0.4.18;

// Created by Roman Oznobin
// Owner is Alexey Malashkin
// Smart contract for BasisToken of Ltd "KKM"


import './refundable.sol';
/// End of RefundableCrowdsale part of Basis Crowdsale contract

contract BssIco is RefundableCrowdsale {

  using SafeMath for uint;
  // Used to set wallet for RefundVault in RefundableCrowdsale constructor
  // To that address Ether will be sended if Ico will have sucsess done
  // Untill Ico is no finish and is no sucsess, all Ether are closed from anybody on RefundVault wallet
  address public constant owner_wallet = 0x79d8af6eEA6Aeeaf7a3a92D348457a5C4f0eEe1B;
  //
  address public bounty_wallet = 0x79d8af6eEA6Aeeaf7a3a92D348457a5C4f0eEe1B;

  uint public constant bountyPercent = 4;

  //address public bounty_reatricted_addr;
  //Base price for BSS ICO. Show how much Wei is in 1 BSS. During ICO price calculate from the $rate
  uint internal constant rate = 3300000000000000;

    uint public token_iso_price;
// Генерируется в Crowdsale constructor
//  BasisToken public token = new BasisToken();

  // Time sructure of Basis ico
  // start_declaration of first round of Basis ico - Presale ( start_declaration of token creation and ico Presale )
  uint public start_declaration = 1511395200;
  // The period for calculate the time structure of Basis ico, amount of the days
  uint public ico_period = 15;
  // First round finish - Presale finish
  uint public presale_finish;
  // ico Second raund start.
  uint public second_round_start;
  // Basis ico finish, all mint are closed
  uint public ico_finish = start_declaration + (ico_period * 1 days).mul(8);


  // Limmits and callculation of total minted Basis token
  uint public constant hardcap = 1536000;

  uint public softcap = 150000;

  uint public bssTotalSuply;

  // Temporary restricted list of owners and balances
  mapping(address => uint) public ico_balances;

  function BssIco() public RefundableCrowdsale(softcap, owner_wallet) Crowdsale(start_declaration, ico_finish, rate, owner_wallet)
    {

    owner = owner_wallet;
    weiRaised = 0;
    bssTotalSuply = 0;
    wallet = owner_wallet;

    token_iso_price = rate.mul(80).div(100);

    //ico_reatricted_wallet = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    //bounty_reatricted_addr = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;


    presale_finish = start_declaration + (ico_period * 1 days);
    second_round_start = start_declaration + (ico_period * 1 days).mul(2);
  }

    modifier saleIsOn() {
      require(now > start_declaration && now < ico_finish);
      _;
    }

    modifier NoBreak() {
      require(now < presale_finish  || now > second_round_start);
      _;
    }

    modifier isUnderHardCap() {
      require (bssTotalSuply <= hardcap);
      _;
    }

    function setPrice () public isUnderHardCap saleIsOn {
          if  (now < presale_finish ){
               // Chek total supply BSS for price level changes
              if( bssTotalSuply > 50000 && bssTotalSuply <= 100000 ) {
                  token_iso_price = rate.mul(85).div(100);
              }
                if( bssTotalSuply > 100000 && bssTotalSuply <= 150000 ) {
                  token_iso_price = rate.mul(90).div(100);
                  }

          }
          else {
               if(bssTotalSuply <= 200000) {
                   token_iso_price = rate.mul(90).div(100);
               } else { if(bssTotalSuply <= 400000) {
                        token_iso_price = rate.mul(95).div(100);
                        }
                        else {
                        token_iso_price = rate;
                        }
                      }
           }
    }

    function getActualPrice() public returns (uint) {
        setPrice ();
        return token_iso_price;
    }

   function buyTokens() external payable saleIsOn NoBreak {

     //require(beneficiary != address(0));
     require(validPurchase(msg.value));

     uint256 weiAmount = msg.value;

     // calculate token amount to be created
     uint256 tokens = weiAmount.div(token_iso_price);
     if  (now < presale_finish ){
         require ((bssTotalSuply + tokens) <= softcap);
     }
    require ((bssTotalSuply + tokens) < hardcap);
     // update state
     weiRaised = weiRaised.add(weiAmount);

     token.mint( msg.sender, tokens);
     TokenPurchase(msg.sender, msg.sender, weiAmount, tokens);

     forwardFunds();
     bssTotalSuply += tokens;
    }

   // fallback function can be used to buy tokens
   function () external payable {
     buyTokensFor(msg.sender);
   }

   function buyTokensFor(address beneficiary) public payable saleIsOn NoBreak {

     require(beneficiary != address(0));
     require(validPurchase(msg.value));

     uint256 weiAmount = msg.value;

     // calculate token amount to be created
     uint256 tokens = weiAmount.div(token_iso_price);
      if  (now < presale_finish ){
         require ((bssTotalSuply + tokens) <= softcap);
     }
    require ((bssTotalSuply + tokens) < hardcap);
     // update state
     weiRaised = weiRaised.add(weiAmount);

     token.mint( beneficiary, tokens);
     TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

     forwardFunds();
     bssTotalSuply += tokens;
 }

   function extraTokenMint(address beneficiary, uint _tokens) external payable saleIsOn onlyOwner {

    require(beneficiary != address(0));
    require ((bssTotalSuply + _tokens) < hardcap);

    uint weiAmount = _tokens.mul(token_iso_price);
     // update state
    weiRaised = weiRaised.add(weiAmount);

     token.mint( beneficiary, _tokens);
     TokenPurchase(msg.sender, beneficiary, weiAmount, _tokens);

     //forwardFunds();
     bssTotalSuply += _tokens;
  }

  function goalReached() public constant returns (bool) {
    return bssTotalSuply >= softcap;
  }

  function bounty_mining () internal {
    uint bounty_tokens = bssTotalSuply.mul(bountyPercent).div(100);
    token.mint(bounty_wallet, bounty_tokens);
    bssTotalSuply += bounty_tokens;
    }

  // vault finalization task, called when owner calls finalize()
  function finalization() internal {
    if (goalReached()) {
        bounty_mining ();
    }
    super.finalization();
  }

  function ico_final() onlyOwner public {

    finalization();
    Finalized();

    isFinalized = true;

  }

  function EtherTakeAfterSoftcap () onlyOwner public {
      require ( bssTotalSuply >= softcap );
      vault.TakeEther() ;
  }


}
