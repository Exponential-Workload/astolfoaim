import * as fs from 'fs';
import * as path from 'path';
const luamin = require('luamin')
const f = (...p:string[])=>path.resolve(__dirname,...p)
if (!fs.existsSync('_pages')) fs.mkdirSync('_pages')
fs.readdirSync(f('..', 'script')).forEach(v => fs.writeFileSync(f('_pages', v), (v.endsWith('.lua') ? (a: string) => `-- AstolfoAim @ ${fs.readFileSync(f('..','.git',fs.readFileSync(f('..','.git','HEAD'),'utf-8').replace('ref: ','').trim()),'utf-8').trim()}
-- AGPLv3 | https://github.com/YieldingExploiter/astolfoaim/blob/main/script/${v}

${luamin.minify(a)}`: (a: string) => a)(fs.readFileSync(f('..', 'script', v), 'utf-8'))))
fs.readdirSync(f('base')).forEach(v => fs.copyFileSync(f('base', v), f('_pages', v)))
