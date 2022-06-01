import os
import requests
from requests.exceptions import HTTPError
import time

commit_hash = os.getenv("SKYNET_BUILD_COMMIT_HASH")
branch_name = os.getenv("SKYNET_CHECKOUT_REF").split("/")[-1]
github_token = os.getenv("GITHUB_TOKEN")
res = requests.get(
        "https://api.github.com/users/octocat",
        params={"branch": branch_name},
        headers={
            'Accept': 'application/vnd.github.v3+json',
            'Authorization': f'token {github_token}'
        })
print(res.json())
completed = False
while not completed:
    try:
        response = requests.get(
            "https://api.github.com/repos/Workiva/w_transport/actions/runs",
            params={"branch": branch_name},
            headers={
                'Accept': 'application/vnd.github.v3+json', 
                'Authorization': f'token {github_token}'
            })
        # If the response was successful, no Exception will be raised
        response.raise_for_status()
    except HTTPError as http_err:
        print(f'HTTP error occurred: {http_err}')
    except Exception as err:
        print(f'Other error occurred: {err}')
    workflow_runs = response.json().get("workflow_runs")

    for run in workflow_runs:
        head_sha = run.get("head_sha")
        if head_sha != commit_hash:
            print(f"Head sha: {head_sha} does not match expected commit hash: {commit_hash} continuing")
            continue
        if run.get("status") != "completed":
            print("Run not completed yet waiting a minute and trying again.")
            time.sleep(60)
            break
        conclusion = run.get("conclusion")
        if conclusion == "success":
            print("Github actions test run successful")
            exit(0)
        else:
            print(f"Github actions failed with the conclusion of: {conclusion}")
            exit(1)
