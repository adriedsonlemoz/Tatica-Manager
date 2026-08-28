import math
import pathlib
import random
import struct
import subprocess
import tempfile
import wave

ROOT = pathlib.Path(__file__).resolve().parents[1]
SAMPLE_RATE = 22050
DURATION = 12.0


def main():
    rng = random.Random(20260827)
    count = int(SAMPLE_RATE * DURATION)
    samples = []
    smooth = 0.0
    for index in range(count):
        time = index / SAMPLE_RATE
        smooth = smooth * 0.965 + rng.uniform(-1, 1) * 0.035
        murmur = (
            math.sin(2 * math.pi * 83 * time) * 0.10
            + math.sin(2 * math.pi * 127 * time + 1.7) * 0.07
            + math.sin(2 * math.pi * 173 * time + 0.6) * 0.04
        )
        swell = 0.72 + 0.13 * math.sin(2 * math.pi * time / 5.8)
        samples.append((smooth * 0.72 + murmur) * swell)

    crossfade = int(SAMPLE_RATE * 1.2)
    for index in range(crossfade):
        ratio = index / crossfade
        blended = samples[index] * ratio + samples[-crossfade + index] * (1 - ratio)
        samples[index] = blended
        samples[-crossfade + index] = blended

    peak = max(abs(value) for value in samples) or 1
    samples = [value * 0.34 / peak for value in samples]
    destination = ROOT / 'assets/audio/match/stadium_ambience.m4a'
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as temporary:
        wav_path = pathlib.Path(temporary) / 'stadium_ambience.wav'
        with wave.open(str(wav_path), 'wb') as output:
            output.setnchannels(1)
            output.setsampwidth(2)
            output.setframerate(SAMPLE_RATE)
            output.writeframes(
                b''.join(
                    struct.pack('<h', int(max(-1, min(1, value)) * 32767))
                    for value in samples
                ),
            )
        subprocess.run(
            [
                'ffmpeg',
                '-y',
                '-loglevel',
                'error',
                '-i',
                str(wav_path),
                '-c:a',
                'aac',
                '-b:a',
                '56k',
                str(destination),
            ],
            check=True,
        )
    print(destination)


if __name__ == '__main__':
    main()
