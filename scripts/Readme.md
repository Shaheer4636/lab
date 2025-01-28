# Windows Automation Script Documentation

## Overview
This PowerShell script is designed to automate the installation of essential software, configure disk drives, set up local users, and manage folder access permissions. It includes tasks such as downloading and installing applications, configuring the environment, and preparing the system for specific development or operational needs.

## Script Workflow
1. **Start Logging:**
   - Begins a transcript to log script activity into a file (`powershell.log`).

2. **Install OS Software:**
   - Installs Chocolatey (a package manager for Windows).
   - Uses Chocolatey to install the following software:
     - Google Chrome
     - Strawberry Perl (64-bit)
     - Python
     - TortoiseSVN
     - Notepad++ (64-bit)
     - 7-Zip (pre-release version)
     - DBeaver
     - FileZilla
     - Adobe Reader
     - WinMerge (pre-release version)
     - Graphviz
     - Eclipse (version 4.33.0)
   - Installs the Azure CLI via MSI.
   - Installs Java JDK 21 via MSI.
   - Installs Apache Ant by downloading and extracting its binary zip file.

3. **Configure Environment for Strawberry Perl:**
   - Sets the environment PATH to include necessary directories for Strawberry Perl.
   - Runs a command script (`StrawberryPerl-approved-modules.cmd`) to install approved Perl modules.

4. **Configure Disk Drive:**
   - Initializes Disk 1 with MBR partition style.
   - Creates a new partition and formats it as NTFS with the label "Local Disk."
   - Copies files from an S3 bucket to the new drive (if the drive is successfully set up):
     - `analysis-factory.zip`
     - `cnv-factory-ccdva-j.zip`
   - Extracts the downloaded ZIP files and verifies the folder structure.

5. **Install PostgreSQL Driver for DBeaver:**
   - Copies the PostgreSQL JDBC driver (`postgresql-42.2.23.jar`) to DBeaver's plugin directory.

6. **Create Local Users:**
   - Retrieves a password from AWS Secrets Manager.
   - Creates two local users (`factory` and `factory2`) with the password.
   - Adds these users to the Administrators group.

7. **Set Folder Access Permissions:**
   - Configures folder-level access control for the `E:\` drive, granting full control to built-in users and administrators.

8. **Install Docker:**
   - Downloads and runs a script to install Docker Community Edition (CE).

9. **Generate Logs:**
   - Saves a list of all installed Chocolatey packages to `c:\softwarelist.txt`.
   - Logs errors during folder extraction (if any) to `c:\errorfolderstructure.txt`.

## Installed Software
| Software            | Source/Method                                                                 |
|---------------------|------------------------------------------------------------------------------|
| Google Chrome       | Chocolatey (`choco install -y googlechrome`)                                 |
| Strawberry Perl     | Chocolatey (`choco install -y strawberryperl --x64`)                        |
| Python              | Chocolatey (`choco install -y python`)                                      |
| TortoiseSVN         | Chocolatey (`choco install -y tortoisesvn`)                                 |
| Notepad++           | Chocolatey (`choco install -y notepadplusplus --x64`)                      |
| 7-Zip               | Chocolatey (`choco install -y 7zip.install --pre`)                         |
| DBeaver             | Chocolatey (`choco install -y dbeaver`)                                     |
| FileZilla           | Chocolatey (`choco install -y filezilla`)                                   |
| Adobe Reader        | Chocolatey (`choco install -y adobereader`)                                 |
| WinMerge            | Chocolatey (`choco install -y winmerge --pre`)                              |
| Graphviz            | Chocolatey (`choco install -y graphviz`)                                    |
| Eclipse             | Chocolatey (`choco install -y eclipse --version=4.33.0`)                   |
| Azure CLI           | MSI (`Invoke-WebRequest` + `msiexec.exe`)                                   |
| Java JDK 21         | MSI (`msiexec.exe` with Oracle JDK URL)                                     |
| Apache Ant          | ZIP Archive (downloaded and extracted)                                      |
| Docker CE           | PowerShell script from Microsoft's GitHub repository                        |

## Key Configurations
- **Disk Setup:** Initializes and formats a secondary drive (`E:\`) for storage purposes.
- **S3 Bucket Integration:** Downloads necessary files from an S3 bucket for setup and configuration.
- **User Creation:** Adds local users with administrator privileges for system access.
- **Access Control:** Configures folder permissions to secure the `E:\` drive.

## Error Handling
- Logs errors during folder extraction to `c:\errorfolderstructure.txt`.
- Outputs error messages to the console if issues occur during the PostgreSQL driver setup or disk configuration.

## Notes
- Ensure the script has the necessary permissions to:
  - Install software.
  - Modify disk partitions.
  - Access S3 buckets.
  - Create local users.
- Dependencies include:
  - AWS CLI for S3 operations.
  - Chocolatey for package management.

## How to Run
1. Open PowerShell as Administrator.
2. Execute the script with the appropriate permissions and ensure the environment is set up to access AWS Secrets Manager and S3 buckets.

```powershell
.\your_script.ps1
```
