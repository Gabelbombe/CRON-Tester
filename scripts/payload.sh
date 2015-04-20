#!/bin/bash
su - vagrant -c "
  echo '* * * * * vagrant touch /tmp/crontest >/dev/null 2>&1 ## touch every minute' >/etc/cron.d/crontest
"
