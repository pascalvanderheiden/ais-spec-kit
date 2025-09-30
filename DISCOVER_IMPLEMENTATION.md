# Discover Command Implementation Summary

## Overview

This document summarizes the addition of the `/discover` command to the Specify CLI, which enables cloud infrastructure discovery and analysis using MCP (Model Context Protocol) servers.

## Files Created

### 1. Templates

#### `templates/discovery-template.md`
- Comprehensive template for documenting discovered cloud infrastructure
- Sections include:
  - **Discovery Summary**: Environment overview, resource counts, statistics
  - **Resource Inventory**: Detailed tables for compute, storage, network, database, and security resources
  - **Resource Dependencies**: Dependency graphs and critical relationships
  - **IaC Analysis**: Existing Infrastructure as Code coverage and gaps
  - **Configuration Details**: Tags, security, monitoring, backup configurations
  - **Cost and Sizing Analysis** (optional)
  - **Compliance and Governance** (optional)
  - **Integration with Planning/Tasks**: How to use discovery in subsequent workflow steps
- Includes execution flow and quality checklists

#### `templates/commands/discover.md`
- Command definition file for AI agents
- Includes:
  - Script paths for bash and PowerShell
  - Detailed workflow for cloud resource discovery
  - MCP server integration instructions
  - Tag filter parsing and usage examples
  - Resource categorization logic
  - IaC analysis steps
  - Integration guidance for planning and tasks
  - Error handling procedures

### 2. Scripts

#### `scripts/bash/discover-environment.sh`
- Bash implementation of discovery script
- Features:
  - Cloud provider validation (Azure, AWS*, GCP*)
  - Tag filter parsing
  - Repository root detection (Git and non-Git)
  - Discovery session naming with timestamps
  - Branch creation for discovery sessions
  - Environment variable management (`SPECIFY_DISCOVERY`, `SPECIFY_CLOUD_PROVIDER`)
  - JSON output mode for AI agent integration
  - Configuration file reading from `.specify/config`

#### `scripts/powershell/discover-environment.ps1`
- PowerShell equivalent of bash script
- Maintains feature parity with bash version
- Windows-compatible path handling
- Same functionality for cloud provider detection and session management

### 3. CLI Updates

#### `src/specify_cli/__init__.py`
Modified to include:

1. **New Constants**:
   ```python
   CLOUD_PROVIDER_CHOICES = {
       "azure": "Microsoft Azure",
       "aws": "Amazon Web Services (coming soon)",
       "gcp": "Google Cloud Platform (coming soon)",
       "none": "Skip cloud discovery setup"
   }
   ```

2. **Interactive Cloud Provider Selection**:
   - Added cloud provider selection during `specify init`
   - Uses arrow-key selection interface (same UX as AI agent selection)
   - Default selection: Azure
   - Shows warning for AWS/GCP as coming soon

3. **Configuration File Creation**:
   - Creates `.specify/config` file with cloud provider setting
   - Tracked in project initialization workflow
   - Used by discovery scripts to determine cloud provider

4. **Updated Next Steps**:
   - Conditionally shows `/discover` command when Azure is selected
   - Updated step numbering to include discovery as step 2.1
   - Added discovery usage examples in enhancement commands section

### 4. Documentation

#### `README.md`
Updated with:

1. **Quick Start Section**:
   - Added Step 3 for `/discover` (optional)
   - Updated subsequent step numbers (4-7)
   - Example usage with tag filters

2. **Commands Table**:
   - Added `/discover` command with description
   - Note about AWS/GCP coming soon

3. **Detailed Process Section**:
   - New "STEP 1.5 (Optional): Discover existing infrastructure"
   - Comprehensive explanation of when to use discovery
   - Tag filter format examples
   - Cloud provider configuration details
   - Discovery output description
   - Integration workflow examples
   - Updated all subsequent step numbers

4. **Command Availability Check**:
   - Updated to include `/discover` in the list of available commands

## Key Features

### Cloud Provider Support

- **Azure**: Fully supported via Azure MCP servers
- **AWS**: Coming soon (infrastructure in place, implementation pending)
- **Google Cloud**: Coming soon (infrastructure in place, implementation pending)

### Tag Filtering

Supports flexible tag filtering patterns:
- Single tag: `azd-env-name:azd-ais-lza-prd`
- Multiple tags: `env:prod,team:platform`
- No filter: discovers all accessible resources

### Discovery Capabilities

1. **Resource Inventory**:
   - Compute (VMs, containers, serverless)
   - Storage (blob, file systems)
   - Network (VNets, load balancers, DNS)
   - Database (SQL, NoSQL)
   - Security (key vaults, firewalls, identity)

2. **Configuration Analysis**:
   - Tags and metadata
   - Security configurations
   - Monitoring and observability
   - Backup and recovery settings

3. **Infrastructure as Code**:
   - Detects existing IaC (Terraform, Bicep, ARM, CloudFormation)
   - Identifies coverage gaps
   - Highlights configuration drift

4. **Integration Points**:
   - Provides context for `/specify` command
   - Identifies deployment targets for `/plan`
   - Enables resource references in `/tasks`

### Workflow Integration

Discovery fits into the Spec-Driven Development workflow:

1. **Optional Pre-Specification**: Run `/discover` before `/specify` to understand existing infrastructure
2. **Pre-Planning**: Run after `/specify` to identify deployment targets
3. **Pre-Tasks**: Reference discovered resources in task definitions

Example:
```
/constitution
/discover azd-env-name:my-prod-env
/specify Add microservice that integrates with existing database
/plan Use discovered VNet and Key Vault
/tasks
/implement
```

## Implementation Isolation

The implementation follows the requirement to minimize changes to existing files:

### New Files Only
- All core functionality in new files (templates, scripts)
- No modifications to existing templates or commands
- No changes to existing script functionality

### Minimal Existing File Changes
- `src/specify_cli/__init__.py`: 
  - Added cloud provider selection (opt-in during init)
  - Added configuration file creation
  - Updated help text and next steps
- `README.md`:
  - Added documentation for new command
  - Updated step numbers to accommodate new optional step

### No Breaking Changes
- Existing workflows unchanged
- Cloud provider selection defaults to "none" in non-interactive mode
- Discovery is completely optional
- All existing commands continue to work as before

## Configuration

### Environment Variables
- `SPECIFY_CLOUD_PROVIDER`: Cloud provider for discovery (azure, aws, gcp)
- `SPECIFY_DISCOVERY`: Current discovery session branch name

### Configuration File
Location: `.specify/config`
```
# Specify Configuration
# Cloud provider for infrastructure discovery
CLOUD_PROVIDER=azure
```

## Usage Examples

### During Init
```bash
specify init my-project
# Interactive prompts:
# 1. Choose AI assistant: copilot
# 2. Choose script type: sh
# 3. Choose cloud provider: azure
```

### Discovery Commands
```bash
# Discover with tag filter
/discover azd-env-name:azd-ais-lza-prd

# Discover by environment
/discover environment:production

# Discover multiple tags
/discover env:prod,region:eastus

# Discover all (use with caution)
/discover
```

### Integration with Planning
```bash
/discover azd-env-name:my-env
/specify Add API Gateway that routes to existing backend services
/plan 
  Use the discovered vnet-prod-01 (10.0.0.0/16)
  Deploy to subnet-api (10.0.2.0/24)
  Store secrets in kv-prod-01
  Use existing backend pool: pool-backend-prod
```

## MCP Server Requirements

The `/discover` command relies on MCP servers for cloud provider integration:

### Azure
- Requires Azure MCP server tools
- Uses tools like:
  - `azure_resource_management`
  - `azure_container_management`
  - `azure_data_management`
  - `azure_network_management`
  - etc.

### Authentication
- Azure: Requires Azure CLI login (`az login`)
- AWS: Will require AWS CLI credentials
- GCP: Will require gcloud authentication

### Permissions
- Read access to all resources in scope
- Ability to query resource configurations
- Access to resource tags and metadata

## Future Enhancements

### Planned Features
1. **AWS Support**: Full implementation of AWS discovery via AWS MCP servers
2. **GCP Support**: Full implementation of Google Cloud discovery via GCP MCP servers
3. **Multi-Cloud**: Discover resources across multiple cloud providers
4. **Resource Graph Visualization**: Generate visual dependency graphs
5. **Cost Analysis**: Integrate with cost management APIs
6. **Compliance Scanning**: Automated compliance checks during discovery
7. **Change Detection**: Track infrastructure changes over time
8. **Export Formats**: Support for JSON, YAML, and other formats

### Potential Improvements
- Incremental discovery (update existing discovery documents)
- Discovery diff comparison
- Resource filtering by type
- Custom discovery templates
- Discovery caching for large environments

## Testing Recommendations

1. **Test Cloud Provider Selection**:
   - Run `specify init` and verify cloud provider prompt appears
   - Test with `--ai` flag to ensure cloud prompt still shows
   - Verify config file creation

2. **Test Discovery Scripts**:
   - Run bash script with various tag filters
   - Test PowerShell script on Windows
   - Verify JSON output format
   - Test with missing cloud provider configuration

3. **Test Integration**:
   - Run full workflow: discover → specify → plan → tasks → implement
   - Verify discovered resources can be referenced in plans
   - Test with different cloud providers (when available)

4. **Test Error Handling**:
   - Test with invalid tag filters
   - Test without MCP server access
   - Test with missing permissions
   - Test with no resources found

## Notes

- Discovery is optional and won't affect users who don't need cloud infrastructure analysis
- The feature is designed to be extensible for future cloud providers
- All discovery output is saved in version-controlled spec directories
- Discovery sessions create new branches (similar to feature development)
- The implementation maintains consistency with existing Spec-Driven Development patterns

---

**Implementation Date**: 2025-09-30
**Status**: Complete
**Cloud Support**: Azure (full), AWS (coming soon), GCP (coming soon)
