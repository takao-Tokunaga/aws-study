resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "takao-case2-vpc"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "takao-igw2"
    }
}
//  ALB
resource "aws_subnet" "public_1a" {
    vpc_id             = aws_vpc.vpc.id
    cidr_block         = "10.0.1.0/24"
    availability_zone  = "ap-northeast-1d"

    tags = {
        Name = "takao-case2-public-1a"
    }
}

resource "aws_subnet" "public_1c" {
    vpc_id             = aws_vpc.vpc.id
    cidr_block         = "10.0.2.0/24"
    availability_zone  = "ap-northeast-1c"

    tags = {
        Name = "takao-case2-public-1c"
    }
}

// EC2
resource "aws_subnet" "private_1a" {
    vpc_id             = aws_vpc.vpc.id
    cidr_block         = "10.0.11.0/24"
    availability_zone  = "ap-northeast-1d"

    tags = {
        Name = "takao-case2-private-1a"
    }
}

resource "aws_subnet" "private_1c" {
    vpc_id             = aws_vpc.vpc.id
    cidr_block         = "10.0.12.0/24"
    availability_zone  = "ap-northeast-1c"

    tags = {
        Name = "takao-case2-private-1c"
    }
}

// RDS
resource "aws_subnet" "db_1a" {
    vpc_id             = aws_vpc.vpc.id
    cidr_block         = "10.0.21.0/24"
    availability_zone  = "ap-northeast-1d"

    tags = {
        Name = "takao-case2-db-1a"
    }
}

resource "aws_subnet" "db_1c" {
    vpc_id             = aws_vpc.vpc.id
    cidr_block         = "10.0.22.0/24"
    availability_zone  = "ap-northeast-1c"

    tags = {
        Name = "takao-case2-db-1c"
    }
}

// NAT用のIPアドレス
resource "aws_eip" "nat" {
    domain = "vpc"

    tags = {
        Name = "takao-case2-nat-eip"
    }
}

// EIPをパブサブに配置
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.public_1a.id

    tags = {
        Name = "takao-case2-nat"
    }

    depends_on = [aws_internet_gateway.igw]
}

// パブリック用ルートテーブル
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "takao-case2-public-rt"
    }
}

// プライベート用ルートテーブル
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }

    tags = {
        Name = "takao-case2-private-rt"
    }
}

// サブネットと関連付け
resource "aws_route_table_association" "public_1a" {
    subnet_id      = aws_subnet.public_1a.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
    subnet_id      = aws_subnet.public_1c.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1a" {
    subnet_id      = aws_subnet.private_1a.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_1c" {
    subnet_id      = aws_subnet.private_1c.id
    route_table_id = aws_route_table.private.id
}





