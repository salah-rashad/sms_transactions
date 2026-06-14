# SMS Intelligence Refactor Spec

## Context
Refactor the SMS Transactions app into a learning-based financial intelligence system using embeddings, local memory, similarity search, and incremental user-driven learning.

SMS is treated as a raw signal source, not the core product.

---

## Claude Code + Speckit Command

Use the following command to start spec generation:

```
/speckit.specify "Refactor SMS Transactions app into an offline-first financial intelligence system using embeddings, local memory, similarity search, and incremental learning. Define MVP architecture, data models, learning loops, and UX flows. Explicitly exclude live detection as MVP and treat it as post-MVP extension."
```

---

## MVP Goals

- Build initial knowledge base from full SMS inbox scan
- Extract merchant profiles and transaction patterns
- Store embeddings for messages and confirmed transactions
- Use similarity search to classify new messages based on past confirmations
- Enable incremental learning from user corrections
- Fully offline inference and storage

---

## Non-Goals (Post-MVP)

- Real-time/live SMS detection pipeline
- Push notification automation
- Advanced ML training or cloud-based inference

---

## Core Architecture Layers

1. Ingestion Layer
   - Raw SMS capture
   - Normalization

2. Feature Extraction Layer
   - Pattern detection (rules + heuristics)
   - Embedding generation

3. Memory Layer
   - Merchant profiles
   - Transaction history
   - User confirmations

4. Similarity Engine
   - Embedding comparison
   - Matching against known transactions

5. Learning Layer
   - Update memory on user confirmation
   - Adjust similarity thresholds
   - Strengthen merchant patterns

---

## Data Models

- MessageRecord
- TransactionCandidate
- ConfirmedTransaction
- MerchantProfile
- EmbeddingVector
- PatternRule

---

## Learning Flow

1. SMS is ingested
2. Embedding generated
3. Compared against memory
4. Candidate transaction produced
5. User confirms or edits
6. System updates:
   - Merchant profile
   - Similarity clusters
   - Pattern confidence

---

## UX Principles

- Show intelligence before asking for input
- Reduce user interaction over time
- Ask only on low confidence cases
- Increase automation as memory grows

---

## Open Questions

- Embedding generation strategy (local vs hybrid)
- Storage optimization for large SMS histories
- Similarity thresholds tuning strategy per user
- Migration from rule-based parser to embedding-first pipeline
