SELECT 
    referencing_schema_name, referencing_entity_name, referencing_id, 
    referencing_class_desc, is_caller_dependent
FROM 
    sys.dm_sql_referencing_entities ('dbo.cis_lookup', 'OBJECT');
GO


select object_name(m.object_id), m.*
  from sys.sql_modules m
 where m.definition like N'%cis_lookup%'


 exec sp_depends 'dbo.account'