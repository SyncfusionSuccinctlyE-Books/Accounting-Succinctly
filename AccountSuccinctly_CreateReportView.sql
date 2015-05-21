/*
	Code: Accounting Succinctly from SyncFusion
	Purpose: Reports
*/

IF Object_id('BalanceSheet') is not null
      DROP VIEW [dbo].BalanceSheet
GO

-- Balance sheet
CREATE VIEW [dbo].BalanceSheet 
AS
	SELECT AccountNum,Descrip,Balance FROM [dbo].Chart_of_Accounts WHERE AcctType='A'
	UNION 
	SELECT '1900','TOTAL ASSETS',Sum(Balance) FROM [dbo].Chart_of_Accounts WHERE AcctType='A'
	UNION
	SELECT AccountNum,Descrip,Balance FROM [dbo].Chart_of_Accounts WHERE AcctType='L'
	UNION 
	SELECT '2900','TOTAL LIABILITIES',Sum(Balance) FROM [dbo].Chart_of_Accounts WHERE AcctType='L'
	UNION
	SELECT AccountNum,Descrip,Balance FROM [dbo].Chart_of_Accounts WHERE AcctType='O'
	UNION 
	SELECT '3900','TOTAL EQUITY',Sum(Balance) FROM [dbo].Chart_of_Accounts WHERE AcctType='O'
	UNION 
	SELECT '3999','TOTAL LIABILITIES and EQUITY',Sum(Balance) FROM [dbo].Chart_of_Accounts WHERE AcctType IN ('L','O')

GO
IF Object_id('IncomeStatement') is not null
      DROP VIEW [dbo].IncomeStatement
GO
CREATE VIEW [dbo].IncomeStatement 
AS
	SELECT 4000 as Seq,'REVENUE' as 'Account Name',IsNull(Sum(jl.Amount),0) as Balance
	FROM [dbo].Journals jl
	JOIN [dbo].Chart_of_Accounts ca on ca.id=jl.AccountId
	WHERE jl.posted='N' and ca.AcctType='R'
	UNION
	SELECT ca.AccountNum,descrip,IsNull(Sum(jl.Amount),0) as Balance
	FROM [dbo].Journals jl
	JOIN [dbo].Chart_of_Accounts ca on ca.id=jl.AccountId
	WHERE jl.posted='N' and ca.AcctType='E'
	GROUP BY ca.descrip,ca.AccountNum
	UNION
	SELECT '9999','NET INCOME(loss)',xx.Balance
	FROM  (
			SELECT IsNull(
				Sum(CASE when jl.dc='D' then -1*jl.amount else jl.amount end),0 ) as Balance
			FROM [dbo].Journals jl
			JOIN [dbo].Chart_of_Accounts ca on ca.id=jl.AccountId AND jl.posted='N' and (ca.AcctType IN ('R','E'))
		) xx

GO
SELECT * FROM BalanceSheet
select * from IncomeStatement ORDER BY Seq
