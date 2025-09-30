# Working Rules (AI Assistant ↔ User)

These rules govern how we collaborate. They can be updated or extended at any time upon the User's request.

1) File Operations
- Only move or delete files with explicit User permission.

2) Checklists Location
- All checklist files must be stored under `guide/checklist/`.

3) Verifying Guides Location
- All verifying guide files must be stored under `guide/verifying_guides/`.

4) Issue Lists Location
- All issue list files must be stored under `guide/reports/`.

5) Test Account
- Use this account for testing flows (auth, admin endpoints):
```
{
  "name": "Duy Dep Trai",
  "email": "duydeptrai@example.com",
  "password": "pass123",
  "role": "ADMIN"
}
```

6) Implementation Explanation
- When implementing features, explain each step as you go
- Break down complex implementations into clear, understandable parts
- Show the reasoning behind design decisions
- Provide examples of how the implemented feature works
- Explain both the "what" and "why" of each implementation step

7) Do Not Touch Working Features
- **CRITICAL RULE**: Never modify, refactor, or change any code/configuration that is already working properly
- Before making any changes, verify if the feature is already functioning correctly
- If a feature is working (APIs returning correct responses, no errors in logs), leave it untouched
- Only fix broken features or add new functionality when explicitly requested
- When in doubt, ask for permission before modifying working code
- This applies to: controllers, services, entities, configurations, scripts, and any other components

8) Evidence-Based Responses
- **CRITICAL RULE**: All answers and conclusions must be based on concrete evidence
- Always provide specific examples, code snippets, or test results to support claims
- When diagnosing issues, show actual error messages, logs, or API responses
- Avoid vague statements like "it might be" or "probably" without supporting evidence
- If uncertain, explicitly state what evidence is missing and what would be needed to confirm
- This applies to: bug reports, feature explanations, troubleshooting, and recommendations

— End of current rules —
