# OWASP Top 10 for LLM & Generative AI Applications

When designing, implementing, reviewing, or deploying applications with Large Language Models (LLMs), AI agents, or Retrieval-Augmented Generation (RAG) architectures, evaluate and enforce the following controls.

---

## 1. LLM01: Prompt Injection (Direct & Indirect)
- **Threat:** Malicious inputs alter model instructions or trick the model into bypassing security guardrails. Indirect prompt injection occurs when the model reads untrusted external data (e.g. web pages, PDFs, tickets, git issues, dependencies).
- **Controls:**
  - Enforce clear delimiter boundaries between system instructions, user prompts, and retrieved untrusted content.
  - Never allow LLM outputs to execute directly in shell or database interpreters without strict schema validation.
  - Apply content moderation / input filtering before passing text to the model.
  - Keep agent execution sandboxed and isolated from privileged infrastructure.

---

## 2. LLM02: Insecure Output Handling
- **Threat:** Downstream components blindly trust model output without sanitization, leading to XSS, SQL injection, remote code execution (RCE), or SSRF.
- **Controls:**
  - Treat all model completions as untrusted user input.
  - Parse structured LLM outputs using strict, validated schemas (e.g., Zod, Pydantic, JSON Schema).
  - Contextually encode model responses before rendering in web browsers, markdown viewers, or CLI shells.
  - Never pass raw model responses to `eval()`, `exec()`, `cmd /c`, or dynamic query builders.

---

## 3. LLM04: Model Denial of Service (DoS)
- **Threat:** Attackers submit requests that cause excessive resource consumption (long context stuffing, infinite generation loops, recursive agent tool calls), exhausting token budgets and system memory.
- **Controls:**
  - Cap maximum context tokens, prompt length, and generation `max_tokens`.
  - Impose strict timeouts and rate limits per user / IP / API key.
  - Limit agent recursive loops and tool invocation depths (e.g., maximum step counts).

---

## 4. LLM05: Supply Chain & Model Provenance
- **Threat:** Compromised third-party models, pre-trained weights, embeddings, or agent plugins introducing backdoors or executing arbitrary code upon loading.
- **Controls:**
  - Load model weights only in safe serialization formats (prefer `.safetensors` over Python `pickle` / `.pt` / `.bin`).
  - Pin model versions and verify cryptographic hashes / signatures.
  - Vet third-party MCP servers, agent tools, and prompt libraries.

---

## 5. LLM06: Sensitive Information Disclosure & Context Privacy
- **Threat:** Proprietary data, system prompts, confidential credentials, or PII exposed to the model leak into chat transcripts, public outputs, or training data.
- **Controls:**
  - Never inject `.env` files, production credentials, private keys, or raw database dumps into LLM prompt context.
  - Implement real-time PII and secret redaction filters before sending data to models.
  - Opt out of provider model training where applicable (zero-data-retention agreements).

---

## 6. LLM07: Insecure Plugin / Tool Design & LLM08: Excessive Agency
- **Threat:** LLM agents are granted excessive capabilities, broad tool permissions, or autonomous access to destructive APIs, enabling an injected prompt to perform unauthorized actions.
- **Controls:**
  - Enforce the Principle of Least Privilege on all agent tools.
  - Separate read-only search/inspection tools from write/execute tools.
  - Mandate human-in-the-loop approval (`force_ask`) for all destructive operations (database drops, git force pushes, infrastructure deletions, production deployments).
  - Use lifecycle hooks (`PreToolUse`) to inspect and gate tool arguments before execution.

---

## 7. LLM09: Overreliance & Hallucination Mitigation
- **Threat:** Blindly accepting hallucinated code, outdated library dependencies, or fabricated security statuses without verification.
- **Controls:**
  - Ground all code modifications in automated test suites (TDD) and static linters.
  - Verify every library and package version against public registries before installing.
  - Prohibit claims of "PASS" or "100% Secure" unless verified by concrete scanner exit codes and tool execution evidence.
