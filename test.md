Hi Ozodi,

We are ready with the next QA automation milestone delivery. We have completed the automating CareLink MoveProvider regression test cases.

Can you please help us to update our QA automation pipeline?

Job Name: QA01-HCC-UI-REGRESSION-TEST
URL: https://dev.azure.com/paradigmoutcomes/QAAutomation/_release?_a=releases&view=mine&definitionId=14
Stage Name: MoveProvider
QA Run Command: MoveProvider:all:run:qa:ui

Job Name: TEST-HCC-UI-REGRESSION-TEST
URL: https://dev.azure.com/paradigmoutcomes/QAAutomation/_release?_a=releases&view=mine&definitionId=18
Stage Name: MoveProvider
Test Run Command: MoveProvider:all:run:test:ui

Job Name: STG-HCC-UI-REGRESSION-TEST
URL: https://dev.azure.com/paradigmoutcomes/QAAutomation/_release?_a=releases&view=all&definitionId=20
Stage Name: MoveProvider
STG Run Command: MoveProvider:all:run:stg:ui

Job Name: UAT-HCC-UI-REGRESSION-TEST
URL: https://dev.azure.com/paradigmoutcomes/QAAutomation/_release?_a=releases&view=mine&definitionId=19
Stage Name: MoveProvider
UAT Run Command: MoveProvider:all:run:uat:ui
