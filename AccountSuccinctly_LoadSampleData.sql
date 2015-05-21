/*
	Code: Accounting Succinctly from SyncFusion
	Purpose: Load data for chart of accounts and transactions
*/
SET NOCOUNT ON
TRUNCATE TABLE [dbo].Journals
DELETE FROM Chart_of_Accounts
DBCC CHECKIDENT ('Chart_of_Accounts', RESEED, 0)

-- Add Balance sheet accounts (Chapter one)
INSERT INTO [dbo].Chart_of_Accounts (AccountNum,Descrip,AcctType,Balance)
VALUES
('1000','Cash-Checking Account','A',0),
('1100','Software','A',0),
('1200','Subscriptions','A',0),
('1600','Computer System','A',0),
('2000','Loan For Computer','L',0),
('3000','Owner Equity','O',0),
('3100','Retained Earnings','O',0)
-- Add Income statement accounts (Chapter two)
INSERT INTO [dbo].Chart_of_Accounts (AccountNum,Descrip,AcctType,Balance)
VALUES
('4000','Sales Revenue','R',0),
('5000','Rent Expense','E',0),
('5100','Postage Expense','E',0),
('5200','Shipping Supplies Expense','E',0),
('5300','Office Supplies Expense','E',0)
GO
--Journal Entries
-- Chapter one

EXEC [dbo].AddTransaction '1000|D|10000,3000|C|10000','GJ'		    
EXEC [dbo].AddTransaction '1600|D|6000,1000|C|1000,2000|C|5000','GJ'
EXEC [dbo].AddTransaction '1100|D|794,1200|D|99,1000|C|893','GJ'	
EXEC [dbo].AddTransaction '1000|C|1000,2000|D|1000','GJ'			
GO
EXEC [dbo].PostTransaction

-- Chapter two
EXEC [dbo].AddTransaction '1000|D|250,4000|C|250','GJ'		    
EXEC [dbo].AddTransaction '1000|D|595,4000|C|595','GJ'		    
EXEC [dbo].AddTransaction '5300|D|75,1000|C|75','GJ'		    
EXEC [dbo].AddTransaction '4000|C|400,1000|D|360,5100|D|12,5200|D|28','GJ'		    
EXEC [dbo].AddTransaction '5000|D|600,1000|C|600','GJ'		    

GO
