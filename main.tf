terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.13.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "sa-naming-convention" {
  name         = "StorageAccountNamingConvention"
  display_name = "Storage Accounts should follow naming convention"
  mode         = "Indexed"
  policy_type  = "Custom"

  metadata = jsonencode({
    "version" : "1.0.0",
    "category" : "Storage"
    }
  )

  parameters = jsonencode({
    "namingPattern" : {
      "type" : "String",
      "metadata" : {
        "displayName" : "Naming Pattern",
        "description" : "Storage Account naming pattern. Using ? for letters, # for numbers."
      },
      "defaultValue" : "4sysops???####"
    },

    "effectAction" : {
      "type" : "String",
      "metadata" : {
        "displayName" : "Effect Action",
        "description" : "The effect action for the policy (Audit or Deny)."
      },
      "allowedValues" : [
        "Audit",
        "Deny"
      ],
      "defaultValue" : "Audit"
    }
    }
  )

  policy_rule = jsonencode({
    "if" : {
      "allOf" : [
        {
          "field" : "type",
          "equals" : "Microsoft.Storage/storageAccounts"
        },
        {
          "field" : "name",
          "notmatch" : "[parameters('namingPattern')]"
        }
      ]
    },
    "then" : {
      "effect" : "[parameters('effectAction')]"
    }
    }
  )
}

resource "azurerm_subscription_policy_assignment" "demo" {
  name                 = "Storage Accounts should following naming convention (demo subscription)"
  policy_definition_id = azurerm_policy_definition.sa-naming-convention.id
  subscription_id      = "/subscriptions/00000000-0000-0000-000000000000"
}
