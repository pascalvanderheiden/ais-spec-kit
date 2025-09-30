````markdown
# Cloud Infrastructure Discovery: [ENVIRONMENT NAME]

**Discovery Session**: `[###-discovery-session]`  
**Created**: [DATE]  
**Cloud Provider**: [Azure | AWS | Google Cloud]  
**Environment**: [Development | Staging | Production | Other]  
**Tag Filter**: [e.g., azd-env-name:azd-ais-lza-prd]

## Execution Flow (main)
```
1. Parse tag filter from user input
   → If empty: use default discovery (all accessible resources)
2. Connect to MCP server for selected cloud provider
   → If connection fails: ERROR "Cannot connect to MCP server"
3. Discover resources matching tag filter
   → Query cloud provider API through MCP
   → Collect resource metadata, configurations, and relationships
4. Categorize resources by service type
   → Group by: compute, storage, network, database, security, etc.
5. Extract infrastructure patterns and dependencies
   → Identify resource relationships and data flows
6. Generate comprehensive resource inventory
   → Include: resource names, types, configurations, tags, regions
7. Analyze existing Infrastructure as Code (if detected)
   → Check for Terraform, Bicep, ARM templates, CloudFormation
8. Run Discovery Quality Checklist
   → Verify resource completeness
   → Check for missing configurations
9. Return: SUCCESS (discovery ready for planning/tasks)
```

---

## ⚡ Quick Guidelines
- ✅ Capture ACTUAL deployed state, not desired state
- ✅ Document resource relationships and dependencies
- ✅ Include configuration details needed for IaC generation
- ❌ Don't make assumptions about missing data
- 🏷️ Use tag filters to scope discovery to specific environments

### Section Requirements
- **Mandatory sections**: Must be completed for every discovery
- **Optional sections**: Include only when resources are found
- When a section doesn't apply (no resources of that type), remove it entirely

### For AI Generation
When creating this discovery from MCP server responses:
1. **Capture exact configurations**: Don't simplify or summarize critical settings
2. **Mark uncertainties**: Use [NEEDS VERIFICATION: specific issue] for unclear configurations
3. **Preserve relationships**: Document dependencies between resources
4. **Common areas to verify**:
   - Resource ownership and responsible teams
   - Cost allocation and billing tags
   - Compliance and security classifications
   - Disaster recovery configurations
   - Monitoring and alerting setup

---

## Discovery Summary *(mandatory)*

### Environment Overview
- **Cloud Provider**: [Azure | AWS | Google Cloud]
- **Region(s)**: [List primary and secondary regions]
- **Subscription/Account**: [ID and name]
- **Resource Groups/Projects**: [List discovered groups]
- **Total Resource Count**: [Number]
- **Discovery Date**: [ISO timestamp]
- **Tag Filter Applied**: [Filter criteria used]

### Resource Statistics
- **Compute Resources**: [Count]
- **Storage Resources**: [Count]
- **Network Resources**: [Count]
- **Database Resources**: [Count]
- **Security Resources**: [Count]
- **Other Resources**: [Count]

---

## Resource Inventory *(mandatory)*

### Compute Resources
#### Virtual Machines / Instances
| Resource Name | Type/SKU | Region | State | IP Addresses | Tags | Notes |
|---------------|----------|--------|-------|--------------|------|-------|
| vm-web-01 | Standard_D2s_v3 | eastus | Running | 10.0.1.4, 52.x.x.x | env:prod, app:web | [Example] |

#### Container Services
| Resource Name | Type | Region | State | Configuration | Tags | Notes |
|---------------|------|--------|-------|---------------|------|-------|
| aks-cluster-01 | AKS/EKS/GKE | eastus | Running | 3 nodes, v1.28 | env:prod | [Example] |

#### Serverless Functions
| Function Name | Runtime | Region | Trigger Type | Configuration | Tags | Notes |
|---------------|---------|--------|--------------|---------------|------|-------|
| func-process-data | Python 3.11 | eastus | HTTP, Queue | Consumption plan | env:prod | [Example] |

### Storage Resources
#### Blob/Object Storage
| Storage Account | Type | Region | Redundancy | Capacity | Public Access | Tags | Notes |
|-----------------|------|--------|------------|----------|---------------|------|-------|
| stproddata01 | General Purpose v2 | eastus | GRS | 500GB | Disabled | env:prod | [Example] |

#### File Systems
| Resource Name | Type | Region | Capacity | Protocol | Mount Points | Tags | Notes |
|---------------|------|--------|----------|----------|--------------|------|-------|
| fs-shared-data | Azure Files | eastus | 1TB | SMB 3.0 | /mnt/shared | env:prod | [Example] |

### Network Resources
#### Virtual Networks
| VNet Name | Address Space | Region | Subnets | Peerings | Tags | Notes |
|-----------|---------------|--------|---------|----------|------|-------|
| vnet-prod-01 | 10.0.0.0/16 | eastus | 5 subnets | 2 peerings | env:prod | [Example] |

#### Load Balancers
| LB Name | Type | Region | Frontend IPs | Backend Pools | Rules | Tags | Notes |
|---------|------|--------|--------------|---------------|-------|------|-------|
| lb-web-prod | Public | eastus | 52.x.x.x | web-pool | HTTP/HTTPS | env:prod | [Example] |

#### DNS Zones
| Zone Name | Type | Record Count | TTL Settings | Tags | Notes |
|-----------|------|--------------|--------------|------|-------|
| example.com | Public | 15 records | 3600s default | env:prod | [Example] |

### Database Resources
#### SQL Databases
| Database Name | Type | Region | SKU/Tier | Size | Backup Config | Tags | Notes |
|---------------|------|--------|----------|------|---------------|------|-------|
| sqldb-prod-01 | Azure SQL | eastus | S3 | 250GB | 7-day retention | env:prod | [Example] |

#### NoSQL Databases
| Database Name | Type | Region | Throughput | Replication | Backup | Tags | Notes |
|---------------|------|--------|------------|-------------|--------|------|-------|
| cosmos-prod-01 | Cosmos DB | eastus | 1000 RU/s | Multi-region | Continuous | env:prod | [Example] |

### Security Resources
#### Key Vaults / Secrets Managers
| Vault Name | Region | Access Policies | Secrets Count | Certificates | Tags | Notes |
|------------|--------|-----------------|---------------|--------------|------|-------|
| kv-prod-01 | eastus | 5 policies | 12 secrets | 3 certs | env:prod | [Example] |

#### Firewalls / Security Groups
| Resource Name | Type | Region | Rules Count | Associated Resources | Tags | Notes |
|---------------|------|--------|-------------|---------------------|------|-------|
| nsg-web-prod | NSG | eastus | 8 rules | 2 subnets | env:prod | [Example] |

#### Identity & Access
| Resource Name | Type | Users/Principals | Roles/Policies | Tags | Notes |
|---------------|------|------------------|----------------|------|-------|
| id-prod-app | Managed Identity | System-assigned | Contributor | env:prod | [Example] |

---

## Resource Dependencies *(mandatory)*

### Dependency Graph
```
[Describe high-level resource relationships]

Example:
- Application Gateway → Backend Pool (VMs)
- VMs → Storage Account (diagnostics)
- VMs → Key Vault (secrets)
- VMs → SQL Database (data)
- All Resources → Virtual Network (connectivity)
```

### Critical Dependencies
1. **[Resource A] depends on [Resource B]**
   - Reason: [Why this dependency exists]
   - Impact if broken: [Consequences]

2. **[Resource C] depends on [Resource D]**
   - Reason: [Why this dependency exists]
   - Impact if broken: [Consequences]

---

## Infrastructure as Code Analysis *(include if IaC detected)*

### Detected IaC Tools
- [ ] Terraform (version: [x.y.z])
- [ ] Bicep (version: [x.y.z])
- [ ] ARM Templates
- [ ] CloudFormation
- [ ] Pulumi
- [ ] Other: [specify]

### IaC Coverage
- **Resources managed by IaC**: [Count/Percentage]
- **Resources not in IaC**: [Count/Percentage]
- **IaC Repository Location**: [Git URL or path]
- **State Storage**: [Location and configuration]

### IaC Gaps
1. [Resource type] not represented in IaC
2. [Configuration drift] detected between code and deployed state
3. [Missing modules/templates] for certain resource types

---

## Configuration Details *(mandatory)*

### Tags and Metadata
**Consistent Tags Found**:
- `env`: [values found]
- `owner`: [values found]
- `cost-center`: [values found]
- `project`: [values found]

**Tagging Gaps**:
- [Number] resources missing required tags
- Inconsistent tag naming: [examples]

### Security Configurations
- **Encryption at rest**: [Enabled/Disabled for which resources]
- **Encryption in transit**: [TLS versions, protocols]
- **Public exposure**: [List resources with public IPs/endpoints]
- **Private endpoints**: [List private link configurations]
- **Authentication methods**: [List auth mechanisms found]

### Monitoring and Observability
- **Logging enabled**: [List resources with diagnostic logs]
- **Metrics collection**: [Monitoring solutions in use]
- **Alerting**: [Alert rules and notification channels]
- **Dashboards**: [Existing monitoring dashboards]

### Backup and Recovery
- **Backup enabled**: [List backed-up resources]
- **Backup frequency**: [Daily, Weekly, etc.]
- **Retention period**: [Days/Weeks/Months]
- **DR configuration**: [Cross-region replication, failover setup]

---

## Cost and Sizing Analysis *(optional)*

### Resource Sizing
| Resource Type | Current SKU/Size | Utilization | Right-sizing Opportunity | Potential Savings |
|---------------|------------------|-------------|-------------------------|-------------------|
| [Example VM] | Standard_D4s_v3 | 25% CPU | Downsize to D2s_v3 | ~50% cost reduction |

### Cost Allocation
- **Estimated monthly cost**: [Amount in currency]
- **Cost by resource type**: [Breakdown]
- **Cost by tag** (if cost tags present): [Breakdown]

---

## Compliance and Governance *(optional)*

### Compliance Requirements
- [ ] GDPR data residency requirements
- [ ] HIPAA compliance configurations
- [ ] SOC 2 controls
- [ ] PCI-DSS requirements
- [ ] Other: [specify]

### Policy Violations
1. [Policy name]: [Resources in violation]
2. [Security baseline]: [Non-compliant configurations]

### Governance Findings
- **Naming conventions**: [Compliance with standards]
- **Resource organization**: [Resource group/subscription structure]
- **Access control**: [RBAC/IAM findings]

---

## Discovery Quality Checklist
*GATE: Automated checks run during main() execution*

### Completeness
- [ ] All accessible resources discovered
- [ ] Resource configurations captured
- [ ] Dependencies documented
- [ ] Tag filter correctly applied
- [ ] No MCP server errors during discovery

### Data Quality
- [ ] Resource names accurate
- [ ] Configuration details complete
- [ ] Relationships verified
- [ ] No [NEEDS VERIFICATION] markers remain (or verified)
- [ ] Regional distribution documented

### Actionability
- [ ] Discovery usable for IaC generation
- [ ] Sufficient detail for planning/tasks
- [ ] Security configurations captured
- [ ] Cost data available (if needed)

---

## Recommendations *(optional)*

### Infrastructure Improvements
1. [Recommendation]: [Rationale and expected benefit]
2. [Optimization opportunity]: [Details]

### IaC Migration Strategy
1. **Priority 1 - Critical Resources**: [List]
2. **Priority 2 - Shared Services**: [List]
3. **Priority 3 - Supporting Resources**: [List]

### Security Hardening
1. [Security gap]: [Remediation steps]
2. [Compliance issue]: [Fix recommendation]

---

## Integration with Planning/Tasks

### For `/plan` Command
This discovery provides the following inputs for implementation planning:
- **Existing infrastructure**: [Summary of resources to integrate with]
- **Deployment targets**: [Where new resources should be deployed]
- **Network configurations**: [VNets, subnets, security groups to use]
- **Shared services**: [Existing services to leverage]

### For `/tasks` Command
Use this discovery to generate tasks for:
- **IaC Template Creation**: Generate Terraform/Bicep for discovered resources
- **Configuration Updates**: Modify existing resources based on requirements
- **New Resource Provisioning**: Deploy alongside existing infrastructure
- **Migration Tasks**: Move or replicate resources

### Example Task Integration
When generating tasks, reference discovered resources:
```
Task: "Create Terraform module for web application"
- Use existing VNet: vnet-prod-01 (10.0.0.0/16)
- Deploy to subnet: subnet-web (10.0.1.0/24)
- Store secrets in: kv-prod-01
- Use existing NSG: nsg-web-prod as baseline
```

---

## Execution Status
*Updated by main() during processing*

- [ ] Tag filter parsed
- [ ] MCP server connected
- [ ] Resources discovered
- [ ] Resources categorized
- [ ] Dependencies identified
- [ ] Inventory generated
- [ ] IaC analysis completed (if applicable)
- [ ] Quality checklist passed

---

## Appendices

### MCP Server Configuration
- **Server**: [MCP server name/endpoint]
- **API Version**: [Version used]
- **Authentication**: [Method used]
- **Query Parameters**: [Parameters passed to MCP]

### Raw Discovery Data
[Optional: Include JSON/YAML dumps of raw MCP responses for reference]

### Discovery Script Logs
[Optional: Include relevant log excerpts showing discovery process]

---

````
