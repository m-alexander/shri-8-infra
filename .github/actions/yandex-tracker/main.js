fetch('https://api.tracker.yandex.net/v2/issues/_search', {
    method: 'POST',
    headers: {
         "Content-Type": "application/json",
         "Authorization": "OAuth " + process.env.$YANDEX_TRACKER_OAUTH,
         "X-Org-Id": process.env.$YANDEX_TRACKER_ORG_ID,
    },
    body: JSON.stringify({
        filter: { unique: '123qwe' }
    })
})
    .then(response => response.json())
    .then(console.log)
    .catch(console.error)

