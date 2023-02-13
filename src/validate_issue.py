import logging
import re
import sys
from hr_core import HrCore
import os

logger = logging.getLogger("uvicorn.error")

hr_core = HrCore()

def validate(body):
    try:
        logger.info(f"[DualAccessValidator] Validating issue")

        body = re.sub(r'\n+', '\n', body).strip()

        split = body.split('\n')
        employee_id_provided = ""
        alias_provided = ""
        for i in range(len(split) - 1):
            v = split[i]
            if "Microsoft Employee ID / PERN".lower() in v.lower():
                employee_id_provided = split[i+1].lstrip("0") .replace(" ", '')
            if "Microsoft Alias".lower() in v.lower():
                alias_provided = split[i+1].replace(" ", "")
        
        if not employee_id_provided or not alias_provided:
            raise Exception("mal-formatted issue")

        employee_id = hr_core.get_employee_id_by_alias(alias_provided)

        if int(employee_id) != int(employee_id_provided):
            raise Exception(f"Employee id does not match alias {alias_provided}. provided id = {employee_id_provided}, should be = {employee_id}")

        return "matches"
    except Exception as e:
 
        # Write the updated environment variable to a file
        print(f"ISSUE_DETECTED=yes")
        print("::set-output name=ISSUE_DETECTED::yes")
        #logger.error(f"[DualAccessValidator] error validating issue: {e}")

validate(sys.argv[1])