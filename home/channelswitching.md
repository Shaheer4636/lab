Update: Implemented the requested feature-branch workflow for HFM.CEQ and verified end-to-end.

Branch builds (CEQ/*, feature/*) now create a release in Octopus Feature channel and auto-deploy to DEV. Verified with a test branch build in TeamCity and the corresponding Feature-channel release in Octopus.

Merges to master create a Production channel release that follows STAGING → PROD (with STG approval per lifecycle).
