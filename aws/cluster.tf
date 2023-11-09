resource "aws_security_group" "sg" {
    vpc_id = aws_vpc.new-vpc.id
    tags = {
        Name = "${var.prefix}-sg"
    }
    /*
     Tudo que está dentro do security group tem acesso a tudo que está fora
     Cluster tem acesso irrestrito à internet pública
     Todo o tráfego em todo protocolo em todas as portas, independentemente do destino
     podem ter acesso
    */
    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
}