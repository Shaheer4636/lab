🔸 Contributors
Limited to view-only access for release pipelines and releases.

All create, delete, manage, and edit permissions are Not set.

🔸 Non-Production Release Approvers
Denied from creating and deleting releases in production.

Allowed to view and manage releases but cannot modify pipelines/stages.

🔸 Production Release Approvers
Granted view and manage access to releases only.

No rights to create, delete, or edit pipelines/stages.

🔸 Project Administrators
All critical permissions (create, delete, manage, edit) are explicitly denied.

Only allowed to view release pipelines and releases.

🔸 Readers
As expected, view-only access is granted.

No permissions set for managing or modifying anything.

🔸 Release Administrators
Granted full access to manage all aspects of releases and pipelines.

This group retains complete control as expected for admin-level roles.

🔸 Release Approvers
Denied most permissions including create, delete, and manage.

Only view access is inherited — cannot perform any release operations.

🔸 Project Collection Administrators
Inherited full access to all permissions — release creation, editing, deletion, and management.

Has unrestricted control over the entire production folder.




🔐 Production environment (PROD\ADVA) is much more restricted:

Approvers and Admins are limited in their ability to create, delete, or modify.

Production Release Approvers group exists only in PROD.

Project Administrators have full control in NON-PROD but are denied nearly everything in PROD.

✅ NON-PROD (\NON-PROD\Fusion) allows more flexibility for testing, experimentation, and active development tasks.
