# StackPay Smart Contract

A decentralized invoice payment system built on Stacks blockchain that allows users to create and pay invoices with automatic late fee calculations.

## Features

- **Invoice Creation**: Create invoices with specific amounts, due dates, and payer information
- **Automatic Late Fees**: 10% late fee automatically applied for overdue payments
- **STX Payments**: Direct STX token transfers between payer and issuer
- **On-chain Storage**: All invoice data stored securely on the Stacks blockchain

## Contract Functions

### `create-invoice`
```clarity
(create-invoice (id uint) (payer principal) (amount uint) (currency (string-ascii 4)) (due-block uint))
```
Creates a new invoice with the specified parameters.

### `pay-invoice`
```clarity
(pay-invoice (id uint))
```
Processes payment for an existing invoice with automatic late fee calculation.

## Error Codes

| Code | Description |
|------|-------------|
| u1   | Invalid amount |
| u2   | Invalid due block |
| u3   | Not authorized payer |
| u4   | Invoice already paid |
| u5   | Invoice not found |
| u6   | Transfer failed |

## Success Responses

| Code | Description |
|------|-------------|
| u0   | Invoice created successfully |
| u1   | Invoice paid successfully |

## Business Logic

- Late Fee: 10% of the original amount
- Fees are calculated automatically based on `burn-block-height`
- All amounts are in STX tokens

## Data Structure

### Invoice
```clarity
{
  issuer: principal,
  payer: principal,
  amount: uint,
  currency: (string-ascii 4),
  due-block: uint,
  paid: bool,
  timestamp: uint
}
```

## Security Considerations

- Principal-based access control
- Input validation for all parameters
- Safe math operations
- Protected payment transfers

