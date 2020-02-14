resource "azurerm_virtual_network" "SSPP" {
  name                = "SSPPVNet"
  address_space       = ["20.0.0.0/16"]
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name
}

resource "azurerm_subnet" "SSPP" {
  name                 = "MgmtSubnet"
  resource_group_name  = azurerm_resource_group.lab1.name
  virtual_network_name = azurerm_virtual_network.SSPP.name
  address_prefix       = "20.0.1.0/24"
}

resource "azurerm_subnet" "SSPP1" {
  name                 = "WebSubnet"
  resource_group_name  = azurerm_resource_group.lab1.name
  virtual_network_name = azurerm_virtual_network.SSPP.name
  address_prefix       = "20.0.2.0/24"
  
}

resource "azurerm_subnet" "SSPP2" {
  name                 = "AppSubnet"
  resource_group_name  = azurerm_resource_group.lab1.name
  virtual_network_name = azurerm_virtual_network.SSPP.name
  address_prefix       = "20.0.3.0/24"
  //network_security_group_id = azurerm_network_security_group.lab1.id
}


//Gateway Subnet
resource "azurerm_subnet" "gw" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.lab1.name
  virtual_network_name = azurerm_virtual_network.SSPP.name
  address_prefix       = "20.0.4.0/24"
}

//Static Public IP for VPN G/W
resource "azurerm_public_ip" "vpngw" {
  name                = "vpnGatewayPublicIp"
  resource_group_name  = azurerm_resource_group.lab1.name
 // virtual_network_name = azurerm_virtual_network.SSPP.name
  location            =  azurerm_resource_group.lab1.location
  allocation_method   = "Dynamic"
}



//NSG creation
resource "azurerm_network_security_group" "rgdefault" {
   name = "NSG1"
   resource_group_name  = azurerm_resource_group.lab1.name
   location             = azurerm_resource_group.lab1.location
   tags                 = azurerm_resource_group.lab1.tags
}

//NSG single Inbound rule assocication for above NSG

resource "azurerm_network_security_rule" "AllowSSH" {
    name = "AllowSSH"
    resource_group_name         = azurerm_resource_group.lab1.name
    network_security_group_name = azurerm_network_security_group.rgdefault.name

    priority                    = 1010
    access                      = "Allow"
    direction                   = "Inbound"
    protocol                    = "Tcp"
    destination_port_range      = 22
    destination_address_prefix  = "*"
    source_port_range           = "*"
    source_address_prefix       = "*"
}

resource "azurerm_network_security_rule" "AllowRDP" {
    name = "AllowRDP"
    resource_group_name         = azurerm_resource_group.lab1.name
    network_security_group_name = azurerm_network_security_group.rgdefault.name

    priority                    = 1020
    access                      = "Allow"
    direction                   = "Inbound"
    protocol                    = "Tcp"
    destination_port_range      = 3389
    destination_address_prefix  = "*"
    source_port_range           = "*"
    source_address_prefix       = "*"
}

resource "azurerm_network_security_rule" "AllowHTTP" {
    name = "AllowHTTP_HTTPS"
    resource_group_name         = azurerm_resource_group.lab1.name
    network_security_group_name = azurerm_network_security_group.rgdefault.name

    priority                    = 1030
    access                      = "Allow"
    direction                   = "Inbound"
    protocol                    = "Tcp"
    destination_port_range      = 80
    destination_address_prefix  = "*"
    source_port_range           = "*"
    source_address_prefix       = "*"
}


resource "azurerm_network_security_rule" "AllowSQLServer" {
    name = "AllowSQLServer"
    resource_group_name         = azurerm_resource_group.lab1.name
    network_security_group_name = azurerm_network_security_group.rgdefault.name

    priority                    = 1040
    access                      = "Allow"
    direction                   = "Inbound"
    protocol                    = "Tcp"
    destination_port_range      = 1443
    destination_address_prefix  = "*"
    source_port_range           = "*"
    source_address_prefix       = "*"
}


//NSG with single rule implicated
resource "azurerm_network_security_group" "ubuntu" {
   name = "NIC_Ubuntu"
   resource_group_name  = azurerm_resource_group.lab1.name
   location             = azurerm_resource_group.lab1.location
   tags                 = azurerm_resource_group.lab1.tags

    security_rule {
        name                       = "SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = 22
        source_address_prefix      = "*"
        destination_address_prefix = "*"
  }
}
/*
resource "azurerm_subnet_network_security_group_association" "lab1" {
  subnet_id                 = azurerm_subnet.nsgapply.id
  network_security_group_id = azurerm_network_security_group.rgdefault.id
}

*/

//VPN Gateway creation
resource "azurerm_virtual_network_gateway" "vpngw" {
  name                = "vpnGateway"
  location            =  azurerm_resource_group.lab1.location
  resource_group_name  = azurerm_resource_group.lab1.name
  tags                =  azurerm_resource_group.lab1.tags
  type     = "Vpn"
  vpn_type = "RouteBased"
  active_active = false
  enable_bgp    = false
  sku           = "Basic"
  ip_configuration {
    name                          = "vpnGwConfig1"
    public_ip_address_id          = azurerm_public_ip.vpngw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw.id
  }
}

