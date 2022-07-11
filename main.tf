terraform {
  required_providers {
    azurerm = {
      source     = "hashicorp/azurerm"
      verversion = "3.13.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "name" {
  name         = "StorageAccountNamingConvention"
  display_name = "Storage Accounts should follow naming convention"
  mode         = "Indexed"
  policy_type  = "Custom"

  policy_rule = <<POLICY_RULE
{
    "if": {
        "allOf": [
            {
                "field": "type",
                "equals": "Microsoft.Storage/storageAccounts"
            },
            {
                "field": "name",
                "notmatch": "[parameters('namingPattern')]"
            }
        ]
    },
    "then": {
        "effect": "[parameters('effectAction')]
    }
}
POLICY_RULE

  parameters = <<PARAMETERS
{
    "namingPattern": {
        "type": "String",
        "metadata": {
            "displayName": "Naming Pattern"
            "description": "Storage Account naming pattern. Using ? for letters, # for numbers."
        }
        "defaultValue": "4sysops???####"
    },

    "effectAction": {
        "type": "String",
        "metadata": {
            "displayName": "Effect Action"
            "description": "The effect action for the policy (Audit or Deny)."
        },
        "allowedValues": [
            "Audit",
            "Deny"
        ]
        "defaultValue": "Audit"
    }
}
PARAMETERS

}
