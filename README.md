# Joel Bieber Data Migration
Conversion project template.

Databases
DYLANS\MSSQLSERVER2022.JoelBieberNeedles
DYLANS\MSSQLSERVER2022.JoelBieberGrowPath
DYLANS\MSSQLSERVER2022.JoelBieberSA

Working Directory: D:\Needles-JoelBieber

# Connection Info
https://sc.bastionpoint.com/Login?Reason=0

## ConnectWise
Username: `Joel Bieber Smart Advocate`  (Spaces included)
Password: `m!ex#fak-qUqh%yw-0wysje#`
2FA sent to Jose@smartadvocate.com

## Windows
`JOELBIEBER\SMARTADVOCATE`
`T=[f,YjP6l=GjDPf}$2l>gWQ[49{s8D8`

## PostgreSQL
pw = `SASuper`

## SQL
server: JBF-SmartAdvocate
`sa`
`T=[f,YjP6l=GjDPf}$2l>gWQ[49{s8D8`


```sql
USE [SA]
GO

INSERT INTO sma_mst_tenants (
    HostName,
    ConnectingString,
    LicenseCount,
    ReadOnlyLicenseCount,
    ExpirationDate,
    IsActive,
    HostNameAlias
)
VALUES (
    'SATenantNeedles',
    'Data Source=JBF-SMARTADVOCA;Initial Catalog=SATenantNeedles;User Id =sa; Password=T=[f,YjP6l=GjDPf}$2l>gWQ[49{s8D8; Connection Timeout=10000',
    242,
    0,
    '2100-01-01 00:00:00.000',
    1,
    'SATenantNeedles.com'
)
```


![alt text](image.png)