const fs = require('fs');
const https = require('https');
const path = require('path');

const GIST_TOKEN = process.env.GIST_TOKEN;
const GISTS = {
    counter: process.env.COUNTER_GIST_ID,
    hydrated: process.env.HYDRATED_GIST_ID,
    undoredo: process.env.UNDOREDO_GIST_ID,
};

async function updateGist(exampleName, gistId) {
    if (!gistId) {
        console.log(`Skipping ${exampleName}: No GIST_ID provided.`);
        return;
    }

    const filePath = path.join(__dirname, '..', 'docs_site', 'static', 'examples', exampleName, 'main.dart');
    if (!fs.existsSync(filePath)) {
        console.error(`File not found: ${filePath}`);
        return;
    }

    const content = fs.readFileSync(filePath, 'utf8');
    const data = JSON.stringify({
        files: {
            'main.dart': {
                content: content,
            },
        },
    });

    const options = {
        hostname: 'api.github.com',
        port: 443,
        path: `/gists/${gistId}`,
        method: 'PATCH',
        headers: {
            'Authorization': `token ${GIST_TOKEN}`,
            'User-Agent': 'Node.js Script',
            'Content-Type': 'application/json',
            'Content-Length': data.length,
        },
    };

    return new Promise((resolve, reject) => {
        const req = https.request(options, (res) => {
            if (res.statusCode === 200) {
                console.log(`Successfully updated Gist for ${exampleName} (${gistId}).`);
                resolve();
            } else {
                console.error(`Failed to update Gist for ${exampleName}. Status: ${res.statusCode}`);
                res.on('data', (d) => process.stdout.write(d));
                reject(new Error(`Status ${res.statusCode}`));
            }
        });

        req.on('error', (e) => {
            console.error(`Request error: ${e.message}`);
            reject(e);
        });

        req.write(data);
        req.end();
    });
}

async function run() {
    if (!GIST_TOKEN) {
        console.error('GIST_TOKEN environment variable is missing.');
        process.exit(1);
    }

    for (const [name, id] of Object.entries(GISTS)) {
        try {
            await updateGist(name, id);
        } catch (e) {
            console.error(`Error updating ${name}:`, e.message);
        }
    }
}

run();
