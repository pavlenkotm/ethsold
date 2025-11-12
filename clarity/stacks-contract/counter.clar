;; Clarity Smart Contract for Stacks (Bitcoin L2)
;; Simple Counter Contract with ownership and events

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-overflow (err u102))
(define-constant err-underflow (err u103))

;; Data Variables
(define-data-var counter uint u0)
(define-data-var total-increments uint u0)

;; Maps
(define-map user-increments principal uint)

;; Read-only functions

;; Get current counter value
(define-read-only (get-counter)
  (ok (var-get counter))
)

;; Get contract owner
(define-read-only (get-owner)
  (ok contract-owner)
)

;; Get total number of increments
(define-read-only (get-total-increments)
  (ok (var-get total-increments))
)

;; Get increments by a specific user
(define-read-only (get-user-increments (user principal))
  (ok (default-to u0 (map-get? user-increments user)))
)

;; Public functions

;; Increment counter by 1
(define-public (increment)
  (let
    (
      (current-value (var-get counter))
      (user-count (default-to u0 (map-get? user-increments tx-sender)))
    )
    ;; Check for overflow
    (asserts! (< current-value u340282366920938463463374607431768211455) err-overflow)

    ;; Update counter
    (var-set counter (+ current-value u1))

    ;; Update total increments
    (var-set total-increments (+ (var-get total-increments) u1))

    ;; Update user increments
    (map-set user-increments tx-sender (+ user-count u1))

    ;; Print event
    (print {
      event: "counter-incremented",
      by: tx-sender,
      value: (+ current-value u1)
    })

    (ok (+ current-value u1))
  )
)

;; Decrement counter by 1
(define-public (decrement)
  (let
    (
      (current-value (var-get counter))
    )
    ;; Check for underflow
    (asserts! (> current-value u0) err-underflow)

    ;; Update counter
    (var-set counter (- current-value u1))

    ;; Print event
    (print {
      event: "counter-decremented",
      by: tx-sender,
      value: (- current-value u1)
    })

    (ok (- current-value u1))
  )
)

;; Increment by custom amount
(define-public (increment-by (amount uint))
  (let
    (
      (current-value (var-get counter))
    )
    ;; Check for overflow
    (asserts! (<= amount (- u340282366920938463463374607431768211455 current-value)) err-overflow)

    ;; Update counter
    (var-set counter (+ current-value amount))

    ;; Print event
    (print {
      event: "counter-incremented-by",
      by: tx-sender,
      amount: amount,
      value: (+ current-value amount)
    })

    (ok (+ current-value amount))
  )
)

;; Reset counter to zero (owner only)
(define-public (reset)
  (begin
    ;; Check if caller is owner
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)

    ;; Reset counter
    (var-set counter u0)

    ;; Print event
    (print {
      event: "counter-reset",
      by: tx-sender
    })

    (ok u0)
  )
)

;; Set counter to specific value (owner only)
(define-public (set-counter (value uint))
  (begin
    ;; Check if caller is owner
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)

    ;; Set counter
    (var-set counter value)

    ;; Print event
    (print {
      event: "counter-set",
      by: tx-sender,
      value: value
    })

    (ok value)
  )
)
