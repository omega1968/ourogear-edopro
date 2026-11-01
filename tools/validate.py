#!/usr/bin/env python3
from pathlib import Path
import ctypes
import glob
import shutil
import sqlite3
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]
EXP=ROOT/'expansion'
CDB=EXP/'ourogear.cdb'
EXPECTED=set(range(21430001,21430022))|{21430099}
SCRIPT_IDS=set(range(21430001,21430022))
errors=[]

# CDB schema/content
try:
    con=sqlite3.connect(CDB)
    cur=con.cursor()
    for table in ('datas','texts'):
        if not cur.execute("SELECT 1 FROM sqlite_master WHERE type='table' AND name=?",(table,)).fetchone():
            errors.append(f'missing CDB table: {table}')
    ids={r[0] for r in cur.execute('SELECT id FROM datas')}
    tids={r[0] for r in cur.execute('SELECT id FROM texts')}
    if ids!=EXPECTED: errors.append(f'datas IDs mismatch: {sorted(EXPECTED^ids)}')
    if tids!=EXPECTED: errors.append(f'texts IDs mismatch: {sorted(EXPECTED^tids)}')
    dup_names=cur.execute('SELECT name,COUNT(*) FROM texts GROUP BY name HAVING COUNT(*)>1').fetchall()
    if dup_names: errors.append(f'duplicate card names: {dup_names}')
    con.close()
except Exception as exc:
    errors.append(f'CDB check failed: {exc}')

# Script coverage
script_dir=EXP/'script'
actual=set()
for p in script_dir.glob('c*.lua'):
    try: actual.add(int(p.stem[1:]))
    except ValueError: errors.append(f'bad script filename: {p.name}')
if actual!=SCRIPT_IDS:
    errors.append(f'script ID mismatch: {sorted(SCRIPT_IDS^actual)}')
if not (script_dir/'ourogear.lua').exists(): errors.append('missing shared script ourogear.lua')

# All individual scripts must load the helper
for cid in SCRIPT_IDS:
    p=script_dir/f'c{cid}.lua'
    if p.exists() and 'Duel.LoadScript("ourogear.lua")' not in p.read_text(encoding='utf-8'):
        errors.append(f'{p.name} does not load shared helper')

# Deck counts and IDs
p=ROOT/'deck'/'Ourogear-Test.ydk'
if not p.exists():
    errors.append('missing test deck')
else:
    sections={'main':[],'extra':[],'side':[]}; cursec=None
    for raw in p.read_text().splitlines():
        line=raw.strip()
        if line=='#main': cursec='main'; continue
        if line=='#extra': cursec='extra'; continue
        if line=='!side': cursec='side'; continue
        if not line or line.startswith('#'): continue
        if cursec: sections[cursec].append(int(line))
    if len(sections['main'])!=40: errors.append(f'main deck count is {len(sections["main"])} not 40')
    if len(sections['extra'])!=15: errors.append(f'extra deck count is {len(sections["extra"])} not 15')
    for cid in sections['main']+sections['extra']+sections['side']:
        if cid not in EXPECTED: errors.append(f'unknown custom ID in test deck: {cid}')

# Lua syntax: prefer luac; fall back to system liblua via ctypes.
lua_files=sorted(script_dir.glob('*.lua'))
luac=shutil.which('luac5.4') or shutil.which('luac')
if luac:
    for f in lua_files:
        cp=subprocess.run([luac,'-p',str(f)],capture_output=True,text=True)
        if cp.returncode: errors.append(f'Lua syntax: {f.name}: {cp.stderr.strip()}')
else:
    libpath=None
    for candidate in ('/lib/x86_64-linux-gnu/liblua5.4.so.0','/usr/lib/x86_64-linux-gnu/liblua5.4.so.0'):
        if Path(candidate).exists(): libpath=candidate; break
    if libpath:
        lib=ctypes.CDLL(libpath)
        lib.luaL_newstate.restype=ctypes.c_void_p
        lib.luaL_loadfilex.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_char_p]
        lib.luaL_loadfilex.restype=ctypes.c_int
        lib.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.POINTER(ctypes.c_size_t)]
        lib.lua_tolstring.restype=ctypes.c_char_p
        lib.lua_close.argtypes=[ctypes.c_void_p]
        for f in lua_files:
            L=lib.luaL_newstate(); rc=lib.luaL_loadfilex(L,str(f).encode(),None)
            if rc:
                n=ctypes.c_size_t(); msg=lib.lua_tolstring(L,-1,ctypes.byref(n))
                errors.append(f'Lua syntax: {f.name}: {(msg or b"unknown").decode(errors="replace")}')
            lib.lua_close(L)
    else:
        print('WARNING: no Lua compiler/runtime available; Lua syntax check skipped')

if errors:
    print('VALIDATION FAILED')
    for err in errors: print(' -',err)
    sys.exit(1)
print(f'VALIDATION OK: {len(EXPECTED)} CDB entries, {len(SCRIPT_IDS)+1} Lua files, 40-card main / 15-card extra test deck')
