--CodeCoverage[Functions/dbo.GetBaseLocale]
EXEC tSQLt.NewTestClass 'GetBaseLocale'
GO

-----------
CREATE PROC GetBaseLocale.Test_01_NULL_IDBase_should_use_default_value_1
AS
BEGIN
  -- Проверяем, что при входящем id_base = NULL работает как при параметре id_base = 1
  DECLARE @Expected nvarchar(15);
  SELECT @Expected = dbo.GetBaseLocale(1);
  
  DECLARE @Result nvarchar(15);
  SELECT @Result = dbo.GetBaseLocale(NULL);
  
  EXEC tSQLt.AssertEquals @Expected, @Result, 
    'Проверяем результат функции';
END
GO

-----------
CREATE PROC GetBaseLocale.Test_02_returns_locale_for_base_1
AS
BEGIN
  -- Проверяем результат функции для входящего id_base = 1
  DECLARE @Expected nvarchar(15) = 'ru';
  DECLARE @Result nvarchar(15);
  
  SELECT @Result = dbo.GetBaseLocale(1);
  
  EXEC tSQLt.AssertEquals @Expected, @Result, 
    'Проверяем результат функции';
END
GO

-----------
CREATE PROC GetBaseLocale.Test_03_base_not_found_returns_NULL
AS
BEGIN
  -- Проверяем, что для несуществующей базы возвращается NULL
  DECLARE @Result nvarchar(15);
  SELECT @Result = dbo.GetBaseLocale(-1);
  
  EXEC tSQLt.AssertEquals NULL, @Result, 
    'Проверяем результат функции';
END
GO

-----------
CREATE PROC GetBaseLocale.Test_04_place_without_country_returns_NULL
AS
BEGIN
  -- Проверяем, что для населенного пункта без страны возвращается NULL
  -- Используем существующую базу с ID = 1 и временно убираем страну у ее населенного пункта (ID = 1)
  DECLARE @SavedCountryID int;
  SELECT @SavedCountryID = ID_COUNTRY FROM T_PLACE WHERE ID = 1;
  
  -- Временно убираем страну у населенного пункта
  UPDATE T_PLACE SET ID_COUNTRY = NULL WHERE ID = 1;
  
  DECLARE @Result nvarchar(15);
  SELECT @Result = dbo.GetBaseLocale(1);
  
  EXEC tSQLt.AssertEquals NULL, @Result, 
    'Проверяем результат функции';
END
GO

-----------
CREATE PROC GetBaseLocale.Test_05_returns_different_locale_for_changed_language
AS
BEGIN
  -- Проверяем результат функции для входящего id_base = 5051 при смене языка страны
  -- Меняем язык для России (ID=1) на английский (ID=2)
  UPDATE T_COUNTRY SET ID_LANGUAGE = 2 WHERE ID = 1;

  DECLARE @Expected nvarchar(15) = 'en';
  DECLARE @Result nvarchar(15);
  
  SELECT @Result = dbo.GetBaseLocale(5051);
  
  EXEC tSQLt.AssertEquals @Expected, @Result, 
    'Проверяем результат функции';
END
GO