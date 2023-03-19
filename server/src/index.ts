import type { WebSocket } from 'ws';
import express from 'express';
import * as crypto from 'crypto'
import ews from 'express-ws';
import proxy from 'express-http-proxy';
import { copyFileSync, existsSync } from 'fs';
import path from 'path';

if (!existsSync('.env')) copyFileSync('.env.example', '.env')

require('dotenv').config()

const ws = ews(express());
const app = ws.app;

const connections: Record<string, WebSocket[]> = {}
let activeConnections = 0;
app.ws('/c/:code', (ws, req) => {
  if (!req.params.code) return ws.close(400, 'No Code')
  const code = req.params.code.trim()
  connections[code] = connections[code] ? connections[code].filter(v => v.readyState === v.OPEN) : [];
  if (connections[code].length > 6) {
    console.log('Blocked Connection');
    ws.send('notif:Too many connections!')
    ws.send('exec:pcall(messagebox,\'Too many connections! Try again later!\')')
    setTimeout(() => ws.close(), 10)
    return
  }
  console.log('Connection Started: ' + code);
  connections[code].push(ws)
  ws.on('message', (msg, isBin) => {
    if (isBin) return ws.close(400, 'Cannot send binary data')
    const msgAsStr = msg.toString()
    if (msgAsStr == 'keepalive') return ws.send('keepalive')
    if (msgAsStr.length > 69000) return ws.close(400, 'Too much data sent! Chill the FUCK Out. This ain\'t free real estate!!!')
    connections[code].filter(v => v !== ws).forEach(v => v.send(msgAsStr))
  })
  activeConnections++;
  ws.on('close', () => activeConnections--)
  ws.on('error', (err) => console.warn(err))
  ws.send('+READY+')
});

app.use('/c/*', (rq, rs) => rs.send('Failed to connect to Socket (Attemtped non-socket connection to /c/*?)'))

app.use('/active-connections', (rq, rs) => rs.send(activeConnections.toString()))

const random = (length = 8) => {
  // Declare all characters
  let chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  // Pick characers randomly
  let str = '';
  for (let i = 0; i < length; i++) {
    str += chars.charAt(Math.floor(Math.random() * chars.length));
  }

  return str;
};
const hash = (val: string) => crypto.createHash('SHA512').update(val).digest('hex')
const sessionKey = hash(random(64))
app.use('/get-connection-code', (rq, rs) => {
  const getHashed = (header: string) => {
    const h = rq.get(header)
    return h ? hash(h) : null;
  }
  const header = getHashed('X-Client-Ip') ?? getHashed('Fluxus-Fingerprint') ?? getHashed('SW-Fingerprint') ?? getHashed('SW-User-Identifier') ?? getHashed('Fingerprint') ?? getHashed('Syn-Fingerprint')
  let code: string;
  if (rq.get('host')?.match(/(localhost|127\.0\.0\.1)/gui))
    code = 'astolfoaim-local'
  else if (header)
    code = (crypto.createHmac('SHA512', sessionKey).update(header).digest('hex').substring(0, 12))
  else
    code = (random(16))
  rs.set('Access-Control-Allow-Origin', '*')
  if (rq.query.onlyIfExists && (connections[code] ?? []).length === 0) rs.send('!code!')
  else rs.send(code)
})
app.use((rq, rs, nx) => {
  rs.set('Cache-Control', 'public, max-age=2592000')
  nx();
})
const staticDir = path.resolve(process.cwd(), '..', 'web', 'build')
if (existsSync(staticDir))
  app.use(express.static(staticDir))
else
  console.warn('No static dir, will only proxy');
app.use(proxy(process.env.STATIC_SITE ?? 'https://aim.femboy.cafe/'))

app.listen(5595, () => console.log('Listening on port 5595'))
