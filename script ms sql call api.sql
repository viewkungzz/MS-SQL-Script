--sp_configure 'show advanced options', 1;
--GO
--RECONFIGURE;
--GO
--sp_configure 'Ole Automation Procedures', 1;
--GO
--RECONFIGURE;
--GO

Declare @Object as Int;
DECLARE @hr  int
Declare @json as table(Json_Table nvarchar(max))

Exec @hr=sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @Object OUT;
IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object
Exec @hr=sp_OAMethod @Object, 'open', NULL, 'get',
                 'https://pixabay.com/api/?key=', --Your Web Service Url (invoked)
                 'false'
IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object
Exec @hr=sp_OAMethod @Object, 'send'
IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object
Exec @hr=sp_OAMethod @Object, 'responseText', @json OUTPUT
IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object

INSERT into @json (Json_Table) exec sp_OAGetProperty @Object, 'responseText'
-- select the JSON string
select * from @json
-- Parse the JSON string
SELECT * FROM OPENJSON((select * from @json))
WITH (   
		total NVARCHAR(50) 'strict $.total',
		totalHits NVARCHAR(50) 'strict $.totalHits',
		hits NVARCHAR(MAX) '$.hits' AS JSON   
)
OUTER APPLY OPENJSON(hits)
  WITH (id NVARCHAR(MAX) '$.id',
		pageURL NVARCHAR(MAX) '$.pageURL'	
		);
EXEC sp_OADestroy @Object