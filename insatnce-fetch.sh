Hi Ozodi,
In all the CareLink QA automation Pipeline -HCC-NEWSERVICES-REGRESSION-TEST>, we request to remove the existing stage ReferralAPISuite and add the following stages. Please let me know if you have any questions.

For TERRA automation
Stage Name: TerraPurchase
UAT command: run:uat:ui:TerraSinglePurchaseReferralAPI
UAT2 command: run:uat2:ui:TerraSinglePurchaseReferralAPI
QA command: run:qa:ui:TerraSinglePurchaseReferralAPI
TEST command: run:tst:ui:TerraSinglePurchaseReferralAPI
STG command: run:stg:ui:TerraSinglePurchaseReferralAPI
STG2 command: run:stg2:ui:TerraSinglePurchaseReferralAPI

Stage Name: TerraRental
UAT command: run:uat:ui:TerraSingleRentalReferralAPI
UAT2 command: run:uat2:ui:TerraSingleRentalReferralAPI
QA command: run:qa:ui:TerraSingleRentalReferralAPI
TEST command: run:tst:ui:TerraSingleRentalReferralAPI
STG command: run:stg:ui:TerraSingleRentalReferralAPI
STG2 command: run:stg2:ui:TerraSingleRentalReferralAPI

Stage Name: TerraExtensionReturned
UAT command: run:uat:ui:TerraExtensionReturned
UAT2 command: run:uat2:ui:TerraExtensionReturned
QA command: run:qa:ui:TerraExtensionReturned
TEST command: run:tst:ui:TerraExtensionReturned
STG command: run:stg:ui:TerraExtensionReturned
STG2 command: run:stg2:ui:TerraExtensionReturned

Stage Name: TerraTwoServiceRequests
UAT command: run:uat:ui:TerraTwoServiceRequests
UAT2 command: run:uat2:ui:TerraTwoServiceRequests
QA command: run:qa:ui:TerraTwoServiceRequests
TEST command: run:tst:ui:TerraTwoServiceRequests
STG command: run:stg:ui:TerraTwoServiceRequests
STG2 command: run:stg2:ui:TerraTwoServiceRequests

Stage Name: TerraFourServiceRequests
UAT command: run:uat:ui:TerraFourServiceRequests
UAT2 command: run:uat2:ui:TerraFourServiceRequests
QA command: run:qa:ui:TerraFourServiceRequests
TEST command: run:tst:ui:TerraFourServiceRequests
STG command: run:stg:ui:TerraFourServiceRequests
STG2 command: run:stg2:ui:TerraFourServiceRequests
