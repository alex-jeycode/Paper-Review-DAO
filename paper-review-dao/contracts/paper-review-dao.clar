;; PaperReview DAO - Decentralized peer review with token incentives

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u400))
(define-constant err-not-found (err u401))
(define-constant err-unauthorized (err u402))
(define-constant err-invalid-params (err u403))
(define-constant err-insufficient-stake (err u404))
(define-constant err-already-reviewed (err u405))
(define-constant err-review-closed (err u406))
(define-constant err-evaluation-period-active (err u407))

;; Review parameters
(define-constant min-reviewer-stake u5000000)
(define-constant review-period-blocks u1440)
(define-constant evaluation-period-blocks u720)

;; Review status
(define-constant status-open u0)
(define-constant status-under-review u1)
(define-constant status-evaluation u2)
(define-constant status-completed u3)

;; Data Variables
(define-data-var next-paper-id uint u0)
(define-data-var next-review-id uint u0)

