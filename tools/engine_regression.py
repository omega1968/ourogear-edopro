"""Run focused real-card regressions against Project Ignis ocgcore API 11."""
import argparse
import ctypes as C
import json
import pathlib
import struct
parser=argparse.ArgumentParser(description='Focused real-card ocgcore tests; these are not full duel simulations.')
parser.add_argument('cardscripts',type=pathlib.Path)
parser.add_argument('core',type=pathlib.Path)
parser.add_argument('--scenario', default='engine_regression.lua')
parser.add_argument('--process', action='store_true')
parser.add_argument('--accept-optional', action='store_true', help='Accept optional trigger effects in the scripted scenario')
parser.add_argument('--token-position',choices=('attack','defense'),default='attack')
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
lib.OCG_StartDuel.argtypes=[C.c_void_p]
lib.OCG_DuelProcess.argtypes=[C.c_void_p]
lib.OCG_DuelGetMessage.argtypes=[C.c_void_p,C.POINTER(C.c_uint32)]
lib.OCG_DuelGetMessage.restype=C.c_void_p
lib.OCG_DuelSetResponse.argtypes=[C.c_void_p,C.c_void_p,C.c_uint32]
cards={c['id']:c for c in json.loads((REPO/'database/cards.json').read_text())};archetype_codes=(C.c_uint16*2)(0x1f99,0);errors=[]; messages=[]
@DR
def dataread(payload,code,p):
 c=cards.get(code,dict(id=code,type=0x81,atk=1000,**{'def':1000},level=8,race=1,attribute=1));d=p.contents
 d.code=code;d.type=c['type'];d.level=c['level'];d.race=c['race'];d.attribute=c['attribute'];d.attack=c['atk'];d.defense=c['def'];d.setcodes=archetype_codes if code in cards else C.POINTER(C.c_uint16)()
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
 msg=s.decode();print(typ,msg);messages.append(msg)
 if typ==0:errors.append(msg)
@DD
def done(payload,p):pass

for variant in (False,True):
    errors.clear()
    messages.clear()
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
    prefix=f"OG_TEST_VARIANT={'true' if variant else 'false'}\nOG_TEST_TOKEN_POSITION='{args.token_position}'\n".encode()
    script=prefix+(REPO/'tests'/args.scenario).read_bytes()
    try:
        result=lib.OCG_LoadScript(duel,script,len(script),b'ourogear-engine-regression.lua')
        if result!=1 or errors:
            raise SystemExit(f'Engine regression failed (variant={variant}): {errors}')
        if args.process:
            lib.OCG_StartDuel(duel)
            for _ in range(256):
                status=lib.OCG_DuelProcess(duel)
                size=C.c_uint32()
                ptr=lib.OCG_DuelGetMessage(duel,C.byref(size))
                data=C.string_at(ptr,size.value)
                packets=[]
                offset=0
                while offset<len(data):
                    length=struct.unpack_from('<I',data,offset)[0]
                    packets.append(data[offset+4:offset+4+length])
                    offset+=4+length
                if errors:
                    raise SystemExit(f'Engine action error: {errors}')
                if any(m.startswith('PASS actions:') for m in messages):
                    break
                if status==0:
                    raise SystemExit('Duel ended before action assertions completed')
                if status==1:
                    packet=packets[-1]
                    if args.scenario.startswith('engine_harness_'):
                        print(f'PROMPT {packet.hex()}')
                    if packet[0]==18:
                        player,count,blocked=struct.unpack_from('<BBI',packet,1)
                        assert count==1
                        if blocked & 0x1f00:  # Select a free Spell/Trap Zone for effect-based equips.
                            mask=(blocked>>8)&0x1f
                            seq=next(i for i in range(5) if not mask&(1<<i))
                            response=bytes([player,4,seq])
                        else:
                            seq=next(i for i in range(7) if not blocked&(1<<i))
                            response=bytes([player,4,seq])
                    elif packet[0]==16 and packet[3]==0:
                        response=struct.pack('<i',0 if args.accept_optional and packet[2]>0 else -1)  # Accept an offered trigger; pass when none are available.
                    elif packet[0]==11:  # Activate the test-only ignition effect.
                        offset=2
                        for entry_size in (10,10,7,10,10):
                            count=struct.unpack_from('<I',packet,offset)[0]
                            offset+=4+count*entry_size
                        count=struct.unpack_from('<I',packet,offset)[0]
                        offset+=4
                        found=[i for i in range(count) if struct.unpack_from('<Q',packet,offset+i*19+10)[0]==0x7fffff]
                        assert len(found)==1,'test-only ignition effect unavailable'
                        response=struct.pack('<I',(found[0]<<16)|5)
                    elif packet[0]==1:  # Core reports the previous response was invalid.
                        raise SystemExit(f'Engine rejected previous response before prompt: {packet.hex()}')
                        assert packet[5]>0 and packet[3]>0
                        response=struct.pack('<II',1,0)
                    elif packet[0]==15:  # The test requires every offered material.
                        minimum,maximum,count=struct.unpack_from('<III',packet,3)
                        assert minimum==maximum
                        if minimum<count:
                            offered_codes=[struct.unpack_from('<I',packet,15+i*14)[0] for i in range(count)]
                            assert len(set(offered_codes))==1,'ambiguous material choice in fixture'
                        response=struct.pack('<II',0,minimum)+b''.join(struct.pack('<I',i) for i in range(minimum))
                    elif packet[0]==23:  # This fixture's Ritual uses all offered Tokens.
                        mandatory=struct.unpack_from('<I',packet,15)[0]
                        assert mandatory==0
                        count=struct.unpack_from('<I',packet,19)[0]
                        offered_codes=[struct.unpack_from('<I',packet,23+i*18)[0] for i in range(count)]
                        assert count in (1,2) and all(code==990071099 for code in offered_codes)
                        response=struct.pack('<II',0,count)+b''.join(struct.pack('<I',i) for i in range(count))
                    elif packet[0]==12:  # The declining-Loom test chooses not to replace.
                        response=struct.pack('<I',0)
                    elif packet[0]==19:  # Fixed test choice: face-up Attack Position.
                        response=struct.pack('<I',4 if args.token_position=='defense' else 1)
                    else:
                        raise SystemExit(f'Unexpected action-test prompt: {packet.hex()}')
                    buf=C.create_string_buffer(response)
                    lib.OCG_DuelSetResponse(duel,buf,len(response))
            else:
                raise SystemExit('Action test exceeded processing limit')
    finally:
        lib.OCG_DestroyDuel(duel)
print('Both real-engine board scenarios passed.')
