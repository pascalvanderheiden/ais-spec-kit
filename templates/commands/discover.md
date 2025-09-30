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

3. **IMPORTANT: Use MCP Servers ONLY - Do NOT use Azure CLI or other terminal commands**
   - Connect to the appropriate MCP server for the cloud provider:
     * **Azure**: Use Azure MCP server via .vscode/mcp.json configuration
       - Use `azure_resources-query_azure_resource_graph` for resource queries
       - Use `azure_activity_log-list` for resource activity
       - Use Azure MCP server tools (NOT `az` CLI commands in terminal)
     * **AWS**: Use AWS MCP servers (aws-core, aws-api) via .vscode/mcp.json
       - Use AWS MCP server tools (NOT `aws` CLI commands in terminal)
     * **Google Cloud**: Use GCP MCP server via .vscode/mcp.json
       - Use GCP MCP server tools (NOT `gcloud` CLI commands in terminal)
   - Verify MCP server connection before proceeding
   - If MCP server is not available, ERROR "MCP server for {CLOUD_PROVIDER} not configured. Check .vscode/mcp.json"

4. Execute cloud resource discovery through MCP server (NOT terminal commands):
   - **Azure Example**: Use `azure_resources-query_azure_resource_graph` with Kusto queries
     ```kusto
     Resources
     | where tags['azd-env-name'] == 'azd-ais-lza-prd'  // Apply tag filter
     | project name, type, location, resourceGroup, tags, properties
     | order by type, name
     ```
   - Query all accessible resources matching the tag filter using MCP tools
   - For each resource, collect via MCP server queries:
     * Resource name, ID, type, and region
     * Configuration details (SKU, size, settings)
     * Tags and metadata
     * State (running, stopped, etc.)
     * Network configurations (IPs, subnets, security groups)
     * Dependencies and relationships
   - Handle pagination and rate limiting appropriately
   - Log any resources that fail to query fully
   - **NEVER run `az`, `aws`, or `gcloud` commands in the terminal - use MCP server tools exclusively**

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

- **CRITICAL**: Discovery MUST use MCP servers exclusively - do NOT execute CLI commands via terminal
- **Authentication**: 
  - **Azure**: Uses Azure MCP server with your Azure credentials (no `az login` needed if already authenticated)
  - **AWS**: Uses AWS MCP servers with AWS credentials from environment
  - **GCP**: Uses GCP MCP server with GOOGLE_APPLICATION_CREDENTIALS
- **MCP Server Configuration**: Read from `.vscode/mcp.json` in the repository
- **Available MCP Tools by Provider**:
  - **Azure**: 
    - `azure_resources-query_azure_resource_graph` - Query resources with Kusto/KQL
    - `azure_activity_log-list` - Get resource activity logs
    - Use these tools instead of running `az resource list` or similar commands
  - **AWS**: 
    - `aws-core` and `aws-api` MCP servers provide comprehensive AWS API access
    - Use MCP tools instead of running `aws` CLI commands
  - **GCP**: 
    - `google-cloud-mcp` server provides access to all GCP services
    - Use MCP tools instead of running `gcloud` commands
- **Permissions**: Discovery requires read permissions on all resources (validated through MCP server)
- **Rate Limiting**: Discovery respects cloud provider API limits (handled by MCP server)
- **Partial Results**: If some resources fail to query via MCP, continue with successful resources and note failures
- **Large Environments**: For 100+ resources, consider using more specific tag filters in your queries

### Why Use MCP Servers Instead of CLI?

1. **Structured Data**: MCP servers return structured data that's easier to parse and document
2. **Better Error Handling**: MCP servers provide detailed error messages and validation
3. **No Shell Dependencies**: Works consistently across different shells and platforms
4. **Type Safety**: MCP server responses are well-defined and validated
5. **Integration**: MCP servers are already configured in your project via `.vscode/mcp.json`

### Fallback to CLI (ONLY if MCP unavailable)

- If MCP server is not configured or accessible, provide clear setup instructions
- Do NOT automatically fall back to terminal CLI commands
- Instead, guide the user to:
  1. Check `.vscode/mcp.json` exists and is properly configured
  2. Verify cloud provider authentication (Azure CLI logged in, AWS credentials set, etc.)
  3. Restart their IDE/editor to reload MCP configuration
  4. Re-run the discover command once MCP server is accessible

### Error Handling

- If MCP server connection fails: Provide clear setup instructions for the cloud provider
- If no resources found: Verify tag filter and access permissions
- If partial discovery: Note missing resources and suggest re-running with adjusted filters
- If IaC analysis fails: Continue with resource inventory, mark IaC section as [NEEDS VERIFICATION]

Use absolute paths with the repository root for all file operations to avoid path issues.
