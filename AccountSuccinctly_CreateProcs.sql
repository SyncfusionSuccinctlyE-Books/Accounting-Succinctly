/*
	Code: Accounting Succinctly from SyncFusion
	Purpose: Journal processing stored procedures
*/

IF Object_id('AddTransaction') is not null
      DROP PROCEDURE [dbo].AddTransaction
GO
CREATE PROCEDURE  [dbo].AddTransaction
( 
	@AcctList VARCHAR(1000),	-- Comma Separated: Format is AcctNum|D or C|Amount,
	@JrnlType CHAR(2) ='GJ'
 )
 AS
 BEGIN
	SET NOCOUNT ON
	-- Split the parameter into a table
	DECLARE @TransTable TABLE (AccoutNum VARCHAR(12),ID INT,DC CHAR(1),amt MONEY)
	INSERT INTO @TransTable
		SELECT * FROM [dbo].TransToTable(@AcctList)
	-- Validate all accounts, return -1 if any invalid accounts
	DECLARE @nCtr INT

	SELECT @nCtr = COUNT(*) FROM @TransTable WHERE ID <0
	IF (@nCtr >0 )
	BEGIN
		-- Optionally, could raise an error
		PRINT 'Missing account numbers'
		RETURN -1
	END

	-- Validate Debits = Credits, return -2 if not
	DECLARE @DebitTot MONEY
	DECLARE @CreditTot MONEY

	SELECT @DebitTot = SUM(amt) FROM @TransTable WHERE DC='D'
	SELECT @CreditTot = SUM(amt) FROM @TransTable WHERE DC='C'
	IF (@DebitTot <> @CreditTot )
	BEGIN
		-- Optionally, could raise an error
		PRINT 'Debits <> Credits'
		RETURN -2
	END
	-- Post the transaction into journals
	BEGIN TRANSACTION
		DECLARE @nNext INT
		SELECT @nNext = IsNull(max(transNum)+1,1) FROM  [dbo].Journals WHERE jrnlType=@JrnlType

		INSERT INTO [dbo].Journals (AccountID,JrnlType,TransNum,DC,Amount)
		SELECT ID,@JrnlType,@nNext,DC,amt
		FROM @TransTable
	COMMIT
	RETURN 0

 END
 GO

 IF Object_id('TransToTable') is not null
      DROP FUNCTION [dbo].TransToTable
GO

 CREATE Function [dbo].TransToTable 
 (@AcctList VARCHAR(1000) )
  RETURNS 
	@RowTable TABLE
		(	AcctNumber VARCHAR(12),
			Jrnl_Account_ID INT,
            DebitCredit CHAR(1),
		    Amt MONEY
    )
AS
BEGIN

	DECLARE @X INT
	DECLARE @Y INT
	DECLARE @OneLine VARCHAR(30)
	DECLARE @acctNUM VARCHAR(12)
	DECLARE @DebCred CHAR(1)
	DECLARE @TransAmt MONEY
	SET @AcctList=@AcctList+','

	SET @x = CHARINDEX(',',@AcctList)
	WHILE @x >0
	BEGIN
		SET @OneLine =  LEFT(@AcctList,@x-1)
		SET @AcctList = RTRIM(SUBSTRING(@AcctList,@x+1,9999))
		if LEN(@OneLine) > 0
		begin
			SET @Y = CHARINDEX('|',@OneLine)
			SET @AcctNum = LEFT(@OneLine,@y-1)
			SET @DebCred = SUBSTRING(@OneLine,@y+1,1)
			SET @OneLine = RTRIM(SUBSTRING(@OneLine,@y+3,9999))
			SET @TransAmt = CAST(@OneLine AS MONEY)
			INSERT INTO @RowTable VALUES (@AcctNum,-1,@DebCred,@TransAmt)
		end
		UPDATE @rowTable SET Jrnl_Account_ID = xx.id
		FROM (select id,accountNum FROM [dbo].chart_of_accounts) xx
		WHERE xx.accountNum=AcctNumber
		SET @x = CHARINDEX(',',@AcctList)
	END
	RETURN 
END
GO

IF Object_id('PostTransaction') is not null
      DROP PROCEDURE [dbo].PostTransaction
GO
CREATE PROCEDURE  [dbo].PostTransaction( @TransNumb INT = 0 )
 AS
 BEGIN
	SET NOCOUNT ON
	UPDATE [dbo].Chart_of_Accounts SET Balance = Balance +xx.PostAmt
	FROM
	(
		SELECT AccountID,
		 Sum(
		 CASE WHEN jl.dc='D' THEN amount ELSE -1*amount END
		 ) as PostAmt
		FROM [dbo].Journals jl
		JOIN [dbo].Chart_of_Accounts ca on jl.AccountID=ca.id
		WHERE jl.posted='N' AND (Transnum = @TransNumb or @TransNumb=0) AND ca.AcctType in ('A','E')
		GROUP BY AccountID
	) xx
	WHERE xx.accountID=ID

	UPDATE [dbo].Chart_of_Accounts SET Balance = Balance +xx.PostAmt
	FROM
	(
		SELECT AccountID,
		 Sum(
		 CASE WHEN jl.dc='C' THEN amount ELSE -1*amount END
		 ) as PostAmt
		FROM [dbo].Journals jl
		JOIN [dbo].Chart_of_Accounts ca on jl.AccountID=ca.id
		WHERE jl.posted='N' AND (Transnum = @TransNumb or @TransNumb=0) AND ca.AcctType in ('L','O','R')
		GROUP BY AccountID
	) xx
	WHERE xx.accountID=ID
	UPDATE [dbo].Journals SET posted='Y',PostDate=getDate() WHERE posted='N' AND (Transnum = @TransNumb or @TransNumb=0) 
 END
 GO
 
 IF Object_id('ClosingEntry') is not null
      DROP PROCEDURE [dbo].ClosingEntry
GO
