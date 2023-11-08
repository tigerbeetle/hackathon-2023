import {
  BankAccount,
  USD,
  EUR,
  createUsdBankTransfer,
  createUsdFundingTransfer,
  usdBankAccountDefaults,
  USD_ISSUER,
  uuidv7,
} from "./generated.js";
import {
  CreateAccountError,
  CreateTransferError,
  createClient,
} from "tigerbeetle-node";

// Create two accounts, the classic Alice and Bob

const alice: BankAccount<USD> = {
  ...usdBankAccountDefaults,
  id: uuidv7(),
};

const bob: BankAccount<USD> = {
  ...usdBankAccountDefaults,
  id: uuidv7(),
};

const client = createClient({
  cluster_id: 0,
  replica_addresses: [process.env.TB_ADDRESS || "3000"],
});

console.log("Creating accounts");
const accounts = [USD_ISSUER, alice, bob];
console.log(accounts);
for (const error of await client.createAccounts(accounts)) {
  if (
    error.result !== CreateAccountError.ok &&
    error.result !== CreateAccountError.exists
  ) {
    console.error(
      `Batch account at ${error.index} failed to create: ${
        CreateAccountError[error.result]
      }.`
    );
  }
}

// Then we're going to fund both of their accounts and create a transfer between them

const aliceToBob = createUsdBankTransfer({
  amount: 100n,
  debit_account_id: alice.id,
  credit_account_id: bob.id,
});

console.log("Creating transfers");
const transfers = [
  createUsdFundingTransfer({ amount: 100n, credit_account_id: alice.id }),
  createUsdFundingTransfer({ amount: 100n, credit_account_id: bob.id }),
  aliceToBob,
];
console.log(transfers);
for (const error of await client.createTransfers(transfers)) {
  if (
    error.result !== CreateTransferError.ok &&
    error.result !== CreateTransferError.exists
  ) {
    console.error(
      `Batch transfer at ${error.index} failed to create: ${
        CreateTransferError[error.result]
      }.`
    );
  }
}

console.log("Alice paid Bob 100 USD!");

process.exit(0);
