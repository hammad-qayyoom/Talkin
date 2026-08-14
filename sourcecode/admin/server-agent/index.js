require('dotenv').config();
const express = require('express');
const { execSync, exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 5700;
const AGENT_SECRET = process.env.AGENT_SECRET || '';

// Only bind to localhost
app.use(express.json({ limit: '5mb' }));

// Auth middleware - simple token check
function authMiddleware(req, res, next) {
  const token = req.headers['x-agent-secret'];
  if (!AGENT_SECRET) {
    return res.status(500).json({ error: 'Agent secret not configured' });
  }
  if (token !== AGENT_SECRET) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
}

app.use(authMiddleware);

// Safe command executor - timeout + max output
function safeExec(cmd, timeout = 15000) {
  return new Promise((resolve, reject) => {
    exec(cmd, { timeout, maxBuffer: 1024 * 1024, encoding: 'utf8' }, (err, stdout, stderr) => {
      if (err && !stdout) {
        reject(new Error(stderr || err.message));
      } else {
        resolve(stdout.trim());
      }
    });
  });
}

// ==================== OVERVIEW ====================

app.get('/overview', async (req, res) => {
  try {
    const commands = {
      hostname: 'hostname',
      os: `cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2`,
      kernel: 'uname -r',
      uptime: 'uptime -p',
      timezone: 'timedatectl show --property=Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null || date +%Z',
      currentTime: 'date "+%Y-%m-%d %H:%M:%S %Z"',
      cpuModel: `lscpu | grep "Model name" | sed 's/Model name:\\s*//'`,
      cpuCores: 'nproc',
      loadAverage: `cat /proc/loadavg | awk '{print $1, $2, $3}'`,
      publicIP: 'curl -s --max-time 5 ifconfig.me 2>/dev/null || echo "N/A"',
      processCount: 'ps aux | wc -l'
    };

    const results = {};
    const promises = Object.entries(commands).map(async ([key, cmd]) => {
      try { results[key] = await safeExec(cmd, 10000); } catch { results[key] = 'N/A'; }
    });
    await Promise.all(promises);

    // CPU usage
    try {
      const cpuStr = await safeExec(`top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}'`, 10000);
      results.cpuUsage = parseFloat(cpuStr) || 0;
    } catch { results.cpuUsage = 0; }

    // Memory
    try {
      const memStr = await safeExec(`free -b | awk 'NR==2{printf "{\\"total\\": %s, \\"used\\": %s, \\"free\\": %s, \\"available\\": %s, \\"percent\\": %.2f}", $2, $3, $4, $7, $3/$2*100}'`, 10000);
      results.memory = JSON.parse(memStr);
    } catch { results.memory = { total: 0, used: 0, free: 0, available: 0, percent: 0 }; }

    // Disks
    try {
      const diskRaw = await safeExec(`df -B1 --output=source,fstype,size,used,avail,pcent,target | grep -E '^/' | awk '{gsub(/%/, "", $6); printf "{\\"device\\": \\"%s\\", \\"fstype\\": \\"%s\\", \\"total\\": %s, \\"used\\": %s, \\"available\\": %s, \\"percent\\": %s, \\"mount\\": \\"%s\\"}\\n", $1, $2, $3, $4, $5, $6, $7}'`, 10000);
      results.disks = diskRaw.split('\n').filter(Boolean).map(l => { try { return JSON.parse(l); } catch { return null; } }).filter(Boolean);
    } catch { results.disks = []; }

    // Load average
    try {
      const loadStr = results.loadAverage || '';
      const parts = loadStr.split(' ');
      results.loadAverage = { one: parseFloat(parts[0]) || 0, five: parseFloat(parts[1]) || 0, fifteen: parseFloat(parts[2]) || 0 };
    } catch { results.loadAverage = { one: 0, five: 0, fifteen: 0 }; }

    // Health
    results.health = determineHealth(results);

    res.json({ ok: true, data: results });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==================== CPU ====================

app.get('/cpu', async (req, res) => {
  try {
    const usage = await safeExec(`top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}'`).catch(() => '0');
    res.json({ ok: true, data: { usage: parseFloat(usage) || 0 } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==================== MEMORY ====================

app.get('/memory', async (req, res) => {
  try {
    const info = await safeExec(`free -b | awk 'NR==2{printf "{\\"total\\": %s, \\"used\\": %s, \\"free\\": %s, \\"available\\": %s, \\"percent\\": %.2f}", $2, $3, $4, $7, $3/$2*100}'`);
    const swap = await safeExec(`free -b | awk 'NR==3{printf "{\\"total\\": %s, \\"used\\": %s, \\"free\\": %s}", $2, $3, $4}'`);
    res.json({ ok: true, data: { ...JSON.parse(info), swap: JSON.parse(swap) } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==================== DISK ====================

app.get('/disk', async (req, res) => {
  try {
    const diskRaw = await safeExec(`df -B1 --output=source,fstype,size,used,avail,pcent,target | grep -E '^/' | awk '{gsub(/%/, "", $6); printf "{\\"device\\": \\"%s\\", \\"fstype\\": \\"%s\\", \\"total\\": %s, \\"used\\": %s, \\"available\\": %s, \\"percent\\": %s, \\"mount\\": \\"%s\\"}\\n", $1, $2, $3, $4, $5, $6, $7}'`);
    const disks = diskRaw.split('\n').filter(Boolean).map(l => { try { return JSON.parse(l); } catch { return null; } }).filter(Boolean);

    const largeDirsRaw = await safeExec(`du -h --max-depth=1 / 2>/dev/null | sort -rh | head -15`);
    const largeDirs = largeDirsRaw.split('\n').filter(Boolean).map(line => {
      const parts = line.split('\t');
      return { size: parts[0]?.trim(), path: parts[1] };
    });

    res.json({ ok: true, data: { disks, largeDirs } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==================== NETWORK ====================

app.get('/network', async (req, res) => {
  try {
    const trafficRaw = await safeExec(`cat /proc/net/dev | awk 'NR>2{gsub(/:/, " "); printf "{\\"interface\\": \\"%s\\", \\"rx_bytes\\": %s, \\"tx_bytes\\": %s}\\n", $1, $2, $10}'`);
    const interfaces = trafficRaw.split('\n').filter(Boolean).map(l => { try { return JSON.parse(l); } catch { return null; } }).filter(Boolean);
    const connections = await safeExec(`ss -tunlp 2>/dev/null | head -30`).catch(() => '');
    res.json({ ok: true, data: { interfaces, connections } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==================== PROCESSES ====================

app.get('/processes', async (req, res) => {
  try {
    const raw = await safeExec(`ps aux --sort=-%cpu | head -21`);
    const lines = raw.split('\n').filter(Boolean);
    const processes = lines.slice(1).map(line => {
      const p = line.trim().split(/\s+/);
      return { user: p[0], pid: p[1], cpu: p[2], mem: p[3], vsz: p[4], rss: p[5], command: p.slice(10).join(' ') };
    });
    res.json({ ok: true, data: processes });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==================== SERVICES ====================

const ALLOWED_SERVICES = ['nginx', 'mongod', 'mongodb', 'redis-server', 'ssh', 'pm2'];
const ALLOWED_ACTIONS = ['start', 'stop', 'restart', 'status'];

app.get('/services', async (req, res) => {
  try {
    const [nginx, mongodb, redis] = await Promise.all([
      safeExec('systemctl is-active nginx 2>/dev/null || echo "not-installed"'),
      safeExec('systemctl is-active mongod 2>/dev/null || systemctl is-active mongodb 2>/dev/null || echo "not-installed"'),
      safeExec('systemctl is-active redis-server 2>/dev/null || echo "not-installed"')
    ]);
    res.json({ ok: true, data: { nginx: nginx.trim(), mongodb: mongodb.trim(), redis: redis.trim() } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/services/control', async (req, res) => {
  try {
    const { service, action } = req.body;
    if (!ALLOWED_SERVICES.includes(service)) return res.status(400).json({ error: 'Service not allowed' });
    if (!ALLOWED_ACTIONS.includes(action)) return res.status(400).json({ error: 'Action not allowed' });
    const result = await safeExec(`systemctl ${action} ${service} 2>&1`, 30000);
    res.json({ ok: true, data: { result } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==================== PM2 ====================

app.get('/pm2', async (req, res) => {
  try {
    const raw = await safeExec('pm2 jlist 2>/dev/null || echo "[]"');
    const processes = JSON.parse(raw);
    res.json({ ok: true, data: processes });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/pm2/action', async (req, res) => {
  try {
    const { name, action } = req.body;
    if (!name || !['restart', 'stop', 'start'].includes(action)) {
      return res.status(400).json({ error: 'Invalid name or action' });
    }
    const safeName = name.replace(/[^a-zA-Z0-9_-]/g, '');
    const result = await safeExec(`pm2 ${action} ${safeName} 2>&1`, 15000);
    res.json({ ok: true, data: { result } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==================== LOGS ====================

app.get('/logs', async (req, res) => {
  try {
    const { type = 'system', lines = 100 } = req.query;
    const logCmds = {
      system: `journalctl --no-pager -n ${lines} --output=short-iso 2>/dev/null || tail -n ${lines} /var/log/syslog 2>/dev/null`,
      nginx: `tail -n ${lines} /var/log/nginx/access.log 2>/dev/null || journalctl -u nginx --no-pager -n ${lines} 2>/dev/null`,
      nginxError: `tail -n ${lines} /var/log/nginx/error.log 2>/dev/null || journalctl -u nginx --no-pager -n ${lines} -p err 2>/dev/null`,
      pm2: `pm2 logs --nostream --lines ${lines} 2>/dev/null || echo "PM2 not available"`,
      auth: `tail -n ${lines} /var/log/auth.log 2>/dev/null || journalctl -u sshd --no-pager -n ${lines} 2>/dev/null`
    };
    const cmd = logCmds[type] || logCmds.system;
    const logs = await safeExec(cmd, 30000);
    res.json({ ok: true, data: { logs, type } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==================== FILE MANAGER ====================

// Blocked paths - never allow access to these
const BLOCKED_PATHS = [
  '/proc', '/sys', '/dev', '/boot', '/lib', '/lib64',
  '/sbin', '/bin', '/usr', '/etc/shadow', '/etc/passwd'
];

function isBlocked(p) {
  const normalized = p.replace(/\/+$/, '');
  return BLOCKED_PATHS.some(b => normalized === b || normalized.startsWith(b + '/'));
}

app.get('/files', async (req, res) => {
  try {
    let { path: dirPath = '/home' } = req.query;
    dirPath = dirPath.replace(/[^a-zA-Z0-9/._-]/g, '');
    if (isBlocked(dirPath)) return res.status(403).json({ error: 'Access denied' });

    const raw = await safeExec(`ls -la "${dirPath}" 2>/dev/null || echo "DIR_NOT_FOUND"`, 10000);
    if (raw.includes('DIR_NOT_FOUND')) return res.json({ ok: true, data: { path: dirPath, items: [], error: 'Directory not found' } });

    const lines = raw.split('\n').filter(Boolean);
    const items = [];
    for (let i = 1; i < lines.length; i++) {
      const parts = lines[i].trim().split(/\s+/);
      if (parts.length < 8) continue;
      const name = parts.slice(8).join(' ');
      if (name === '.' || name === '..') continue;
      const isDir = parts[0].startsWith('d');
      items.push({
        name,
        isDirectory: isDir,
        permissions: parts[0],
        size: parseInt(parts[4]) || 0,
        modified: `${parts[5]} ${parts[6]} ${parts[7]}`,
        path: dirPath === '/' ? `/${name}` : `${dirPath}/${name}`
      });
    }
    res.json({ ok: true, data: { path: dirPath, items } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/files/read', async (req, res) => {
  try {
    let { path: filePath } = req.query;
    if (!filePath) return res.status(400).json({ error: 'Path required' });
    filePath = filePath.replace(/[^a-zA-Z0-9/._-]/g, '');
    if (isBlocked(filePath)) return res.status(403).json({ error: 'Access denied' });

    // Check file type
    const typeResult = await safeExec(`file "${filePath}" 2>/dev/null`);
    const isText = /text|ASCII|UTF-8|empty|JSON|XML|config|script|source/.test(typeResult);
    if (!isText) return res.json({ ok: true, data: { path: filePath, content: null, error: 'Not a text file', type: typeResult } });

    // Check size
    const sizeStr = await safeExec(`stat -c%s "${filePath}" 2>/dev/null || echo "0"`);
    const size = parseInt(sizeStr) || 0;
    if (size > 5 * 1024 * 1024) return res.json({ ok: true, data: { path: filePath, content: null, error: 'File too large (>5MB)' } });

    const content = await safeExec(`cat "${filePath}"`, 15000);
    res.json({ ok: true, data: { path: filePath, content, size } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/files/write', async (req, res) => {
  try {
    let { path: filePath, content } = req.body;
    if (!filePath || content === undefined) return res.status(400).json({ error: 'Path and content required' });
    filePath = filePath.replace(/[^a-zA-Z0-9/._-]/g, '');
    if (isBlocked(filePath)) return res.status(403).json({ error: 'Access denied' });

    // Backup first
    await safeExec(`cp "${filePath}" "${filePath}.bak" 2>/dev/null`).catch(() => {});

    // Write using printf (safer than heredoc)
    const escaped = content.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\$/g, '\\$').replace(/`/g, '\\`');
    await safeExec(`printf "%s" "${escaped}" > "${filePath}"`, 15000);
    res.json({ ok: true, data: { path: filePath, success: true } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/files/mkdir', async (req, res) => {
  try {
    let { path: dirPath } = req.body;
    if (!dirPath) return res.status(400).json({ error: 'Path required' });
    dirPath = dirPath.replace(/[^a-zA-Z0-9/._-]/g, '');
    if (isBlocked(dirPath)) return res.status(403).json({ error: 'Access denied' });
    await safeExec(`mkdir -p "${dirPath}"`, 10000);
    res.json({ ok: true, data: { path: dirPath, success: true } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/files/delete', async (req, res) => {
  try {
    let { path: targetPath } = req.body;
    if (!targetPath) return res.status(400).json({ error: 'Path required' });
    targetPath = targetPath.replace(/[^a-zA-Z0-9/._-]/g, '');
    if (isBlocked(targetPath)) return res.status(403).json({ error: 'Access denied - system path' });

    // Extra protection for /root
    const normalized = targetPath.replace(/\/+$/, '');
    if (normalized === '/root' || normalized.startsWith('/root/')) {
      return res.status(403).json({ error: 'Access denied - root home' });
    }

    await safeExec(`rm -rf "${targetPath}"`, 15000);
    res.json({ ok: true, data: { path: targetPath, success: true } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/files/rename', async (req, res) => {
  try {
    let { oldPath, newPath } = req.body;
    if (!oldPath || !newPath) return res.status(400).json({ error: 'Both paths required' });
    oldPath = oldPath.replace(/[^a-zA-Z0-9/._-]/g, '');
    newPath = newPath.replace(/[^a-zA-Z0-9/._-]/g, '');
    if (isBlocked(oldPath) || isBlocked(newPath)) return res.status(403).json({ error: 'Access denied' });
    await safeExec(`mv "${oldPath}" "${newPath}"`, 10000);
    res.json({ ok: true, data: { oldPath, newPath, success: true } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/files/search', async (req, res) => {
  try {
    let { path: dirPath = '/', query } = req.query;
    if (!query) return res.status(400).json({ error: 'Query required' });
    dirPath = dirPath.replace(/[^a-zA-Z0-9/._-]/g, '');
    const safeQuery = query.replace(/[^a-zA-Z0-9._-]/g, '');
    if (isBlocked(dirPath)) return res.status(403).json({ error: 'Access denied' });
    const result = await safeExec(`find "${dirPath}" -maxdepth 4 -name "*${safeQuery}*" -type f 2>/dev/null | head -50`, 15000);
    const files = result.split('\n').filter(Boolean).map(p => ({ path: p, name: p.split('/').pop() }));
    res.json({ ok: true, data: files });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==================== HEALTH ====================

function determineHealth(data) {
  const issues = [];
  if (data.cpuUsage > 90) issues.push({ level: 'critical', message: 'CPU usage is critical' });
  else if (data.cpuUsage > 80) issues.push({ level: 'warning', message: 'CPU usage is high' });

  if (data.memory?.percent > 90) issues.push({ level: 'critical', message: 'Memory usage is critical' });
  else if (data.memory?.percent > 85) issues.push({ level: 'warning', message: 'Memory usage is high' });

  const rootDisk = data.disks?.find(d => d.mount === '/');
  if (rootDisk) {
    if (rootDisk.percent > 90) issues.push({ level: 'critical', message: 'Disk usage is critical' });
    else if (rootDisk.percent > 80) issues.push({ level: 'warning', message: 'Disk usage is high' });
  }

  if (issues.length === 0) return { status: 'healthy', issues: [] };
  if (issues.some(i => i.level === 'critical')) return { status: 'critical', issues };
  return { status: 'warning', issues };
}

// ==================== START ====================

app.listen(PORT, '127.0.0.1', () => {
  console.log(`Notisboard Server Agent running on 127.0.0.1:${PORT}`);
});
