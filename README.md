# tfm_air_quality_infrastructure
Infrastructure as Code

![PyPI - Python Version](https://img.shields.io/pypi/pyversions/Pandas)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/FelixAngelMartinez/tfm_air_quality_infrastructure)
![GitHub last commit](https://img.shields.io/github/last-commit/FelixAngelMartinez/tfm_air_quality_infrastructure)
![GitHub all releases](https://img.shields.io/github/downloads/FelixAngelMartinez/test_1/tfm_air_quality_infrastructure)
![GitHub issues](https://img.shields.io/github/issues-raw/FelixAngelMartinez/tfm_air_quality_infrastructure)
![GitHub contributors](https://img.shields.io/github/contributors/FelixAngelMartinez/tfm_air_quality_infrastructure)
![GitHub followers](https://img.shields.io/github/followers/FelixAngelMartinez?style=social)

## Description
Repository belonging to the development of the Master Thesis entitled "Intelligent system for monitoring indoor air quality and fight against COVID-19", which develops a system to monitor air quality in enclosed spaces using IoT devices and Machine Learning algorithms. All this developed with a Cloud approach.

This Master's Thesis has been developed within the framework of the "Master in Computer Engineering" of the University of Castilla la Mancha.

## Repository elements
In this repository there is 1 folders:
* **iac/**: in this directory we find the code written in .yml to run with Terraform.

## Requirements
It is mandatory to have already installed [Terraform](https://www.terraform.io/)

## Commands
Before to lauch the comands it is important to login in Azure via console.
```console
  $az login
```
```console
  $terraform init
```
Once it is already sign in, you can launch the following commands:
```console
  $terraform fmt
  $terraform validate
  $terraform plan -out plan.tfplan
  $terraform apply --auto-approve
  $terraform destroy --auto-approve
```
## Dependences
```console
  $terraform graph
```
## Destroy infrastructure
```console
  $terraform destroy --auto-approve
```
## Master's thesis
The report of the project will be published in the university repository.
[UCLM Repository](https://ruidera.uclm.es/)

## License:
Project under license [LICENSE](LICENSE)

---
_Project carried out by:_
* **Félix Ángel Martínez Muela** - [Félix Ángel Martínez](https://github.com/FelixAngelMartinez)