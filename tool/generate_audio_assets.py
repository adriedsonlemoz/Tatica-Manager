import math, random, wave, struct, subprocess, os, pathlib
ROOT = pathlib.Path(__file__).resolve().parents[1]
SR=22050

def clamp(x): return max(-1.0,min(1.0,x))

def write_wav(path, samples, sr=SR):
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path),'w') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(sr)
        frames=b''.join(struct.pack('<h', int(clamp(s)*32767)) for s in samples)
        w.writeframes(frames)

def env(t,d,attack=.01,release=.08):
    if t<0 or t>d: return 0
    a=min(1,t/max(attack,1e-6)); r=min(1,(d-t)/max(release,1e-6)); return max(0,min(a,r))

def tone(duration, freqs, amps=None, noise=0, sweep=0, attack=.01, release=.1, seed=1):
    rng=random.Random(seed); amps=amps or [1/len(freqs)]*len(freqs); out=[]
    n=int(duration*SR)
    for i in range(n):
        t=i/SR; e=env(t,duration,attack,release); v=0
        for f,a in zip(freqs,amps):
            ff=f*(1+sweep*(t/duration-.5))
            v += a*math.sin(2*math.pi*ff*t)
        v += noise*rng.uniform(-1,1)
        out.append(v*e)
    return out

def mix(parts, duration=None):
    if duration is None: duration=max((off+len(s)/SR for off,s,g in parts), default=0)
    out=[0.0]*int(duration*SR)
    for off,s,g in parts:
        start=int(off*SR)
        for i,v in enumerate(s):
            j=start+i
            if j<len(out): out[j]+=v*g
    m=max((abs(x) for x in out), default=1)
    if m>.94: out=[x*(.94/m) for x in out]
    return out

def whistle(pattern='single'):
    if pattern=='single':
        return tone(.52,[1850,3700],[.8,.16],noise=.01,sweep=.05,attack=.02,release=.12)
    if pattern=='double':
        return mix([(0,tone(.28,[1800,3600],[.8,.14],sweep=.03),.9),(.38,tone(.32,[1920,3840],[.8,.14],sweep=-.03),.9)],.78)
    return mix([(0,tone(.22,[1820,3640],[.8,.14]),.85),(.31,tone(.22,[1980,3960],[.8,.14]),.85),(.62,tone(.44,[1700,3400],[.8,.14],sweep=-.05),.9)],1.18)

def crowd(duration=1.4, seed=3, peak=.55):
    rng=random.Random(seed); out=[]
    for i in range(int(duration*SR)):
        t=i/SR
        e=(math.sin(math.pi*t/duration)**.7)
        # filtered-ish noise by blending slow oscillations
        n=.42*rng.uniform(-1,1)+.22*math.sin(2*math.pi*97*t)+.12*math.sin(2*math.pi*131*t)
        out.append(n*e*peak)
    return out

def click(freq=720,d=.07): return tone(d,[freq,freq*1.5],[.55,.18],noise=.02,attack=.002,release=.05)

# UI
write_wav(ROOT/'assets/audio/ui/tap.wav', click(640,.055))
write_wav(ROOT/'assets/audio/ui/navigation.wav', mix([(0,click(520,.07),.7),(.055,click(780,.08),.5)],.16))
write_wav(ROOT/'assets/audio/ui/confirm.wav', mix([(0,tone(.16,[523,784],[.42,.18],attack=.004,release=.08),.75),(.11,tone(.22,[659,988],[.4,.16],attack=.004,release=.12),.65)],.36))

# Match SFX
write_wav(ROOT/'assets/audio/match/kickoff.wav', whistle('single'))
write_wav(ROOT/'assets/audio/match/halftime.wav', whistle('double'))
write_wav(ROOT/'assets/audio/match/second_half.wav', whistle('single'))
write_wav(ROOT/'assets/audio/match/fulltime.wav', whistle('triple'))
write_wav(ROOT/'assets/audio/match/goal.wav', mix([(0,crowd(1.75,11,.7),.85),(.10,tone(.33,[880,1320],[.5,.22],attack=.01,release=.2),.26)],1.8))
write_wav(ROOT/'assets/audio/match/foul.wav', mix([(0,whistle('single'),.8),(.18,crowd(.8,13,.28),.25)],.95))
write_wav(ROOT/'assets/audio/match/yellow_card.wav', mix([(0,click(410,.08),.48),(.08,tone(.22,[690,1035],[.35,.14],attack=.005,release=.12),.38)],.35))
write_wav(ROOT/'assets/audio/match/red_card.wav', mix([(0,tone(.18,[235,352],[.52,.2],attack=.004,release=.12),.7),(.14,tone(.32,[185,277],[.5,.18],attack=.004,release=.2),.72)],.5))
write_wav(ROOT/'assets/audio/match/substitution.wav', mix([(0,tone(.11,[440,660],[.45,.16],attack=.004,release=.06),.55),(.12,tone(.15,[554,831],[.42,.15],attack=.004,release=.08),.58)],.32))
write_wav(ROOT/'assets/audio/match/shot.wav', tone(.13,[95,155],[.55,.22],noise=.13,sweep=.35,attack=.002,release=.11))
write_wav(ROOT/'assets/audio/match/save.wav', mix([(0,tone(.12,[120,240],[.45,.16],noise=.09,attack=.002,release=.09),.75),(.08,crowd(.5,17,.18),.18)],.56))
write_wav(ROOT/'assets/audio/match/woodwork.wav', mix([(0,tone(.18,[620,1240,1860],[.48,.28,.13],attack=.001,release=.16),.82),(.06,crowd(.65,19,.22),.18)],.72))
write_wav(ROOT/'assets/audio/match/penalty.wav', mix([(0,tone(.4,[165,220],[.28,.16],attack=.05,release=.16),.45),(.31,whistle('single'),.6)],.9))
write_wav(ROOT/'assets/audio/match/penalty_saved.wav', mix([(0,tone(.12,[115,230],[.48,.16],noise=.08,attack=.002,release=.1),.65),(.05,crowd(1.05,23,.55),.55)],1.08))
write_wav(ROOT/'assets/audio/match/injury.wav', mix([(0,tone(.34,[260,390],[.26,.12],attack=.015,release=.22),.55),(.2,tone(.38,[220,330],[.24,.1],attack=.01,release=.25),.45)],.7))

# 5 original menu loops: gentle pad/pluck patterns.
chords = [
    ([220.0, 277.18, 329.63], [246.94,311.13,369.99], [196.0,246.94,293.66], [220.0,277.18,329.63]),
    ([196.0,246.94,293.66], [174.61,220.0,261.63], [220.0,261.63,329.63], [196.0,246.94,293.66]),
    ([261.63,329.63,392.0], [220.0,277.18,329.63], [233.08,293.66,349.23], [196.0,246.94,293.66]),
    ([174.61,220.0,261.63], [196.0,246.94,293.66], [146.83,196.0,246.94], [174.61,220.0,261.63]),
    ([233.08,293.66,349.23], [261.63,329.63,392.0], [220.0,277.18,329.63], [233.08,293.66,349.23]),
]
for idx, prog in enumerate(chords,1):
    duration=20.0; out=[0.0]*int(duration*SR); rng=random.Random(100+idx)
    seg=duration/4
    for ci,ch in enumerate(prog):
        start=ci*seg
        # pad with gentle tremolo
        for i in range(int(seg*SR)):
            t=i/SR; gt=start+t
            edge=min(1,t/.7,(seg-t)/.8); edge=max(0,edge)
            v=0
            for j,f in enumerate(ch):
                v += (0.085/(j+1)**.2)*math.sin(2*math.pi*f*t + j*.4)
                v += 0.025*math.sin(2*math.pi*(f/2)*t + j)
            v *= edge*(.9+.1*math.sin(2*math.pi*.18*gt+idx))
            out[int(start*SR)+i]+=v
        # sparse soft plucks
        for beat in range(8):
            pstart=start + beat*(seg/8) + (0.06 if beat%2 else 0)
            f=ch[(beat+idx)%len(ch)]*2
            plen=.55
            for i in range(int(plen*SR)):
                t=i/SR; j=int(pstart*SR)+i
                if j>=len(out): break
                e=math.exp(-5.2*t)
                out[j]+=0.055*e*(math.sin(2*math.pi*f*t)+.32*math.sin(2*math.pi*f*2*t))
    # tiny texture, fade ends for safer loop
    for i in range(len(out)):
        t=i/SR; out[i]+=rng.uniform(-1,1)*0.002
        fade=min(1,t/.35,(duration-t)/.35); out[i]*=max(0,fade)
    m=max(abs(x) for x in out); out=[x*(.58/m) for x in out]
    wav=ROOT/f'/tmp/menu_{idx:02d}.wav'
    write_wav(wav,out)
    m4a=ROOT/f'assets/audio/menu/menu_{idx:02d}.m4a'
    subprocess.run(['ffmpeg','-y','-loglevel','error','-i',str(wav),'-c:a','aac','-b:a','72k',str(m4a)],check=True)
    wav.unlink()
print('generated')
