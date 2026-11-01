"""Run focused real-card regressions against Project Ignis ocgcore API 11."""
import argparse
import ctypes as C
import json
import pathlib
parser=argparse.ArgumentParser(description='Focused real-card ocgcore tests; these are not full duel simulations.')
parser.add_argument('cardscripts',type=pathlib.Path)
parser.add_argument('core',type=pathlib.Path)
args=parser.parse_args()
UP=args.cardscripts.resolve()
REPO=pathlib.Path(__file__).resolve().parents[1]
lib=C.CDLL(str(args.core.resolve()))
major,minor=C.c_int(),C.c_int()
lib.OCG_GetVersion(C.byref(major),C.byref(minor))
if major.value!=11:
    raise SystemExit(f'This runner requires ocgcore API 11, got {major.value}.{minor.value}')
class Data(C.Structure):_fields_=[('code',C.c_uint32),('alias',C.c_uint32),('setcodes',C.POINTER(C.c_uint16)),('type',C.c_uint32),('level',C.c_uint32),('attribute',C.c_uint32),('race',C.c_uint64),('attack',C.c_int32),('defense',C.c_int32),('lscale',C.c_uint32),('rscale',C.c_uint32),('link_marker',C.c_uint32)]
class Player(C.Structure):_fields_=[('startingLP',C.c_uint32),('startingDrawCount',C.c_uint32),('drawCountPerTurn',C.c_uint32)]
DR=C.CFUNCTYPE(None,C.c_void_p,C.c_uint32,C.POINTER(Data));SR=C.CFUNCTYPE(C.c_int,C.c_void_p,C.c_void_p,C.c_char_p);LH=C.CFUNCTYPE(None,C.c_void_p,C.c_char_p,C.c_int);DD=C.CFUNCTYPE(None,C.c_void_p,C.POINTER(Data))
class Options(C.Structure):_fields_=[('seed',C.c_uint64*4),('flags',C.c_uint64),('team1',Player),('team2',Player),('cardReader',DR),('payload1',C.c_void_p),('scriptReader',SR),('payload2',C.c_void_p),('logHandler',LH),('payload3',C.c_void_p),('cardReaderDone',DD),('payload4',C.c_void_p),('enableUnsafeLibraries',C.c_uint8)]
lib.OCG_CreateDuel.argtypes=[C.POINTER(C.c_void_p),C.POINTER(Options)];lib.OCG_DestroyDuel.argtypes=[C.c_void_p];lib.OCG_LoadScript.argtypes=[C.c_void_p,C.c_char_p,C.c_uint32,C.c_char_p];lib.OCG_LoadScript.restype=C.c_int
cards={c['id']:c for c in json.loads((REPO/'database/cards.json').read_text())};codes=(C.c_uint16*2)(0x1f99,0);errors=[]
@DR
def dataread(payload,code,p):
 c=cards.get(code,dict(id=code,type=0x81,atk=1000,**{'def':1000},level=8,race=1,attribute=1));d=p.contents
 d.code=code;d.type=c['type'];d.level=c['level'];d.race=c['race'];d.attribute=c['attribute'];d.attack=c['atk'];d.defense=c['def'];d.setcodes=codes if code in cards else C.POINTER(C.c_uint16)()
@SR
def scriptread(payload,duel,name):
 n=name.decode()
 for d in [REPO/'script',UP,UP/'official',UP/'unofficial',UP/'pre-release']:
  path=d/n
  if path.is_file():
   b=path.read_bytes();return lib.OCG_LoadScript(duel,b,len(b),name)
 return 0
@LH
def log(payload,s,typ):
 msg=s.decode();print(typ,msg)
 if typ==0:errors.append(msg)
@DD
def done(payload,p):pass

for with_circuit in (False,True):
    errors.clear()
    opt=Options()
    opt.seed[:]=[1,2,3,4]
    opt.team1=opt.team2=Player(8000,0,0)
    opt.cardReader=dataread
    opt.scriptReader=scriptread
    opt.logHandler=log
    opt.cardReaderDone=done
    duel=C.c_void_p()
    result=lib.OCG_CreateDuel(C.byref(duel),C.byref(opt))
    if result!=0:
        raise SystemExit(f'Could not create duel: {result}')
    prefix=f"OG_TEST_WITH_CIRCUIT={'true' if with_circuit else 'false'}\n".encode()
    script=prefix+(REPO/'tests/engine_regression.lua').read_bytes()
    try:
        result=lib.OCG_LoadScript(duel,script,len(script),b'ourogear-engine-regression.lua')
        if result!=1 or errors:
            raise SystemExit(f'Engine regression failed (Circuit={with_circuit}): {errors}')
    finally:
        lib.OCG_DestroyDuel(duel)
print('Both real-engine board scenarios passed.')
