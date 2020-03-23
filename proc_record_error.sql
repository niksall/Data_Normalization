CREATE PROCEDURE [pk5].[err_models_all]
	@user NVARCHAR(250) = N'Management Studio - sa'
	,@only_not_transfered_to_sap bit = 1 -- 0 - all_object; 1 - only only non-transferred to SAP
AS
BEGIN

DECLARE @status_id INT, @inprogress BIT, @lastupdate DATETIME
	DECLARE @starttime DATETIME = GETDATE()
    --status init
	EXEC pk5.err_fix_status_progress @status_id OUT, 0, @lastupdate OUT, 0, 0, 0, NULL, @inprogress OUT, @starttime, NULL, N'pk5.err_models_all'
	IF @inprogress=1
    BEGIN
        RETURN 0
    END

	DECLARE @total INT = 0, @i INT = 0, @proc INT, @status NVARCHAR(255)
    DECLARE @cancel BIT
	SELECT @total = COUNT(*)
	  FROM dbo.models m
     WHERE m.deleted IS NULL

	--status populate
	EXEC pk5.err_fix_status_progress @status_id, 0, NULL, 0, 0, @total, N'обрабатывается', 0, NULL, @user

	DECLARE @id INT

    DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
    SELECT m.id
      FROM dbo.models m
     WHERE m.deleted IS NULL

    OPEN cur

    FETCH NEXT FROM cur
    INTO @id

    WHILE @@FETCH_STATUS = 0
    BEGIN
		SET @i = @i + 1
		SET @proc = @i*100/@total
		SET @status = CONCAT(N'обрабатывается: ', @i, N' из ', @total)
		--status progress
		EXEC pk5.err_fix_status_progress @status_id, @cancel OUT, @lastupdate OUT, @proc, @i, @total, @status 
        IF (@cancel = 1)
		BEGIN
			SET @proc = @i*100/@total
			--status complete
		    EXEC pk5.err_fix_status_complete @status_id, @proc, @i, @total, N'остановлено пользователем'
			RETURN 0;
		END
		
		--EXEC pk5.err_models @id 
		EXEC pk5.err_model_id_0 @id
		EXEC pk5.err_model_descr_0 @id
		EXEC pk5.err_model_code_0 @id
		EXEC pk5.err_model_descr_1 @id
 
        FETCH NEXT FROM cur
         INTO @id
    END

    CLOSE cur
    DEALLOCATE cur

	EXEC pk5.err_fix_status_complete @status_id, 100, @total, @total, N'завершено'

END
