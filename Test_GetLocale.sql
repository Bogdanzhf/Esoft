--CodeCoverage[Functions/dbo.GetLocale]
EXEC tSQLt.NewTestClass 'GetLocale'
GO

-----------
-- Создаем fake функцию для GetBaseLocale
CREATE FUNCTION GetLocale.Fake_GetBaseLocale(@IDBase int)
RETURNS nvarchar(15)
AS
BEGIN
  -- Возвращаем фиксированные значения для тестирования
  IF @IDBase = 1
    RETURN 'ru'
  ELSE IF @IDBase = 2
    RETURN 'en'
  ELSE
    RETURN NULL
END
GO

-----------
CREATE PROC GetLocale.Test_01_IDBase_and_Phone_should_return_expected_locale
AS
BEGIN
  -- Проверяем, что при входящих id_base = 1 и phone = '+79991234567' возвращается ожидаемая локаль 'en'
  EXEC tSQLt.SpyFunction 'dbo.GetBaseLocale', 'GetLocale.Fake_GetBaseLocale'
  
  -- Настраиваем данные для возврата 'en' через логику телефона
  DECLARE @SavedLanguageID int;
  SELECT @SavedLanguageID = ID_LANGUAGE FROM T_COUNTRY WHERE ID = 1;
  
  UPDATE T_COUNTRY SET ID_LANGUAGE = 2 WHERE ID = 1; -- Меняем язык России на английский

  DECLARE @Expected nvarchar(15) = 'en';
  DECLARE @Result nvarchar(15);
  SELECT @Result = dbo.GetLocale(1, NULL, '+79991234567');
  
  EXEC tSQLt.AssertEquals @Expected, @Result, 
    'Проверяем результат функции';
END
GO

-----------
CREATE PROC GetLocale.Test_02_only_IDPlace_should_return_expected_locale
AS
BEGIN
  -- Проверяем, что при входящем id_place = 1 возвращается ожидаемая локаль 'ru'
  EXEC tSQLt.SpyFunction 'dbo.GetBaseLocale', 'GetLocale.Fake_GetBaseLocale'
  
  DECLARE @Expected nvarchar(15) = 'ru';
  DECLARE @Result nvarchar(15);
  SELECT @Result = dbo.GetLocale(NULL, 1, NULL);
  
  EXEC tSQLt.AssertEquals @Expected, @Result, 
    'Проверяем результат функции';
END
GO

-----------
CREATE PROC GetLocale.Test_03_only_IDBase_should_use_base_logic
AS
BEGIN
  -- Проверяем, что при входящем id_base = 1 результат совпадает с GetBaseLocale(1)
  EXEC tSQLt.SpyFunction 'dbo.GetBaseLocale', 'GetLocale.Fake_GetBaseLocale'
  
  DECLARE @Expected nvarchar(15) = 'ru';
  DECLARE @Result nvarchar(15);
  SELECT @Result = dbo.GetLocale(1, NULL, NULL);
  
  EXEC tSQLt.AssertEquals @Expected, @Result, 
    'Проверяем результат функции';
END
GO

-----------
CREATE PROC GetLocale.Test_04_no_parameters_should_use_default_base
AS
BEGIN
  -- Проверяем, что при отсутствии параметров используется id_base = 1
  EXEC tSQLt.SpyFunction 'dbo.GetBaseLocale', 'GetLocale.Fake_GetBaseLocale'
  
  DECLARE @Expected nvarchar(15) = 'ru';
  DECLARE @Result nvarchar(15);
  SELECT @Result = dbo.GetLocale(NULL, NULL, NULL);
  
  EXEC tSQLt.AssertEquals @Expected, @Result, 
    'Проверяем результат функции';
END
GO

-----------
CREATE PROC GetLocale.Test_05_priority_IDBase_Phone_over_IDPlace
AS
BEGIN
  -- Проверяем приоритет id_base и phone над id_place - получаем 'en' а не 'ru'
  EXEC tSQLt.SpyFunction 'dbo.GetBaseLocale', 'GetLocale.Fake_GetBaseLocale'
  
  -- Настраиваем данные для возврата 'en' через логику телефона
  DECLARE @SavedLanguageID int;
  SELECT @SavedLanguageID = ID_LANGUAGE FROM T_COUNTRY WHERE ID = 1;
  
  UPDATE T_COUNTRY SET ID_LANGUAGE = 2 WHERE ID = 1; -- Английский для логики базы+телефона
  
  DECLARE @Expected nvarchar(15) = 'en';
  DECLARE @Result nvarchar(15);
  SELECT @Result = dbo.GetLocale(1, 1, '+79991234567');
  
  EXEC tSQLt.AssertEquals @Expected, @Result, 
    'Проверяем результат функции';
END
GO

-----------
CREATE PROC GetLocale.Test_06_phone_with_IDPlace_should_use_place_logic
AS
BEGIN
  -- Проверяем, что при phone и id_place (без id_base) используется логика места
  EXEC tSQLt.SpyFunction 'dbo.GetBaseLocale', 'GetLocale.Fake_GetBaseLocale'
  
  DECLARE @Expected nvarchar(15) = 'ru';
  DECLARE @Result nvarchar(15);
  SELECT @Result = dbo.GetLocale(NULL, 1, '+79991234567');
  
  EXEC tSQLt.AssertEquals @Expected, @Result, 
    'Проверяем результат функции';
END
GO

-----------
CREATE PROC GetLocale.Test_07_phone_without_IDBase_should_use_default
AS
BEGIN
  -- Проверяем, что при phone без id_base и id_place используется значение по умолчанию
  EXEC tSQLt.SpyFunction 'dbo.GetBaseLocale', 'GetLocale.Fake_GetBaseLocale'
  
  DECLARE @Expected nvarchar(15) = 'ru';
  DECLARE @Result nvarchar(15);
  SELECT @Result = dbo.GetLocale(NULL, NULL, '+79991234567');
  
  EXEC tSQLt.AssertEquals @Expected, @Result, 
    'Проверяем результат функции';
END
GO