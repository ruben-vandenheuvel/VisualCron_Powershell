# VisualCron_Powershell
VisualCron allows you to store the logging into an external database. Once this is configured you can connect to this database and extract information out of it.
However, the loggin information stored is all ID based. The powershell script in the repo will extract the ID information and the name details for Jobs, Tasks, Trigger and Users.

This code will export Job, Task, Trigger, Session and User details into CSV files.
These CSV files can be imported into other tools such as the database where the VisualCron logging information is stored. Together they can provide you details about for instance the Job execution times, the job and task duration, show trends on job and task level and a lot more.
