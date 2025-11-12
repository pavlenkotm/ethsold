;; SIP-010 Fungible Token Standard Implementation
;; Clarity token contract for Stacks blockchain

;; Token trait (SIP-010)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-invalid-amount (err u103))

;; Token configuration
(define-fungible-token clarity-token u1000000000000)

;; Data Variables
(define-data-var token-name (string-ascii 32) "Clarity Token")
(define-data-var token-symbol (string-ascii 10) "CLR")
(define-data-var token-decimals uint u6)
(define-data-var token-uri (optional (string-utf8 256)) none)

;; SIP-010 Functions

;; Transfer tokens
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    ;; Verify sender is tx-sender
    (asserts! (is-eq tx-sender sender) err-not-token-owner)

    ;; Verify amount is positive
    (asserts! (> amount u0) err-invalid-amount)

    ;; Transfer tokens
    (try! (ft-transfer? clarity-token amount sender recipient))

    ;; Print memo if provided
    (match memo to-print (print to-print) 0x)

    ;; Print transfer event
    (print {
      event: "transfer",
      from: sender,
      to: recipient,
      amount: amount
    })

    (ok true)
  )
)

;; Get token name
(define-read-only (get-name)
  (ok (var-get token-name))
)

;; Get token symbol
(define-read-only (get-symbol)
  (ok (var-get token-symbol))
)

;; Get token decimals
(define-read-only (get-decimals)
  (ok (var-get token-decimals))
)

;; Get balance of account
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance clarity-token account))
)

;; Get total supply
(define-read-only (get-total-supply)
  (ok (ft-get-supply clarity-token))
)

;; Get token URI
(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; Additional Functions

;; Mint tokens (owner only)
(define-public (mint (amount uint) (recipient principal))
  (begin
    ;; Check if caller is owner
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)

    ;; Verify amount is positive
    (asserts! (> amount u0) err-invalid-amount)

    ;; Mint tokens
    (try! (ft-mint? clarity-token amount recipient))

    ;; Print mint event
    (print {
      event: "mint",
      to: recipient,
      amount: amount
    })

    (ok true)
  )
)

;; Burn tokens
(define-public (burn (amount uint))
  (begin
    ;; Verify amount is positive
    (asserts! (> amount u0) err-invalid-amount)

    ;; Verify sender has sufficient balance
    (asserts! (>= (ft-get-balance clarity-token tx-sender) amount) err-insufficient-balance)

    ;; Burn tokens
    (try! (ft-burn? clarity-token amount tx-sender))

    ;; Print burn event
    (print {
      event: "burn",
      from: tx-sender,
      amount: amount
    })

    (ok true)
  )
)

;; Update token URI (owner only)
(define-public (set-token-uri (uri (string-utf8 256)))
  (begin
    ;; Check if caller is owner
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)

    ;; Update URI
    (var-set token-uri (some uri))

    ;; Print event
    (print {
      event: "token-uri-updated",
      uri: uri
    })

    (ok true)
  )
)

;; Get contract owner
(define-read-only (get-owner)
  (ok contract-owner)
)

;; Initialize - mint initial supply to contract owner
(begin
  (try! (ft-mint? clarity-token u1000000000 contract-owner))
  (print {
    event: "token-initialized",
    owner: contract-owner,
    initial-supply: u1000000000
  })
)
