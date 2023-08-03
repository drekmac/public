#This script triggers SCCM actions on a client, run this on a client and the associated action will start
#From https://learn.microsoft.com/en-us/mem/configmgr/develop/reference/core/clients/client-classes/triggerschedule-method-in-class-sms_client
Invoke-CIMMethod -Namespace root\ccm -ClassName SMS_CLIENT -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000021}'} #Machine Policy Assignments Request
Invoke-CIMMethod -Namespace root\ccm -ClassName SMS_CLIENT -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000022}'} #Machine Policy Evaluation
Invoke-CIMMethod -Namespace root\ccm -ClassName SMS_CLIENT -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000042}'} #Policy Agent Validate Machine Policy / Assignment
Invoke-CIMMethod -Namespace root\ccm -ClassName SMS_CLIENT -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000107}'} #Windows Installer Source List Update Cycle
Invoke-CIMMethod -Namespace root\ccm -ClassName SMS_CLIENT -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000121}'} #Application manager policy action
Invoke-CIMMethod -Namespace root\ccm -ClassName SMS_CLIENT -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000113}'} #Scan by Update Source
Invoke-CIMMethod -Namespace root\ccm -ClassName SMS_CLIENT -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000108}'} #Software Updates Assignments Evaluation Cycle
Invoke-CIMMethod -Namespace root\ccm -ClassName SMS_CLIENT -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000001}'} #Hardware Inventory
Invoke-CIMMethod -Namespace root\ccm -ClassName SMS_CLIENT -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000221}'} #Endpoint deployment reevaluate
Invoke-CIMMethod -Namespace root\ccm -ClassName SMS_CLIENT -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000222}'} #Endpoint AM policy reevaluate