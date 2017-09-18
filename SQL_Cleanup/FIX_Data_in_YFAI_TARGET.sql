/* 
FIX ng4SDTLead -->a9p_ProjectManager attribute mapping from Ng4_MasterPrgRevision  to A9_ProgramItemRevision
ng4SDTLead -->a9p_ProjectManager (Its wrongly transformed to UID of ng4SDTLead User,instead of mapping string value. 
We need to update correct values in target. */

Update pA9_ProgramItemRevision set PA9P_PROJECTMANAGER='mark.kadzban@yfai.com' where puid='ryUdD5DCIRyNID';
commit;