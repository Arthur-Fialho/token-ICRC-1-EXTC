 import EXTCTokenLedger "canister:extc_icrc1_ledger_canister";    
 import Principal "mo:base/Principal";
 import Result "mo:base/Result";
 import Error "mo:base/Error";     


actor EXTCToken{
  public func getTokenName() : async Text {
        let name = await EXTCTokenLedger.icrc1_name();
        return name;
    }; 
  
  public func getTokenSymbol() : async Text {
        let symbol = await EXTCTokenLedger.icrc1_symbol();
        return symbol;
    };

  public func getTokenTotalSupply() : async Nat {
        let totalSupply = await EXTCTokenLedger.icrc1_total_supply();
        return totalSupply;
    };
  
  public func getTokenFee() : async Nat {
        let fee = await EXTCTokenLedger.icrc1_fee();
        return fee;
    };

  public func getTokenMintingPrincipal() : async Text {
   let mintingAccountOpt = await EXTCTokenLedger.icrc1_minting_account();
   
    switch (mintingAccountOpt) {
        case (null) { return "Nenhuma conta de mintagem localizada!"; };
        case (?account) {
            
            return Principal.toText(account.owner);
        };
      };
    };

  type TokenInfo = {
        name : Text; 
        symbol : Text; 
        totalSupply : Nat; 
        fee : Nat; 
        mintingPrincipal : Text; 
    }; 
    
    public func getTokenInfo() : async TokenInfo {
       
        let name = await getTokenName();
        let symbol = await getTokenSymbol();
        let totalSupply = await getTokenTotalSupply();
        let fee = await getTokenFee();
        let mintingPrincipal = await getTokenMintingPrincipal();


        let info : TokenInfo = { name = name;
                                 symbol = symbol;
                                 totalSupply = totalSupply;
                                 fee = fee;
                                 mintingPrincipal = mintingPrincipal;
                               };
       
        return info;
    };

    type TransferArgs = {
        amount : Nat;
        toAccount : EXTCTokenLedger.Account;
  }; 

  /* transferir da ledger do Canister para outra conta */
  public shared func transfer(args : TransferArgs) : async Result.Result<EXTCTokenLedger.BlockIndex, Text> {
    
    let transferArgs : EXTCTokenLedger.TransferArg = {
      memo = null;
      amount = args.amount;
      from_subaccount = null;
      fee = null;
      to = args.toAccount;
      created_at_time = null;
    };

    try {
      let transferResult = await EXTCTokenLedger.icrc1_transfer(transferArgs);

      switch (transferResult) {
        case (#Err(transferError)) {
          return #err("Não foi possível transferir fundos:
        " # debug_show (transferError));
        };
        case (#Ok(blockIndex)) { return #ok blockIndex };
      };
    } catch (error : Error) {
      return #err("Mensagem de rejeição: " # Error.message(error));
    };
  };

    public func getBalance(owner: Principal) : async Nat {
      let balance = await EXTCTokenLedger.icrc1_balance_of({ owner = owner; subaccount = null });      
      return balance;
  };

  public query func getCanisterPrincipal() : async Text {
    return Principal.toText(Principal.fromActor(EXTCToken));
  };

  public func getCanisterBalance() : async Nat {
      let owner = Principal.fromActor(EXTCToken);
      let balance = await getBalance(owner);      
      return balance;
  };

  public shared(msg) func transferFrom(to: Principal, amount: Nat) : async Result.Result<EXTCTokenLedger.BlockIndex, Text> {
  let transferFromArgs : EXTCTokenLedger.TransferFromArgs = {
                spender_subaccount = null;
                from = { owner = msg.caller; subaccount = null };                                                              
                to = { owner = to; subaccount = null };                                                              
                amount = amount;
                fee = null;
                memo = null;
               created_at_time = null; };
  try {
      let transferResult = await EXTCTokenLedger.icrc2_transfer_from(transferFromArgs);
      switch (transferResult) {
          case (#Err(transferError)) {
             return #err("Não foi possível transferir fundos:\n" # debug_show (transferError));
          };
          case (#Ok(blockIndex)) { return #ok blockIndex };
      };
  } catch (error : Error) {
      return #err("Mensagem de rejeição: " # Error.message(error));
  };
  };
};
