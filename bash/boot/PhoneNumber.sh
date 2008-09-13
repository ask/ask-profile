#!/bin/bash
. ~/.living-profile.rc
import LibLivingProfile

PHONE_NUMBER_FILE="$LP_PERSONALIADIR/phone-number"


log_action "Configuring phone number"

if [ -f "$PHONE_NUMBER_FILE" ]; then
    export PHONE=$(cat "$PHONE_NUMBER_FILE")
    export PHONELOCAL=$(echo "$PHONE" | awk '{print $2}')
    result_ok "OK ($PHONE)"
else
    result_failed
fi


