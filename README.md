# PaperReview DAO

A decentralized peer review protocol built on Stacks blockchain that incentivizes fair and high-quality reviews of AI research papers through a token staking and reputation system.

## Overview

PaperReview DAO creates economic incentives for thorough peer review by requiring reviewers to stake tokens. The community evaluates review quality, and stakes are redistributed based on the quality of contributions. This mechanism ensures honest, substantive feedback while building reviewer reputation on-chain.

## Features

- **Paper Submission**: Authors submit research papers for community review
- **Staked Reviews**: Reviewers stake STX tokens to submit reviews
- **Quality Evaluation**: Community members evaluate review quality
- **Automated Redistribution**: Stakes returned or forfeited based on review quality
- **Reputation System**: On-chain tracking of reviewer performance
- **Time-Bound Process**: Structured review and evaluation periods

## Smart Contract Functions

### Read-Only Functions

- `get-paper (paper-id uint)`: Retrieve paper details and status
- `get-review (review-id uint)`: Get review information
- `get-reviewer-reputation (reviewer principal)`: View reviewer's reputation metrics
- `has-reviewed (paper-id uint, reviewer principal)`: Check if reviewer has reviewed paper
- `get-review-quality (review-id uint)`: Get aggregated quality scores

### Public Functions

- `submit-paper (title, content-hash)`: Submit a paper for peer review
- `submit-review (paper-id, review-hash, stake-amount)`: Submit review with stake
- `evaluate-review (review-id, quality-score)`: Rate a review's quality (0-100)
- `finalize-review (review-id)`: Finalize review and distribute stakes
- `close-paper-review (paper-id)`: Close review period for a paper

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- STX tokens for staking
- Stacks wallet

### Installation
```bash
git clone <repository-url>
cd paper-review-dao
clarinet check
```

### Testing
```bash
clarinet test
clarinet console
```

## Usage Example
```clarity
;; Submit a paper for review
(contract-call? .paper-review-dao submit-paper
  "Attention Mechanisms in Transformer Networks"
  "QmP1q2R3s4T5u6V7w8X9y0Z1a2B3c4D5e6F7g8H9i0J1k2")

;; Submit a review with 5 STX stake
(contract-call? .paper-review-dao submit-review
  u0
  "QmA1b2C3d4E5f6G7h8I9j0K1l2M3n4O5p6Q7r8S9t0U1v2"
  u5000000)

;; Evaluate review quality (score out of 100)
(contract-call? .paper-review-dao evaluate-review u0 u85)

;; Finalize review after evaluation period
(contract-call? .paper-review-dao finalize-review u0)

;; Check reviewer reputation
(contract-call? .paper-review-dao get-reviewer-reputation 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## Review Process

### 1. Paper Submission
- Author submits paper with IPFS content hash
- Paper enters "open" status

### 2. Review Period (1,440 blocks ~10 days)
- Reviewers stake minimum 5 STX to submit reviews
- Each reviewer can submit one review per paper
- Review content stored as IPFS hash

### 3. Evaluation Period (720 blocks ~5 days)
- Community evaluates review quality (0-100 scale)
- Multiple evaluations aggregated for final score
- Reviewers cannot evaluate their own reviews

### 4. Finalization
- Reviews with average score ≥60 receive stake back
- Reviews with score <60 forfeit stake
- Reputation updated based on performance

## Quality Score Guidelines

- **90-100**: Exceptional - Comprehensive, insightful, constructive
- **75-89**: Good - Thorough analysis with actionable feedback
- **60-74**: Adequate - Meets basic review standards
- **40-59**: Poor - Superficial or unhelpful feedback
- **0-39**: Unacceptable - Off-topic or malicious

## Reputation Metrics

Tracked for each reviewer:
- **Total Reviews**: Number of reviews submitted
- **Average Quality**: Mean quality score across all reviews
- **Total Stake Earned**: STX earned from quality reviews
- **Total Stake Lost**: STX forfeited for poor reviews

## Technical Details

- **Minimum Stake**: 5 STX (5,000,000 microSTX)
- **Review Period**: 1,440 blocks (~10 days)
- **Evaluation Period**: 720 blocks (~5 days)
- **Quality Threshold**: 60/100 to recover stake
- **Content Storage**: IPFS for papers and reviews

## Economic Model

The staking mechanism creates incentives for:
- **Reviewers**: Provide quality feedback to earn/recover stakes
- **Evaluators**: Assess review quality to maintain system integrity
- **Authors**: Receive substantive feedback from engaged reviewers
- **Community**: Build reputation of trustworthy reviewers

## Security Considerations

- Reviewers cannot evaluate their own reviews
- Minimum stake prevents spam reviews
- Time-locked periods prevent manipulation
- Reputation system discourages bad actors
- Content hashes ensure review integrity

## Use Cases

1. **Academic Publishing**: Decentralized peer review for research
2. **Preprint Review**: Community feedback before formal publication
3. **Grant Proposals**: Review funding applications
4. **Technical Documentation**: Peer review of technical specs
5. **Protocol Improvements**: Review blockchain improvement proposals

## Future Enhancements

- Weighted voting based on reviewer reputation
- Appeal mechanism for disputed quality scores
- Reviewer specialization and matching
- Anonymous review option with zero-knowledge proofs
- Integration with academic credentials
- Automated payment distribution for accepted papers