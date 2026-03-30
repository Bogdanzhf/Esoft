SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetLocale] (
  @IDBase int, 
  @IDPlace int, 
  @Phone varchar(30)
) 
RETURNS nvarchar(15)
AS
BEGIN
  DECLARE @Locale nvarchar(15)
  DECLARE @IDOrg int
  DECLARE @IDLang int

  -- Основная логика выбора способа определения локали
  IF @IDBase IS NOT NULL AND @Phone IS NOT NULL
  BEGIN
    -- Определяем локаль по базе и телефону (логика из GetClientLocale)
    SELECT @IDOrg = ID_ORGANIZATION 
    FROM dbo.T_BASES 
    WHERE ID = @IDBase

    SELECT @IDLang = ID_LANG_NATIVE 
    FROM dbo.T_PHONES 
    WHERE C_PHONE = @Phone AND ID_ORGANIZATION = @IDOrg

    SELECT @Locale = C_CODE 
    FROM dbo.T_LANGUAGES 
    WHERE ID = @IDLang AND C_IVR_AVAILABLE = 1
  END

  -- Если локаль еще не определена, пробуем другие способы
  IF @Locale IS NULL AND @IDPlace IS NOT NULL
  BEGIN
    -- Определяем локаль по населенному пункту через JOIN
    SELECT @Locale = l.C_CODE 
    FROM T_PLACE p 
    LEFT JOIN T_COUNTRY c ON c.ID = p.ID_COUNTRY
    LEFT JOIN T_LANGUAGES l ON l.ID = c.ID_LANGUAGE
    WHERE p.ID = @IDPlace
  END

  -- Если все еще не определена, используем базовую логику
  IF @Locale IS NULL
  BEGIN
    SET @Locale = dbo.GetBaseLocale(ISNULL(@IDBase, 1))
  END

  RETURN @Locale
END
GO