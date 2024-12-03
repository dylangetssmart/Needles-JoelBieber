USE JoelBieber_GrowPath;

DECLARE @sql NVARCHAR(MAX) = N'';

WITH TableList AS (
    SELECT 
        c.TABLE_SCHEMA,
        c.TABLE_NAME,
        c.COLUMN_NAME,
        ROW_NUMBER() OVER (PARTITION BY c.TABLE_SCHEMA, c.TABLE_NAME ORDER BY c.COLUMN_NAME) AS RowNum,
        DENSE_RANK() OVER (ORDER BY c.TABLE_NAME) AS TableRank
    FROM INFORMATION_SCHEMA.COLUMNS c
    JOIN INFORMATION_SCHEMA.TABLES t 
        ON c.TABLE_SCHEMA = t.TABLE_SCHEMA AND c.TABLE_NAME = t.TABLE_NAME
    WHERE t.TABLE_TYPE = 'BASE TABLE'
),
PaginatedTables AS (
    SELECT DISTINCT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME
    FROM TableList
    WHERE TableRank BETWEEN 51 AND 103 -- Offset 51, fetch 50 rows
)

SELECT @sql += 
    'SELECT ''' + 
    TABLE_NAME + ''' AS TableName, ''' + 
    COLUMN_NAME + ''' AS ColumnName, COUNT([' + COLUMN_NAME + ']) AS NonNullCount, ' +
    'MIN(CASE WHEN [' + COLUMN_NAME + '] IS NOT NULL THEN CAST([' + COLUMN_NAME + '] AS NVARCHAR(4000)) END) AS SampleValue ' +
    'FROM [' + TABLE_SCHEMA + '].[' + TABLE_NAME + '] ' + 
    'UNION ALL '
FROM PaginatedTables;

-- Remove the last 'UNION ALL'
IF LEN(@sql) > 0
    SET @sql = LEFT(@sql, LEN(@sql) - 10) + ';';

-- Execute the generated SQL
IF LEN(@sql) > 0
    EXEC sp_executesql @sql;
ELSE
    PRINT 'No tables found for this range.';
