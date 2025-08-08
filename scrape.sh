#!/bin/bash

output_file="anime_id_map.txt"

# Resume logic
if [[ -f "$output_file" ]]; then
    last_id=$(tail -n 1 "$output_file" | cut -d'-' -f1)
else
    last_id=0
fi

start_id=$((last_id + 1))
end_id=999999999  # Adjust upper limit if needed

for ((id=start_id; id<=end_id; id++)); do
    echo "[+] Checking anime ID: $id"

    html=$(curl -s "https://aniwave.at/anime/$id" 
  --Compressed \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
  -H 'Accept-Language: en-US,en;q=0.5' \
  -H 'Accept-Encoding: gzip, deflate, br, zstd' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: cf_clearance=RQ19sR94mTpd.ArEA_kbo432v6dUfarXGlFIzHiBiXk-1754559855-1.2.1.1-iZpUJkp8EP8JziGXlVNo22JvTVI9WKYixesRL7tqqWvHx0ruuFcP_6HM51.vhEgKDR18KGvua8AGDAX8K9B522YnZFQMfBeLkfng0Qep2tFNUsCecTO1fLnLBKbx0uVylzsqR4KsqX0jUxEVaCDHzxLHewoVHhcjHuHP2225TU_1fPtgJ1MmRY96AtjytCBpKSdeUTuUWQTdfQhTD45ovkHmkQS_PzW.audb5nRHr_E; csrf_token=1b983011-82a8-42ac-bdc6-0e36e2b56cbe; __pf=1' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'Sec-Fetch-Dest: document' \
  -H 'Sec-Fetch-Mode: navigate' \
  -H 'Sec-Fetch-Site: none' \
  -H 'Sec-Fetch-User: ?1' \
  -H 'Priority: u=0, i' \
  -H 'TE: trailers')

    mal_id=$(echo "$html" | grep -oP 'https://myanimelist\.net/anime/\K[0-9]+' | head -n1)

    if [[ -n "$mal_id" ]]; then
        # Updated grep title extraction
        anime_title=$(echo "$html" | grep -oP '<title>Watch \K.*?(?= Latest Episodes)' | head -n1)

        if [[ -n "$anime_title" ]]; then
            echo "$id-$mal_id-$anime_title" >> "$output_file"
            echo "[✓] Found: $id-$mal_id-$anime_title"
        else
            echo "[-] MAL found but title parsing failed: $id"
        fi
    else
        echo "[-] Not found or MAL ID missing: $id"
    fi

    sleep 1
done
