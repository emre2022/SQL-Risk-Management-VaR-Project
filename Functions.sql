USE RiskManagementDB;
GO

CREATE FUNCTION dbo.FN_Value_IRS
(
    @TradeID INT,
    @TradeDate DATE
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Notional DECIMAL(18,2),
            @FixedRate DECIMAL(5,2),
            @MarketRate DECIMAL(5,2),
            @PV DECIMAL(18,2);

    SELECT @Notional = Notional,
           @FixedRate = FixedRate
    FROM Trades
    WHERE TradeID = @TradeID AND ProductType = 'IRS';

    SELECT @MarketRate = ShortTermRate
    FROM MarketData
    WHERE TradeDate = @TradeDate;

    DECLARE @Days INT = DATEDIFF(DAY, @TradeDate, (SELECT MaturityDate FROM Trades WHERE TradeID = @TradeID));
    SET @PV = @Notional * ((@FixedRate - @MarketRate) / 100.0) * (@Days / 365.0);

    RETURN @PV;
END;
GO

CREATE FUNCTION dbo.FN_Value_FXFWD
(
    @TradeID INT,
    @TradeDate DATE
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Notional DECIMAL(18,2),
            @AgreedRate DECIMAL(10,4),
            @SpotRate DECIMAL(10,4),
            @PV DECIMAL(18,2);

    SELECT @Notional = Notional,
           @AgreedRate = AgreedRate
    FROM Trades
    WHERE TradeID = @TradeID AND ProductType = 'FXFWD';

    SELECT @SpotRate = SpotExchangeRate
    FROM MarketData
    WHERE TradeDate = @TradeDate;

    SET @PV = @Notional * (@AgreedRate - @SpotRate);

    RETURN @PV;
END;
GO

CREATE PROCEDURE sp_CalculatePV
    @TradeID INT,
    @TradeDate DATE,
    @PV DECIMAL(18,2) OUTPUT
AS
BEGIN
    DECLARE @ProductType VARCHAR(20);
    SELECT @ProductType = ProductType FROM Trades WHERE TradeID = @TradeID;

    IF @ProductType = 'IRS'
        SET @PV = dbo.FN_Value_IRS(@TradeID, @TradeDate);
    ELSE IF @ProductType = 'FXFWD'
        SET @PV = dbo.FN_Value_FXFWD(@TradeID, @TradeDate);
    ELSE
        SET @PV = 0;
END;
GO
