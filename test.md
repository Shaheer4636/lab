Application Development & QA Teams - Pipeline Restructuring Documentation 
 
Purpose of the Restructuring 
To enhance security and streamline access management, we have restructured the application pipelines into separate folders for non-production and production environments. This segregation ensures that: 
- Application development and QA teams have controlled access to non-production pipelines. 
- IT Operations teams have exclusive access to production pipelines. 
- Proper approval gates are enforced for production releases. 
- Minimized risk of unauthorized modifications to production deployments. 
 
Changes to Pipelines 
- Non-production pipelines have been moved to the “NON-PROD” folder. 
- Production pipelines have been moved to the “PROD” folder. 
- Application development and QA teams have full access to the “NON-PROD” folder for testing and deployment needs. 
- IT Operations team has access to the “PROD” folder, ensuring secure deployments. 
- Pipeline permissions have been updated to reflect these changes, allowing the appropriate teams to approve and manage deployments within their designated environments. 
 
Finding Release Numbers for Documentation 
To document the release numbers: 
1. Navigate to the Azure DevOps Portal. 
2. Navigate to the Releases section 
3. Click the folder icon to show all releases  
2. Go to the “NON-PROD” pipelines folder. 
3. Open the relevant pipelines folder and navigate to the Releases section. 
4. Locate the relevant non-prod release deployed up to “PRODTRIGGER” stage. 
5. In the “Trigger Azure DevOps Pipeline” step log, locate the “Triggered Release: Release-xxxx” 
6. Use this release number in your release documentation. 
 
Emergency Release Process 
In case of an emergency release, the following steps must be followed: 
1. Create an Emergency Change Request (CR) 
   - Submit an emergency CR following the standard change management process. 
   - Ensure proper documentation is included for the change. 
 
2. Get Approval 
   - Contact Grayson to obtain approval for the emergency release. 
   - Provide justification for the emergency release. 
 
3. Deployment Coordination 
   - Grayson will contact Chris and/or a member of the IT Operations Engineering team. 
   - The IT Operations Engineering team will perform the emergency deployment following the approved emergency CR. 
 
For any questions or further clarifications, please reach out to the DevOps team. 
 
Pipeline Folder Permissions Setup 
To ensure proper access control, two permission groups have been created. These groups determine who can approve and manage deployments within Azure DevOps. 
 
Permissions Groups and Access Levels 
Permission Group 	Folder 	Group Membership	 	Permissions 
Non-Production Release Approvers 	NON-PROD 	ADVA CAB Release Approvers 
ADVA DevOps Release Approvers 
PSN CAB Release Approvers 
PSN DevOps Release Approvers 	Create releases, Delete releases, Manage deployments, Manage releases, View release pipeline, View releases 
Non-Production Release Approvers 	PROD 	ADVA CAB Release Approvers 
ADVA DevOps Release Approvers 
PSN CAB Release Approvers 
PSN DevOps Release Approvers 	Manage deployments, Manage releases, View releases 
Production Release Approvers 	PROD 	ADVA CAB Release Approvers 
ADVA DevOps Release Approvers 
PSN CAB Release Approvers 
PSN DevOps Release Approvers 	Manage deployments, Manage releases, View release pipeline, View releases 
 
 
Detailed Folder-Specific Access 
NON-PROD 
•	Accessible by: Non-Production Release Approvers (Application Development, QA Teams, and their approvers) 
•	Permissions: 
o	Create releases – Ability to initiate new releases 
o	Delete releases – Remove unwanted or obsolete releases 
o	Manage deployments – Control deployment processes in non-production environments 
o	Manage releases – Edit and oversee non-production release pipelines 
o	View release pipeline – Access pipeline configurations and workflows 
o	View releases – Monitor and review previous releases 
PROD 
•	Accessible by: 
o	Non-Production Release Approvers (Restricted Access) 
	Manage deployments 
	Manage releases 
	View releases 
o	Production Release Approvers (Full Access) 
	Manage deployments 
	Manage releases 
	View release pipeline 
	View releases 
 

