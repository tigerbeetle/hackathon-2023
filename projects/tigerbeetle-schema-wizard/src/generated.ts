// ...not actually generated ;)
import {
  Account,
  AccountFlags,
  Transfer,
  TransferFlags,
} from "tigerbeetle-node";
// The docs recommend using ULIDs or UUIDv7s for IDs so we do that automatically for you
import { uuidv7obj } from "uuidv7";
import { Merge } from "type-fest";

/// Each ledger represents a different asset within our database
export enum Ledgers {
  USD = 1000,
  EUR = 1001,
}
export type USD = Ledgers.USD;
export type EUR = Ledgers.EUR;

/// The type of account
export enum AccountCodes {
  BANK_ACCOUNT = 1,
}

/// The type of transfer
export enum TransferCodes {
  FUNDING_TRANSFER = 1,
  BANK_TRANSFER = 2,
}

const accountDefaults: Omit<Account, "id" | "ledger" | "code"> = {
  flags: AccountFlags.none,
  debits_pending: 0n,
  credits_pending: 0n,
  debits_posted: 0n,
  credits_posted: 0n,
  user_data_128: 0n,
  user_data_64: 0n,
  user_data_32: 0,
  reserved: 0,
  timestamp: 0n,
};

const transferDefaults: Omit<
  Transfer,
  "id" | "amount" | "debit_account_id" | "credit_account_id" | "ledger" | "code"
> = {
  flags: TransferFlags.none,
  user_data_128: 0n,
  user_data_64: 0n,
  user_data_32: 0,
  timestamp: 0n,
  timeout: 0,
  pending_id: 0n,
};

export const usdBankAccountDefaults: Omit<BankAccount<USD>, "id"> = {
  ...accountDefaults,
  ledger: Ledgers.USD,
  code: AccountCodes.BANK_ACCOUNT,
  flags: AccountFlags.debits_must_not_exceed_credits,
};

export interface IssuerAccount<L extends number = Ledgers> extends Account {
  ledger: L;
  flags: AccountFlags.credits_must_not_exceed_debits;
}

/// The debits on this account represent the total outstanding USD in the system
export const USD_ISSUER: IssuerAccount<USD> = {
  ...usdBankAccountDefaults,
  id: 1n,
  flags: AccountFlags.credits_must_not_exceed_debits,
};

/// A bank transfer between two USD accounts
const usdBankTransferDefaults: Omit<
  BankTransfer<USD>,
  "id" | "amount" | "debit_account_id" | "credit_account_id"
> = {
  ...transferDefaults,
  ledger: Ledgers.USD,
  code: TransferCodes.BANK_TRANSFER,
};

/// A funding transfer from the issuer to a USD account
const usdFundingTransferDefaults: Omit<
  FundingTransfer<USD>,
  "id" | "amount" | "credit_account_id"
> = {
  ...transferDefaults,
  ledger: Ledgers.USD,
  code: TransferCodes.FUNDING_TRANSFER,
  debit_account_id: USD_ISSUER.id,
};

export type BankAccount<L = Ledgers> = Required<
  Merge<
    Account,
    {
      ledger: L;
      code: AccountCodes.BANK_ACCOUNT;
      flags: AccountFlags.debits_must_not_exceed_credits;
    }
  >
>;

export type FundingTransfer<L = Ledgers> = Required<
  Merge<Transfer, { ledger: L; code: TransferCodes.FUNDING_TRANSFER }>
>;

export type BankTransfer<L = Ledgers> = Required<
  Merge<Transfer, { ledger: L; code: TransferCodes.BANK_TRANSFER }>
>;

/// Generate a UUIDv7 as a bigint
export function uuidv7(): bigint {
  return BigInt("0x" + uuidv7obj().toHex());
}

/// Helper method to create a USD bank transfer between two accounts
export function createUsdBankTransfer({
  amount,
  debit_account_id,
  credit_account_id,
}: {
  amount: bigint;
  debit_account_id: bigint;
  credit_account_id: bigint;
}): BankTransfer<USD> {
  return {
    ...usdBankTransferDefaults,
    id: uuidv7(),
    amount,
    debit_account_id,
    credit_account_id,
  };
}

/// Helper method to create a USD funding transfer from the issuer to an account
export function createUsdFundingTransfer({
  amount,
  credit_account_id,
}: {
  amount: bigint;
  credit_account_id: bigint;
}): FundingTransfer<USD> {
  return {
    ...usdFundingTransferDefaults,
    id: uuidv7(),
    amount,
    credit_account_id,
  };
}
