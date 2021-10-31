const https = require('https')

const options = {
    port: 443,
    hostname: 'api.tracker.yandex.net',
    path: '/v2/issues/_search',
    method: 'POST',
    headers: {
        "Content-Type": "application/json",
        "Authorization": "OAuth " + process.env.YANDEX_TRACKER_OAUTH,
        "X-Org-Id": `${process.env.YANDEX_TRACKER_ORG_ID}`,
    },
    body: JSON.stringify({
        filter: { unique: '123qwe' }
    })
}

const req = https.request(options, res => {
    console.log(`statusCode: ${res.statusCode}`)

    res.on('data', d => {
        process.stdout.write(d)
    })
})

req.on('error', error => {
    console.error(error)
})

req.end()
