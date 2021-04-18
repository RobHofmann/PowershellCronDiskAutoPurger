#!/bin/bash

# Make sure CRON is being setup
if [[ -n "$CLEAN_CRON_EXPRESSION" ]]; then
  ln -sf /proc/$$/fd/1 /var/log/stdout
  service cron start
	if [[ -n "$CLEAN_CRON_EXPRESSION" ]]; then
        echo "$CLEAN_CRON_EXPRESSION pwsh /scripts/Purge.ps1 -RootDirectory '/data' -GracePeriodInSeconds $GRACE_PERIOD_IN_SECONDS -IncludeFilters "$INCLUDE_FILTERS" -ExcludeFilters "$EXCLUDE_FILTERS" >/var/log/stdout 2>&1" > /etc/crontab
	fi
	crontab /etc/crontab
fi

# Tail to let the container run
tail -f /dev/null