"""
mouse_bot.py
Autor: Selvin + ChatGPT

Uso ultra simple de duración:
  - Cambia esta línea y listo:  DURATION = "2h30m"  (o "10m", "90s", "4h")
  - O pásala por consola:  py mouse_bot.py --for 2h30m

Formatos válidos:
  "45s"  | "10m"  | "2h"  | "1h30m"  | "2h5m40s"  | "600" (segundos)
  (combinaciones con h/m/s en cualquier orden; números enteros)

Modo cooperativo:
  - Si mueves el mouse, el bot PAUSA.
  - Cuando sueltas el mouse por 'idle_seconds', RESUME su ruta.
  - FAILSAFE: mover el mouse a la esquina superior izquierda (0,0) aborta el script.

Ruta:
  - Mueve entre A y B alrededor del centro (offset_x=300), 5 s por tramo.
  - En B: clic derecho; en A: clic izquierdo.
"""

from __future__ import annotations
import re
import time
import math
import argparse
from dataclasses import dataclass
from typing import Tuple

import pyautogui

# ===================== CONFIG RÁPIDA (edita solo esto si querés) =====================
DURATION = "8h"  # <-- Cambia aquí: "45s", "10m", "2h", "1h30m", "2h5m40s", "600" (segundos)
# =====================================================================================

# Configuración global de PyAutoGUI
pyautogui.FAILSAFE = True
pyautogui.PAUSE = 0.00  # controlamos nosotros los tiempos finos


# -------- Utilidad: parseo de duración "humana" ("2h30m", "10m", "90s", "600") --------
def parse_duration_to_seconds(value: str) -> float:
    """
    Convierte strings como "2h30m", "10m", "45s", "1h", "2h5m40s", "600" a segundos (float).
    Permite unidades en cualquier orden. Si es número puro, asume segundos.
    """
    s = value.strip().lower()
    if re.fullmatch(r"\d+", s):
        return float(int(s))  # segundos directos

    total = 0
    for number, unit in re.findall(r"(\d+)\s*([hms])", s):
        n = int(number)
        if unit == "h":
            total += n * 3600
        elif unit == "m":
            total += n * 60
        elif unit == "s":
            total += n
    if total <= 0:
        raise ValueError(f"Duración inválida: '{value}'. Usa formatos como '10m', '2h', '1h30m', '90s'.")
    return float(total)


@dataclass
class BotConfig:
    # Duraciones / distancias base
    duration_seconds: float = 120.0  # SOBREESCRITO por DURATION o --for
    offset_x: int = 300              # distancia horizontal desde el centro a A y B
    offset_y: int = 0                # distancia vertical desde el centro
    move_duration: float = 5.0       # segundos por tramo (A->B o B->A)
    pause_between: float = 0.10      # pausa tras cada clic

    # Modo cooperativo
    idle_seconds: float = 0.8        # tiempo sin movimiento del usuario para reanudar
    drift_tolerance: float = 25.0    # px de tolerancia para considerar que tomaste control

    countdown: int = 3               # cuenta regresiva antes de iniciar

    def validate(self) -> None:
        if self.duration_seconds <= 0:
            raise ValueError("La duración total debe ser > 0 s")
        if self.move_duration < 0:
            raise ValueError("move_duration no puede ser negativo")
        if self.pause_between < 0:
            raise ValueError("pause_between no puede ser negativo")
        if self.countdown < 0:
            raise ValueError("countdown no puede ser negativo")
        if self.idle_seconds < 0:
            raise ValueError("idle_seconds no puede ser negativo")
        if self.drift_tolerance < 0:
            raise ValueError("drift_tolerance no puede ser negativo")


# --------------------- Helpers de posición / movimiento ---------------------
def screen_center() -> Tuple[int, int]:
    w, h = pyautogui.size()
    return w // 2, h // 2


def clamp_offset_to_screen(cx: int, dx: int, margin: int = 10) -> int:
    w, _ = pyautogui.size()
    max_dx = max(0, min(dx, cx - margin, (w - margin) - cx))
    return max_dx


def points_from_center(cx: int, cy: int, dx: int, dy: int) -> Tuple[Tuple[int, int], Tuple[int, int]]:
    ax, ay = cx - dx, cy - dy
    bx, by = cx + dx, cy + dy
    return (ax, ay), (bx, by)


def distance(a: Tuple[int, int], b: Tuple[int, int]) -> float:
    return math.hypot(b[0] - a[0], b[1] - a[1])


def wait_until_idle(cfg: BotConfig) -> None:
    """Espera hasta que el mouse esté 'quieto' por cfg.idle_seconds (reinicia si se mueve)."""
    idle_needed = cfg.idle_seconds
    check_interval = 0.05
    last_pos = pyautogui.position()
    quiet_time = 0.0
    while quiet_time < idle_needed:
        time.sleep(check_interval)
        curr = pyautogui.position()
        if distance(curr, last_pos) < 1.0:
            quiet_time += check_interval
        else:
            quiet_time = 0.0
            last_pos = curr


def smooth_move_with_coop(target: Tuple[int, int], cfg: BotConfig) -> bool:
    """
    Mueve hacia 'target' en pasos cortos. Devuelve True si llegó,
    False si el usuario intervino (desvío > drift_tolerance).
    """
    start_pos = pyautogui.position()
    total_time = max(0.001, cfg.move_duration)
    steps = max(1, int(total_time / 0.02))  # ~50 FPS
    start_t = time.monotonic()

    for i in range(1, steps + 1):
        t = i / steps
        eased = 0.5 - 0.5 * math.cos(math.pi * t)  # ease-in-out
        x = round(start_pos[0] + (target[0] - start_pos[0]) * eased)
        y = round(start_pos[1] + (target[1] - start_pos[1]) * eased)

        # ¿Te desviaste lo suficiente como para tomar control?
        curr = pyautogui.position()
        if distance(curr, (x, y)) > cfg.drift_tolerance:
            return False

        pyautogui.moveTo(x, y, duration=0)

        # Mantiene la cadencia temporal real
        target_elapsed = t * total_time
        sleep_left = target_elapsed - (time.monotonic() - start_t)
        if sleep_left > 0:
            time.sleep(sleep_left)

    return True


def move_and_click_coop(target: Tuple[int, int], button: str, cfg: BotConfig) -> bool:
    arrived = smooth_move_with_coop(target, cfg)
    if arrived:
        pyautogui.click(button=button)
        time.sleep(cfg.pause_between)
        return True
    return False


# --------------------------------- Main loop ---------------------------------
def run_bot(cfg: BotConfig) -> None:
    cfg.validate()

    # Duración total (reloj)
    start = time.time()
    end_at = start + cfg.duration_seconds

    if cfg.countdown:
        print(f"Iniciando en {cfg.countdown}… (FAILSAFE: mover a 0,0)")
        for i in range(cfg.countdown, 0, -1):
            print(i)
            time.sleep(1)

    cx, cy = screen_center()
    safe_dx = clamp_offset_to_screen(cx, cfg.offset_x)
    if safe_dx != cfg.offset_x:
        print(f"[Info] Ajuste offset_x {cfg.offset_x} -> {safe_dx} para mantener puntos en pantalla.")
    (ax, ay), (bx, by) = points_from_center(cx, cy, safe_dx, cfg.offset_y)

    print(f"Centro=({cx},{cy})  A=({ax},{ay})  B=({bx},{by})")
    print(f"Duración: {cfg.duration_seconds:.0f}s  Tramo: {cfg.move_duration:.2f}s  Idle: {cfg.idle_seconds}s  Drift: {cfg.drift_tolerance}px")

    cycles = 0
    going_to_b = True

    try:
        while time.time() < end_at:
            target = (bx, by) if going_to_b else (ax, ay)
            button = "right" if going_to_b else "left"

            wait_until_idle(cfg)  # espera a que sueltes el mouse
            arrived = move_and_click_coop(target, button, cfg)

            if arrived:
                going_to_b = not going_to_b
                if not going_to_b:
                    cycles += 1
            else:
                print("Interrumpido por el usuario. Pausando… (se reanuda al soltar el mouse)")

        print(f"Finalizado. Ciclos completos: {cycles}")

    except pyautogui.FailSafeException:
        print("Abortado por FAILSAFE (0,0).")
    except KeyboardInterrupt:
        print("Abortado por el usuario (Ctrl+C).")


# ------------------------ CLI: permite --for 2h30m, etc. ------------------------
def parse_args() -> BotConfig:
    p = argparse.ArgumentParser(description="Bot cooperativo que mueve el mouse entre A y B.")
    p.add_argument("--for", dest="for_duration", type=str, default=None,
                   help="Duración total (ej: '10m', '2h', '1h30m', '90s'). Si no se indica, usa DURATION.")
    p.add_argument("--offset-x", type=int, default=300, help="Distancia horizontal desde el centro (px).")
    p.add_argument("--offset-y", type=int, default=0, help="Distancia vertical desde el centro (px).")
    p.add_argument("--move-duration", type=float, default=5.0, help="Segundos por tramo A->B o B->A.")
    p.add_argument("--pause", type=float, default=0.10, help="Pausa tras cada clic (s).")
    p.add_argument("--countdown", type=int, default=3, help="Cuenta regresiva (s).")
    p.add_argument("--idle-seconds", type=float, default=0.8, help="Segundos de inactividad para reanudar.")
    p.add_argument("--drift", type=float, default=25.0, help="Tolerancia de desvío (px) antes de pausar.")
    a = p.parse_args()

    # Determina la duración (CLI tiene prioridad; si no, usa DURATION del tope)
    duration_str = a.for_duration if a.for_duration else DURATION
    duration_seconds = parse_duration_to_seconds(duration_str)

    return BotConfig(
        duration_seconds=duration_seconds,
        offset_x=a.offset_x,
        offset_y=a.offset_y,
        move_duration=a.move_duration,
        pause_between=a.pause,
        countdown=a.countdown,
        idle_seconds=a.idle_seconds,
        drift_tolerance=a.drift,
    )


if __name__ == "__main__":
    cfg = parse_args()
    run_bot(cfg)
