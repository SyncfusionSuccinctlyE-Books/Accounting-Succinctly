/*
	Code: Accounting Succinctly from SyncFusion
	Purpose: Generate data tables
*/
IF Object_id('Journals') is not null
      DROP TABLE [dbo].Journals
GO    
IF Object_id('Chart_of_Accounts') is not null
      DROP TABLE [dbo].Chart_of_Accounts
GO

CREATE TABLE [dbo].Chart_of_Accounts
(
      ID          INT IDENTITY(1,1),
      AccountNum  VARCHAR(12) UNIQUE NOT NULL,
      Descrip     VARCHAR(48),
      AcctType    CHAR(1)     CHECK (AcctType in ('A','L','O','R','E')),
      Balance     MONEY,
      CONSTRAINT PK_Chart_of_Accounts PRIMARY KEY (ID)
)
CREATE TABLE [dbo].Journals
(
      ID          INT IDENTITY(1,1),      -- Unique key per line item
      AccountID   INT,  
      JrnlType    CHAR(2),		          -- GJ, AR, AP, SJ, PJ, etc
      TransNum    INT,		              -- Key to group entries together.  
      DC          CHAR(1)     CHECK (DC in ('D','C')),
	  Posted	  CHAR(1)	  DEFAULT 'N',
	  TransDate	  DATETIME	  DEFAULT GetDate(),
	  PostDate	  DATETIME,
      Amount      MONEY NOT NULL,
      CONSTRAINT PK_Journals PRIMARY KEY (ID),
      CONSTRAINT FK_Chart FOREIGN KEY (AccountID) REFERENCES Chart_of_Accounts(ID)
)
GO
