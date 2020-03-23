CREATE PROCEDURE [pk5].[err_models] @id INT
AS
BEGIN

	--Checking for models without brands.
	INSERT INTO pk5.error (row_id, col, error, tbl, error_type, deleted, qty_code)
	SELECT DISTINCT m.id, '', '', 'dbo.models', null, NULL, 153
	FROM dbo.models m
		LEFT JOIN (SELECT mm.id, mm.model_id FROM dbo.models_marks mm WHERE mm.deleted IS NULL) mm ON mm.model_id = m.id
		WHERE mm.id IS NULL AND m.deleted IS NULL AND m.id = @id
		GROUP BY m.site_code, m.id

	--Checking the availability of models with the same name (with different classes).
	INSERT INTO pk5.error (row_id, col, error, tbl, error_type, deleted, qty_code)
	SELECT DISTINCT m.id, '', '', 'dbo.models', null, NULL, 155
	FROM dbo.models m JOIN 
	(
		SELECT m.site_code, m.descr
		FROM dbo.models m
			WHERE m.deleted IS NULL
			GROUP BY m.site_code, m.descr
			HAVING COUNT(DISTINCT m.class) > 1
	) AS d_m ON d_m.site_code = m.site_code AND d_m.descr = m.descr
	WHERE m.deleted IS NULL AND m.id = @id

	--Checking for models with the same code (with different names or classes).
	INSERT INTO pk5.error (row_id, col, error, tbl, error_type, deleted, qty_code)
	SELECT DISTINCT m.id, '', '', 'dbo.models', null, NULL, 156
	FROM dbo.models m JOIN 
	(
		SELECT m.site_code, m.code
		FROM dbo.models m
			WHERE m.deleted IS NULL
			GROUP BY m.site_code, m.code
			HAVING (COUNT(DISTINCT m.class) > 1 OR COUNT(DISTINCT m.descr) > 1)
	) AS d_m ON d_m.site_code = m.site_code AND d_m.code = m.code
	WHERE m.deleted IS NULL AND m.id = @id

	--Models are not in the directory of grouped models
	INSERT INTO pk5.error (row_id, col, error, tbl, error_type, deleted, qty_code)
	SELECT m.id, '', '', 'dbo.models', null, NULL, 158
	FROM dbo.models m
	LEFT JOIN ( SELECT id, site_code, model_name FROM dbo.models_group_marks WHERE deleted IS NULL) gm ON gm.model_name = m.descr
	WHERE m.deleted IS NULL AND gm.id IS NULL AND m.id = @id

END 
