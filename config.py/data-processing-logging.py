"""
Configuration module for SharePoint Excel Integration
Handles all environment variables and settings
"""

import os
from dotenv import load_dotenv
import logging
from typing import Optional

logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()


class Config:
    """Configuration class for SharePoint Excel Integration"""
    
    def __init__(self, key_vault_client=None):
        self.key_vault_client = key_vault_client
        
        # SharePoint Configuration
        self.tenant_id = self._get_secret_or_env('TENANT_ID', 'TENANT_ID')
        self.client_id = self._get_secret_or_env('CLIENT_ID', 'CLIENT_ID')
        self.client_secret = self._get_secret_or_env('CLIENT_SECRET', 'CLIENT_SECRET')
        self.sharepoint_site = self._get_secret_or_env('SHAREPOINT_SITE', 'SHAREPOINT_SITE')
        self.drive_id = self._get_secret_or_env('DRIVE_ID', 'DRIVE_ID')
        
        # Parse multiple item IDs from ITEM_ID environment variable
        self.item_ids = self._parse_item_ids()
        
        # Azure Key Vault Configuration (optional)
        self.key_vault_url = os.getenv('KEY_VAULT_URL')
        
        # Azure Blob Storage Configuration
        self.storage_account_name = os.getenv('STORAGE_ACCOUNT_NAME', 'dwwolffsadevwestus3')
        self.container_name = os.getenv('CONTAINER_NAME', 'data-lake')
        self.base_path = os.getenv('BASE_PATH', 'sharepoint/fpa')
        # Optional: Connection string or storage key (if not using managed identity)
        self.storage_connection_string = self._get_secret_or_env('AZURE_STORAGE_CONNECTION_STRING', 'AZURE_STORAGE_CONNECTION_STRING')
        self.storage_account_key = self._get_secret_or_env('AZURE_STORAGE_ACCOUNT_KEY', 'AZURE_STORAGE_ACCOUNT_KEY')
        
        # Performance Configuration
        self.default_page_size = int(os.getenv('DEFAULT_PAGE_SIZE', '50000'))
        self.max_retries = int(os.getenv('MAX_RETRIES', '5'))
        self.retry_delay = int(os.getenv('RETRY_DELAY', '2'))
        self.max_workers = int(os.getenv('MAX_WORKERS', '4'))
        
        # Graph API Configuration
        self.authority = f"https://login.microsoftonline.com/{self.tenant_id}"
        self.scope = ["https://graph.microsoft.com/.default"]
        self.base_url = "https://graph.microsoft.com/v1.0"
        
        # Validate configuration
        self._validate_config()
    
    def _get_secret_or_env(self, secret_name: str, env_var_name: str) -> Optional[str]:
        """Get secret from Key Vault or fallback to environment variable"""
        if self.key_vault_client:
            return self.key_vault_client.get_secret_or_env(secret_name, env_var_name)
        else:
            return os.getenv(env_var_name)
    
    def _parse_item_ids(self):
        """Parse ITEM_ID environment variable into dictionary"""
        item_ids = {}
        item_ids_str = os.getenv('ITEM_ID', '').strip('[]')
        
        if not item_ids_str:
            raise ValueError("ITEM_ID environment variable is required")
        
        for item_pair in item_ids_str.split(','):
            if '=' in item_pair:
                key, value = item_pair.strip().split('=')
                item_ids[key] = value
        
        if not item_ids:
            raise ValueError("No valid item IDs found in ITEM_ID environment variable")
        
        logger.info(f"Found {len(item_ids)} Excel files to process")
        for key, value in item_ids.items():
            logger.info(f"  {key}: {value}")
        
        return item_ids
    
    def _validate_config(self):
        """Validate that all required configuration is present"""
        required_vars = [
            ('TENANT_ID', self.tenant_id),
            ('CLIENT_ID', self.client_id),
            ('CLIENT_SECRET', self.client_secret),
            ('SHAREPOINT_SITE', self.sharepoint_site),
            ('DRIVE_ID', self.drive_id),
        ]
        
        missing_vars = []
        for var_name, var_value in required_vars:
            if not var_value:
                missing_vars.append(var_name)
        
        if missing_vars:
            raise ValueError(f"Missing required environment variables: {missing_vars}")
        
        logger.info("Configuration validation passed")
    
    def get_file_path(self, table_name):
        """Get the file storage path for a specific table"""
        return f"{self.base_path}/{table_name}"
    
    def get_blob_path(self, table_name):
        """Get the blob storage path for a specific table (for backward compatibility)"""
        return self.get_file_path(table_name)
    
    def get_file_name(self, table_name, file_number):
        """Get the file name for a specific table and file number"""
        return f"{table_name}_{file_number}.json"
