;; Error constants
(define-constant ERR-INVALID-AMOUNT (err u1))
(define-constant ERR-INVALID-DUE-BLOCK (err u2))
(define-constant ERR-NOT-PAYER (err u3))
(define-constant ERR-ALREADY-PAID (err u4))
(define-constant ERR-INVOICE-NOT-FOUND (err u5))
(define-constant ERR-TRANSFER-FAILED (err u6))

;; Success responses
(define-constant SUCCESS-INVOICE-CREATED (ok u0))
(define-constant SUCCESS-INVOICE-PAID (ok u1))

;; Business logic constants
(define-constant LATE_FEE_PERCENT u10)
(define-constant FEE_DENOMINATOR u100)

;; Storage
(define-map invoices 
  { id: uint }  ;; Key type
  { 
    issuer: principal,
    payer: principal,
    amount: uint,
    currency: (string-ascii 4),
    due-block: uint,
    paid: bool,
    timestamp: uint
  }  ;; Value type
)


(define-private (create-invoice-data (id uint) (payer principal) (amount uint) (currency (string-ascii 4)) (due-block uint))
  { issuer: tx-sender,
    payer: payer,
    amount: amount,
    currency: currency,
    due-block: due-block,
    paid: false,
    timestamp: burn-block-height })

(define-public (create-invoice (id uint) (payer principal) (amount uint) (currency (string-ascii 4)) (due-block uint))
  (begin
    ;; Validate inputs
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (>= due-block burn-block-height) ERR-INVALID-DUE-BLOCK)
    
    ;; Create the invoice using helper function
    (map-set invoices
      { id: id }
      (create-invoice-data id payer amount currency due-block))
    SUCCESS-INVOICE-CREATED
  ))

(define-public (pay-invoice (id uint))
  (let
    (
      (invoice (map-get? invoices { id: id }))
    )
    (match invoice
      invoice-data
      (begin
        (asserts! (is-eq (get payer invoice-data) tx-sender) ERR-NOT-PAYER)
        (asserts! (not (get paid invoice-data)) ERR-ALREADY-PAID)

        ;; Calculate payment amount with late fee if applicable
        (let 
          ((base-amount (get amount invoice-data))
           (fee-amount (if (> burn-block-height (get due-block invoice-data))
                        (/ (* base-amount LATE_FEE_PERCENT) FEE_DENOMINATOR)
                        u0))
           (total-amount (+ base-amount fee-amount)))
          
          ;; Perform the transfer and handle response
          (match (stx-transfer? total-amount tx-sender (get issuer invoice-data))
            success
            (begin
              (map-set invoices { id: id } (merge invoice-data { paid: true }))
              SUCCESS-INVOICE-PAID)
            error ERR-TRANSFER-FAILED)
        )
      )
      ERR-INVOICE-NOT-FOUND
    )
  )
)
