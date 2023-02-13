import logging
import re
import sys
from hr_core import HrCore

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
                employee_id_provided = split[i+1].lstrip("0") 
            if "Microsoft Alias".lower() in v.lower():
                alias_provided = split[i+1]
        
        if not employee_id_provided or not alias_provided:
            raise Exception("mal-formatted issue")

        employee_id = hr_core.get_employee_id_by_alias(alias_provided)

        if employee_id != employee_id_provided:
            raise Exception(f"Employee id does not match alias: {alias_provided}, it should instead be {employee_id}")

        return "matches"
    except Exception as e:
        logger.error(f"[DualAccessValidator] error validating issue: {e}")
        raise e

validate(sys.argv[1])