resource "aws_vpc" "new-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

data "aws_availability_zones" "available" {}

// Criação dinâmica de subnets
resource "aws_subnet" "subnets" {
    count = 2
    availability_zone = data.aws_availability_zones.available.names[count.index] // Vai pegar 1a e 1b
    vpc_id = aws_vpc.new-vpc.id // ID do resource "new-vpc" da linha 1
    cidr_block = "10.0.${count.index}.0/24" # Usar calculadora de subnets
    map_public_ip_on_launch = true // Toda subnet já terá um IP público gerado
    tags = {
        Name = "${var.prefix}-subnet-${count.index}"
    }
}

resource "aws_internet_gateway" "new-igw" {
    vpc_id = aws_vpc.new-vpc.id
    tags = {
        Name = "${var.prefix}-igw"
    }
}

resource "aws_route_table" "new-rtb" {
    vpc_id = aws_vpc.new-vpc.id
    route {
        cidr_block = "0.0.0.0/0" // Todo mundo pode acessar
        gateway_id = aws_internet_gateway.new-igw.id # Atachando route table no IGW acima
    }
    tags = {
        Name = "${var.prefix}-igw"
    }
}

resource "aws_route_table_association" "new-rtb-association" {
    count = 2
    route_table_id = aws_route_table.new-rtb.id
    # subnet_id = aws_subnet.subnets[count.index].id // Não entendi pq essa sintaxe não funcionaria
    subnet_id = aws_subnet.subnets.*.id[count.index]
}