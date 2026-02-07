# Terraform Agents Skills

I have developed these skills to ensure infrastructure delivery adheres to a specific subset of governance and security rules. As a proof of concept, I have included **Hub-and-Spoke** resources generated in a single shot via these agents.

🤝 **Contributions are welcome!** Feel free to submit a PR or suggest improvements.

A collection of enterprise-grade AI agent skills designed to standardize, secure, and automate Azure infrastructure delivery.

These skills turn your AI assistant into a **Senior Platform Engineer** capable of scaffolding projects, enforcing governance, and generating secure code that complies with our strict **Hub-and-Spoke architecture**.

## 🚀 Quick Start

### Installation
1. Ensure you have the [Claude CLI](https://github.com/anthropics/claude-code) or a compatible agent environment installed.
2. Clone this repository.
3. Copy the contents of the `skills/` directory to your local agent configuration:
   ```bash
   mkdir -p ~/.claude/skills
   cp -r skills/* ~/.claude/skills/
   ```
4. Copy the `CLAUDE.md` file to the root of your infrastructure repository to activate the "Master Prompt" context.

### Verification

Ask your agent:

> "What skills do you have available?"
> It should list the 5 core skills below.

---

## 🛠️ Skill Catalog (More to Come)

| Skill Name | Description | Triggers |
| :--- | :--- | :--- |
| **[`terraform-spoke-onboarding`](./.agent/skills/terraform-spoke-onboarding/SKILL.md)** | Scaffolds new Hub or Spoke projects with the correct `Workload/` vs `Deployment/` directory structure. | `new project`, `onboard spoke`, `create workload` |
| **[`terraform-azure-standards`](./.agent/skills/terraform-azure-standards/SKILL.md)** | Enforces AJFC naming conventions (e.g., `rg-ajfc-hub-cin-data-01`) and mandatory tagging policies. | `naming convention`, `tags`, `standard names` |
| **[`terraform-code-style`](./.agent/skills/terraform-code-style/SKILL.md)** | Ensures code quality by enforcing strict file structures (`data.tf`, `locals.tf`) and prohibiting hardcoded values. | `lint code`, `check style`, `refactor` |
| **[`terraform-rbac-management`](./.agent/skills/terraform-rbac-management/SKILL.md)** | Generates secure, ID-free RBAC assignments using dynamic runtime resolution (`data` sources). | `assign role`, `rbac`, `grant access` |
| **[`terraform-cicd-pipeline`](./.agent/skills/terraform-cicd-pipeline/SKILL.md)** | Generates OIDC-authenticated GitHub Actions workflows that map correctly to our split directory structure. | `create pipeline`, `ci/cd`, `github action` |

---

## 🏗️ Architecture Standards

These skills enforce a strict **Hub-and-Spoke** model:

### 1. Directory Separation

We separate source code from configuration to allow for multi-environment deployments.

* **Code:** `Workload/[Scope]/[Project]/[Component]/` (contains `.tf` files)
* **Config:** `Deployment/[Scope]/[Project]/[Component]/` (contains `.tfvars`)

### 2. Security First

* **No IDs in Config:** We never hardcode Object IDs or Subscription IDs in `.tf` files. We use names and resolve them via `data` sources.
* **OIDC Auth:** Pipelines use OpenID Connect; no long-lived client secrets.
* **Remote State:** All state is stored in the Hub storage account with specific key paths.

---

## 👩‍💻 Usage Examples

### Scenario: New Project Onboarding

**User:** *"I need to onboard a new AI project called 'genbot' in the dev environment."*
**Agent Action:**

1. Triggers `terraform-spoke-onboarding`.
2. Creates `Workload/Spokes/genbot/` directories.
3. Creates `Deployment/Spokes/genbot/` tfvars.
4. Validates names using `terraform-azure-standards`.

### Scenario: Granting Access

**User:** *"Give the GitHub Action read access to the Key Vault."*
**Agent Action:**

1. Triggers `terraform-rbac-management`.
2. Generates a human-readable RBAC map using `principal_name` instead of IDs.
3. Adds the validation block to ensure the principal exists.

### Scenario: Pipeline Generation

**User:** *"Create a pipeline for the genbot network component."*
**Agent Action:**

1. Triggers `terraform-cicd-pipeline`.
2. Generates a `.yml` file that correctly points `working_directory` to Workload and `tfvars_file` to Deployment.

### Tested Scenario: 


```
Create using terraform and azure. Use skills
Hub-Data-RG	Resource Group rg-ajfc-hub-cin-data-01
Storage Account	stajfchubcindata01
Log Analytics	log-ajfc-hub-cin-01
Key Vault	kv-ajfc-hub-cin-data-01
Hub-Identity-RG	Resource Group	rg-ajfc-hub-cin-identity-01
User Managed Identity	id-ajfc-hub-cin-github-01
```
```
I need to onboard a new spoke project called 'finbot' in the dev environment hosted in Central India. Please scaffold the directory structure and generate the Terraform code for the following resources:
Network: A Virtual Network with subnets for application and data.
Data: A Storage Account for transaction logs and a Key Vault for secrets.
Compute: An AKS cluster for the application workloads.
AI: An Azure OpenAI instance for the financial model
```


---

## 🤝 Contributing

1. **TDD is Mandatory:** All new skills must include a test plan (`baseline-scenarios.md`) before implementation.
2. **Structure:** Follow the pattern `skills/<name>/SKILL.md` + `skills/<name>/references/`.
3. **Validation:** Ensure new skills do not conflict with existing naming or architectural standards.

