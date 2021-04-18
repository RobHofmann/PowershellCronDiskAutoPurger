# PowershellAzureCronBlobCleaner
Powershell script that cleans files from your disk with a cutoff date & filters.

# Environment variables needed
| Variable name | Required | Example value | Description |
| ------------- | ------------- | ------------- | ------------- |
| CLEAN_CRON_EXPRESSION | <input type="checkbox" checked> | `*/2 * * * *` | The CRON expression in which frequency to run the script. |
| GRACE_PERIOD_IN_SECONDS | <input type="checkbox" checked> | `3600` | Files newer than this grace period will be skipped (both for uploading & deleting). This is usefull for when files are still in use when the upload starts. |
| INCLUDE_FILTERS | <input type="checkbox"> | `somefolder;somewildcard*` | A list (`;` separated) which should be included. If left empty, it will auto include everything. |
| EXCLUDE_FILTERS | <input type="checkbox"> | `somefolder;somewildcard*` | A list (`;` separated) which should be included. If left empty, nothing will be excluded. |

# How to use
1. Make sure you filled all the required environment variables listed above.
2. The folder to be purged should be mounted at /data inside the container.
3. Run :).

## Example
```
docker run --name=mycleaner -e CLEAN_CRON_EXPRESSION='0 * * * *' -e GRACE_PERIOD_IN_SECONDS=3600 -e INCLUDE_FILTERS="somefolder;somewildcard*" -e EXCLUDE_FILTERS="somefolder;somewildcard*" -d robhofmann/powershellcrondiskautopurger
```
