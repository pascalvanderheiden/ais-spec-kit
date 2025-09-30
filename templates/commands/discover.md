---
description: Discover and analyze cloud infrastructure using MCP servers to generate comprehensive resource inventory.
scripts:
  sh: scripts/bash/discover-environment.sh --json
  ps: scripts/powershell/discover-environment.ps1 -Json
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

Given the tag filter or discovery scope provided as an argument, do this:

1. Run `{SCRIPT}` from the repo root and parse JSON for DISCOVERY_FILE, CLOUD_PROVIDER, DISCOVERY_DIR, TAG_FILTER. All future file paths must be absolute.
   - The script creates the discovery file and sets up the environment
   - If CLOUD_PROVIDER is not configured, ERROR "Cloud provider not configured. Run 'specify init' or set SPECIFY_CLOUD_PROVIDER"
   - If MCP server is not available, ERROR "MCP server for {CLOUD_PROVIDER} not accessible"

2. Parse the tag filter from user arguments:
   - Tag filter format: "key:value" or "key1:value1,key2:value2"
   - If no tag filter provided, use default discovery (all accessible resources)
   - Examples: "azd-env-name:azd-ais-lza-prd", "environment:production,team:platform"

3. Connect to the appropriate MCP server for the cloud provider:
   - **Azure**: Use Azure MCP server tools (azure_resource_management, azure_container_management, etc.)
   - **AWS**: Use AWS MCP server (coming soon)
   - **Google Cloud**: Use GCP MCP server (coming soon)
   - Verify MCP server connection before proceeding

4. Execute cloud resource discovery through MCP server:
   - Query all accessible resources matching the tag filter
   - For each resource, collect:
     * Resource name, ID, type, and region
     * Configuration details (SKU, size, settings)
     * Tags and metadata
     * State (running, stopped, etc.)
     * Network configurations (IPs, subnets, security groups)
     * Dependencies and relationships
   - Handle pagination and rate limiting appropriately
   - Log any resources that fail to query fully

5. Categorize discovered resources:
   - Group by service type: Compute, Storage, Network, Database, Security, etc.
   - Identify resource dependencies and relationships
   - Map resource groups/projects and organizational structure
   - Extract tag patterns and naming conventions

6. Analyze existing Infrastructure as Code (if present):
   - Search for IaC files: Terraform (*.tf), Bicep (*.bicep), ARM (*.json), CloudFormation (*.yaml)
   - Compare IaC definitions with discovered resources
   - Identify drift between code and actual deployment
   - Note resources not managed by IaC

7. Generate comprehensive discovery document:
   - Load `/templates/discovery-template.md` (already copied to DISCOVERY_FILE path)
   - Fill all sections with discovered data:
     * Discovery Summary: Overview, resource counts, statistics
     * Resource Inventory: Detailed tables for each resource type
     * Resource Dependencies: Dependency graph and critical relationships
     * IaC Analysis: Existing IaC coverage and gaps
     * Configuration Details: Tags, security, monitoring, backup
     * Optional sections: Cost analysis, compliance, recommendations
   - Preserve exact configurations (don't simplify critical settings)
   - Mark any uncertain or incomplete data with [NEEDS VERIFICATION: reason]

8. Extract actionable insights for planning and tasks:
   - Identify deployment targets (VNets, subnets, resource groups)
   - List shared services that can be reused
   - Document security configurations to inherit
   - Note compliance and governance requirements
   - Highlight opportunities for optimization or consolidation

9. Verify discovery completeness:
   - Check Discovery Quality Checklist in the template
   - Ensure all resource types are covered
   - Verify no MCP errors occurred
   - Confirm tag filter was applied correctly
   - Validate resource relationships are documented

10. Prepare integration with planning and tasks:
    - Add "Integration with Planning/Tasks" section
    - Specify how discovered resources inform `/plan` command
    - Define task generation patterns for IaC creation
    - Provide example task references to discovered resources

11. Update Execution Status in the template:
    - Mark each step as completed
    - Note any errors or warnings
    - Document any resources that require manual verification

12. Report results:
    - Discovery file path
    - Total resources discovered
    - Resource breakdown by type
    - Any gaps or verification needed
    - Next steps (typically `/plan` or `/tasks`)

### Example Discovery Workflow

**Scenario 1: Discover production Azure environment**
```
User: /discover azd-env-name:azd-ais-lza-prd
→ Discovers all resources tagged with azd-env-name=azd-ais-lza-prd
→ Generates comprehensive inventory in specs/XXX-discovery/discovery.md
→ Ready for /plan to design changes that integrate with existing infrastructure
```

**Scenario 2: Discover all resources in subscription**
```
User: /discover
→ Discovers all accessible resources (no tag filter)
→ May be large - use with caution
→ Useful for initial environment assessment
```

**Scenario 3: Discover specific environment**
```
User: /discover environment:staging,region:eastus
→ Discovers resources with both tags
→ Scoped to specific environment and region
→ Enables focused IaC generation
```

### MCP Server Integration Notes

- **Authentication**: Ensure cloud credentials are configured (Azure CLI logged in, AWS credentials, etc.)
- **Permissions**: Discovery requires read permissions on all resources
- **Rate Limiting**: Discovery respects cloud provider API limits
- **Partial Results**: If some resources fail to query, continue with successful resources and note failures
- **Large Environments**: For 100+ resources, consider using more specific tag filters

### Error Handling

- If MCP server connection fails: Provide clear setup instructions for the cloud provider
- If no resources found: Verify tag filter and access permissions
- If partial discovery: Note missing resources and suggest re-running with adjusted filters
- If IaC analysis fails: Continue with resource inventory, mark IaC section as [NEEDS VERIFICATION]

Use absolute paths with the repository root for all file operations to avoid path issues.
