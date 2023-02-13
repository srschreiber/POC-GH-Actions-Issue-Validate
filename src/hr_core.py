import os
import logging
import requests as http
import sys

cwd = os.path.abspath(os.getcwd())
include_path = f"{cwd}"
sys.path.append(include_path)

logger = logging.getLogger("HrCore")
logging.basicConfig(level=logging.INFO)
class HrCore:
    def __init__(self) -> None:

        self.hr_core_api_people_cid = os.getenv("HR_CORE_API_HARD_DELETE_CLIENT_ID")
        self.client_id = os.getenv("MSFT_TENANT_CLIENT_ID")
        self.client_secret = os.getenv("MSFT_TENANT_CLIENT_SECRET")
        self.azure_tenant_id = os.getenv("MSFT_AZURE_TENANT_ID")
        self.base_url = os.getenv("HR_CORE_API_URL")


    def get_alias_by_employee_id(self, employee_id):
        token = self.__get_hr_api_bearer_token(self.hr_core_api_people_cid)
        headers = {
            "Authorization": token,
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        url = f"{self.base_url}/Person/{employee_id}"
        r = http.get(
            url,
            headers=headers,
        )

        if r is None:
            raise Exception("None response from hr core api get microsoft alias by employee id")
        
        if r.status_code == 401:
            raise Exception(f"Unauthorized status when requesting to {url}")

        if r.status_code == 404:
            raise Exception(f"Could not find user with employee id {employee_id}")

        return r.json()["emailAlias"]

    def get_employee_id_by_alias(self, alias):
        token = self.__get_hr_api_bearer_token(self.hr_core_api_people_cid)
        headers = {
            "Authorization": token,
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        url = f"{self.base_url}/Person/{alias}/getByAlias"
        r = http.get(
            url,
            headers=headers,
        )

        if r is None:
            raise Exception("None response from hr core api get msft employee id by alias")
        
        if r.status_code == 401:
            raise Exception(f"Unauthorized status when requesting to {url}")

        if r.status_code == 404:
            raise Exception(f"Could not find user with alias {alias}")
        return r.json()["personnelNumber"]

    
    def __get_hr_api_bearer_token(self, target_client_id) -> str:
        data = {
            "grant_type": "client_credentials",
            "client_id": self.client_id,
            "client_secret": self.client_secret,
            "scope": f"{target_client_id}/.default",
        }
        r = http.post(
            f"https://login.microsoftonline.com/{self.azure_tenant_id}/oauth2/v2.0/token",
            data,
        )
        token = r.json()["access_token"]
        return f"Bearer {token}"

