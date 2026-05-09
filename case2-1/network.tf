resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "takao-case2-1-vpc"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "takao-case2-1-igw"
    }
}

// ALB用パブリックサブネット
resource "aws_subnet" "public_1a" {
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = "ap-northeast-1d"

    tags = {
        Name = "takao-case2-1-public-1a"
    }
}

resource "aws_subnet" "public_1c" {
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = "10.0.2.0/24"
    availability_zone = "ap-northeast-1c"

    tags = {
        Name = "takao-case2-1-public-1c"
    }
}

// ECS Fargate用プライベートサブネット
resource "aws_subnet" "private_1a" {
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = "10.0.11.0/24"
    availability_zone = "ap-northeast-1d"

    tags = {
        Name = "takao-case2-1-private-1a"
    }
}

resource "aws_subnet" "private_1c" {
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = "10.0.12.0/24"
    availability_zone = "ap-northeast-1c"

    tags = {
        Name = "takao-case2-1-private-1c"
    }
}

// RDS用サブネット
resource "aws_subnet" "db_1a" {
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = "10.0.21.0/24"
    availability_zone = "ap-northeast-1d"

    tags = {
        Name = "takao-case2-1-db-1a"
    }
}

resource "aws_subnet" "db_1c" {
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = "10.0.22.0/24"
    availability_zone = "ap-northeast-1c"

    tags = {
        Name = "takao-case2-1-db-1c"
    }
}

resource "aws_eip" "nat" {
    domain = "vpc"

    tags = {
        Name = "takao-case2-1-nat-eip"
    }
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.public_1a.id

    tags = {
        Name = "takao-case2-1-nat"
    }

    depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "takao-case2-1-public-rt"
    }
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }

    tags = {
        Name = "takao-case2-1-private-rt"
    }
}

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
