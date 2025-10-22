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

;; Data Maps
(define-map papers
  { paper-id: uint }
  {
    author: principal,
    title: (string-ascii 100),
    content-hash: (string-ascii 64),
    submitted-block: uint,
    status: uint,
    review-count: uint,
    total-stake: uint
  }
)

(define-map reviews
  { review-id: uint }
  {
    paper-id: uint,
    reviewer: principal,
    submitted-block: uint,
    review-hash: (string-ascii 64),
    stake-amount: uint,
    quality-score: uint,
    stake-returned: bool
  }
)

(define-map paper-reviews
  { paper-id: uint, reviewer: principal }
  { review-id: uint }
)

(define-map reviewer-reputation
  { reviewer: principal }
  {
    total-reviews: uint,
    average-quality: uint,
    total-stake-earned: uint,
    total-stake-lost: uint
  }
)

(define-map quality-evaluations
  { review-id: uint, evaluator: principal }
  { quality-score: uint }
)

(define-map review-quality-totals
  { review-id: uint }
  {
    total-score: uint,
    evaluation-count: uint
  }
)

;; Read-only functions
(define-read-only (get-paper (paper-id uint))
  (map-get? papers { paper-id: paper-id })
)

(define-read-only (get-review (review-id uint))
  (map-get? reviews { review-id: review-id })
)

(define-read-only (get-reviewer-reputation (reviewer principal))
  (map-get? reviewer-reputation { reviewer: reviewer })
)

(define-read-only (has-reviewed (paper-id uint) (reviewer principal))
  (is-some (map-get? paper-reviews { paper-id: paper-id, reviewer: reviewer }))
)

(define-read-only (get-review-quality (review-id uint))
  (map-get? review-quality-totals { review-id: review-id })
)

;; New read-only helpers
(define-read-only (get-paper-stats (paper-id uint))
  ;; Returns optional map with review-count and total-stake for a paper
  (match (map-get? papers { paper-id: paper-id })
    paper
      (ok { review-count: (get review-count paper), total-stake: (get total-stake paper) })
    (err err-not-found)
  )
)

(define-read-only (get-review-stake (review-id uint))
  ;; Returns the stake amount and whether stake has been returned for a review
  (match (map-get? reviews { review-id: review-id })
    r
      (ok { stake-amount: (get stake-amount r), stake-returned: (get stake-returned r) })
    (err err-not-found)
  )
)

;; Public functions
;; #[allow(unchecked_data)]
(define-public (submit-paper (title (string-ascii 100)) (content-hash (string-ascii 64)))
  (let
    (
      (paper-id (var-get next-paper-id))
    )
    (map-set papers
      { paper-id: paper-id }
      {
        author: tx-sender,
        title: title,
        content-hash: content-hash,
        submitted-block: stacks-block-height,
        status: status-open,
        review-count: u0,
        total-stake: u0
      }
    )
    (var-set next-paper-id (+ paper-id u1))
    (ok paper-id)
  )
)

;; #[allow(unchecked_data)]
(define-public (submit-review (paper-id uint) (review-hash (string-ascii 64)) (stake-amount uint))
  (let
    (
      (paper-data (unwrap! (get-paper paper-id) err-not-found))
      (review-id (var-get next-review-id))
      (current-reputation (get-reviewer-reputation tx-sender))
    )
    (asserts! (>= stake-amount min-reviewer-stake) err-insufficient-stake)
    (asserts! (not (has-reviewed paper-id tx-sender)) err-already-reviewed)
    (asserts! (< (- stacks-block-height (get submitted-block paper-data)) review-period-blocks) err-review-closed)
    
    (try! (stx-transfer? stake-amount tx-sender (as-contract tx-sender)))
    
    (map-set reviews
      { review-id: review-id }
      {
        paper-id: paper-id,
        reviewer: tx-sender,
        submitted-block: stacks-block-height,
        review-hash: review-hash,
        stake-amount: stake-amount,
        quality-score: u0,
        stake-returned: false
      }
    )
    
    (map-set paper-reviews
      { paper-id: paper-id, reviewer: tx-sender }
      { review-id: review-id }
    )
    
    (map-set papers
      { paper-id: paper-id }
      (merge paper-data {
        review-count: (+ (get review-count paper-data) u1),
        total-stake: (+ (get total-stake paper-data) stake-amount),
        status: status-under-review
      })
    )
    
    (match current-reputation
      rep
        (map-set reviewer-reputation
          { reviewer: tx-sender }
          (merge rep { total-reviews: (+ (get total-reviews rep) u1) })
        )
      (map-set reviewer-reputation
        { reviewer: tx-sender }
        {
          total-reviews: u1,
          average-quality: u0,
          total-stake-earned: u0,
          total-stake-lost: u0
        }
      )
    )
    
    (var-set next-review-id (+ review-id u1))
    (ok review-id)
  )
)