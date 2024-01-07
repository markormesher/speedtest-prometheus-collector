import * as http from "http";
import * as speedtest from "speedtest-net";
import { ConfigKey, getConfig } from "./config";
import { formatMeasurement } from "./utils";

function log(msg: string, ...args: unknown[]) {
  console.log(`[${new Date().toISOString()}] ${msg}`, ...args);
}

// get config
const testIntervalMs = parseInt(getConfig(ConfigKey.TestIntervalMs)) || 15 * 60 * 1000;

// string array of metrics, or null if collection is failing
let latestMeasurements: string[] = null;

async function updateMeasurements(): Promise<void> {
  log("Updating metrics...");
  try {
    const tags = {};
    const result = await speedtest({ acceptLicense: true, acceptGdpr: true });
    const measurements: string[] = [];
    measurements.push(formatMeasurement("speedtest_download_bps", tags, result.download.bandwidth * 8));
    measurements.push(formatMeasurement("speedtest_upload_bps", tags, result.upload.bandwidth * 8));
    measurements.push(formatMeasurement("speedtest_ping_latency_ms", tags, result.ping.latency));
    measurements.push(formatMeasurement("speedtest_ping_jitter_ms", tags, result.ping.jitter));
    latestMeasurements = measurements;
    log("Metrics updated");
  } catch (e) {
    log("Failed to take measurements - exiting", e);
    throw e;
  }
}

updateMeasurements();
setInterval(updateMeasurements, testIntervalMs);

const server = http.createServer((req, res) => {
  if (req.method == "GET" && req.url == "/metrics") {
    if (latestMeasurements !== null) {
      res
        .writeHead(200, {
          "Content-Type": "text/plain",
        })
        .end(latestMeasurements.join("\n"));
    } else {
      res.writeHead(500).end();
    }
    return;
  }

  res.writeHead(404).end();
});

server.listen(9030, () => log("Server listening on HTTP/9030"));

process.on("SIGTERM", () => {
  log("Closing server connection");
  server.close(() => {
    log("Exiting process");
    process.exit(0);
  });
});
