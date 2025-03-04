USE RiskManagementDB;
GO

CREATE TABLE Trades (
    TradeID INT IDENTITY(1,1) PRIMARY KEY,
    ProductType VARCHAR(20),
    Notional DECIMAL(18,2),
    Currency VARCHAR(10),
    FixedRate DECIMAL(5,2),
    AgreedRate DECIMAL(10,4),
    MaturityDate DATE
);

CREATE TABLE MarketData (
    TradeDate DATE PRIMARY KEY,
    ShortTermRate DECIMAL(5,2),
    LongTermRate DECIMAL(5,2),
    SpotExchangeRate DECIMAL(10,4)
);
