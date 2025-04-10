terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Use Azure CLI authentication (recommended for local development)
provider "azurerm" {
  features {}

  # subscription_id = var.subscription_id
  # client_id       = var.client_id
  # client_secret   = var.client_secret  # Must be the actual secret value
  # tenant_id       = var.tenant_id

    # These values will be pulled from your Azure CLI context
  subscription_id = "9c29117e-bf0a-4840-820e-6f9e8cd23506"
  tenant_id       = "cce39ac2-c32b-45f4-a3bc-0d84939e8f06"

}

 
# 🔹 Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.rg_prefix}-rg"
  location = var.location
  tags     = var.tags
}
 
# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
 
# Create Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.project_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
 
# Create Public IP for VM
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.project_prefix}-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
 
# Create Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.project_prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
 
# Allow RDP (3389) in NSG
resource "azurerm_network_security_rule" "allow_rdp" {
  name                        = "${var.project_prefix}-allow-rdp"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*" # Restrict this to your IP for security
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}
# Allow HTTP (80) in NSG
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "${var.project_prefix}-allow-http"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}
 
# Allow HTTPS (443) in NSG
resource "azurerm_network_security_rule" "allow_https" {
  name                        = "${var.project_prefix}-allow-https"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}
 
# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
 
# Create Network Interface with Public IP
resource "azurerm_network_interface" "nic" {
  name                = "${var.project_prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
 
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}
 
# Create Windows Virtual Machine with IIS and .NET 9
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "${var.project_prefix}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!" # Change this to a secure password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

# Azure DevOps Agent Installation and RDP Configuration
resource "azurerm_virtual_machine_extension" "install_ado_agent" {
  name                 = "${var.project_prefix}-install-ado-agent"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = jsonencode({
    "commandToExecute" = <<-EOT
      powershell -Command "
        $ErrorActionPreference = 'Stop'

        # Enable RDP
        Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'
        Set-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server' -Name fDenyTSConnections -Value 0

        # Parameters
        $azureDevOpsUrl = '${var.azure_devops_url}'
        $patToken = '${var.azure_devops_pat}'
        $agentPool = '${var.azure_devops_pool}'
        $agentName = '${var.project_prefix}-iis-agent'

        # Create agent directory
        $agentDir = 'C:\\azagent'
        New-Item -Path $agentDir -ItemType Directory -Force
        mkdir C:\\azagent2


        # Download agent
        $agentZip = \"$agentDir\\agent.zip\"
        $agentUrl = \"$azureDevOpsUrl/_apis/distributedtask/packages/agent?platform=win-x64&top=1\"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $agentUrl -Headers @{Authorization = \"Basic $([Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(\":$patToken\")))} -OutFile $agentZip

        # Extract and configure
        Expand-Archive -Path $agentZip -DestinationPath $agentDir -Force
        Push-Location $agentDir
        .\\config.cmd --unattended `
          --url $azureDevOpsUrl `
          --auth pat `
          --token $patToken `
          --pool $agentPool `
          --agent $agentName `
          --replace `
          --acceptTeeEula `
          --runAsService `
          --windowsLogonAccount \"NT AUTHORITY\\SYSTEM\"

        # Start service and clean up
        Start-Service -Name vstsagent*
        Remove-Item $agentZip -Force
      "
    EOT
  })
}
