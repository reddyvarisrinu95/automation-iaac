variable  "pub_cidr" {
  type    = list
  default = ["10.1.0.0/24" ,"10.1.1.0/24" ,"10.1.2.0/24"]
}  



variable  "private_cidr" {
  type    = list
  default = ["10.1.3.0/24" ,"10.1.4.0/24" ,"10.1.5.0/24"]
}  




variable  "data_cidr" {
  type    = list
  default = ["10.1.6.0/24" ,"10.1.7.0/24" ,"10.1.8.0/24"]
}  