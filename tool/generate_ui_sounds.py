"""Generate short, quiet WAV chimes for Alamiyah UI feedback."""

from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 22050
OUT = Path(__file__).resolve().parents[1] / "assets" / "sounds"


def write_wav(name: str, samples: list[float]) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / name
    with wave.open(str(path), "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        frames = b"".join(
            struct.pack("<h", max(-32767, min(32767, int(s * 32767))))
            for s in samples
        )
        wf.writeframes(frames)
    print(f"wrote {path} ({len(samples)} samples)")


def env(i: int, n: int, attack: float = 0.02, decay_exp: float = 4.0) -> float:
    t = i / n
    a = min(1.0, t / attack) if attack > 0 else 1.0
    return a * math.exp(-decay_exp * t)


def tone(freq: float, seconds: float, volume: float, decay: float = 4.5) -> list[float]:
    n = int(SAMPLE_RATE * seconds)
    return [
        volume * env(i, n, decay_exp=decay) * math.sin(2 * math.pi * freq * i / SAMPLE_RATE)
        for i in range(n)
    ]


def mix(*tracks: list[float]) -> list[float]:
    length = max(len(t) for t in tracks)
    out = [0.0] * length
    for t in tracks:
        for i, s in enumerate(t):
            out[i] += s
    peak = max((abs(s) for s in out), default=1.0) or 1.0
    if peak > 0.95:
        out = [s * 0.95 / peak for s in out]
    return out


def droplet() -> list[float]:
    n = int(SAMPLE_RATE * 0.42)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        freq = 980 - 520 * t
        samples.append(
            0.22 * env(i, n, attack=0.01, decay_exp=6.5) * math.sin(2 * math.pi * freq * t)
        )
    return samples


def swoosh() -> list[float]:
    n = int(SAMPLE_RATE * 0.16)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        freq = 420 + 380 * (i / n)
        samples.append(
            0.12 * env(i, n, attack=0.02, decay_exp=10) * math.sin(2 * math.pi * freq * t)
        )
    return samples


def main() -> None:
    write_wav("tick.wav", tone(1180, 0.07, 0.16, decay=14))
    write_wav(
        "settle.wav",
        mix(tone(523.25, 0.28, 0.14, decay=5.5), tone(784.0, 0.22, 0.10, decay=7)),
    )
    write_wav("chime_droplet.wav", droplet())
    write_wav(
        "chime_wind.wav",
        mix(
            tone(392.0, 0.55, 0.12, decay=3.2),
            tone(493.88, 0.48, 0.09, decay=3.8),
            tone(587.33, 0.40, 0.05, decay=4.5),
        ),
    )
    write_wav(
        "chime_bell.wav",
        mix(
            tone(523.25, 0.48, 0.12, decay=3.4),
            tone(659.25, 0.42, 0.08, decay=4.0),
            tone(784.0, 0.36, 0.06, decay=5.0),
        ),
    )
    write_wav("swoosh.wav", swoosh())
    write_wav(
        "confirm.wav",
        mix(tone(392.0, 0.18, 0.12, decay=8), tone(587.33, 0.22, 0.11, decay=6.5)),
    )


if __name__ == "__main__":
    main()
