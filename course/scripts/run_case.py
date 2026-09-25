"""Prepare and run the short EcoSIM examples from a notebook or terminal."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1] / "examples" / "ecosim"
CASES = (
    "snow_dynamics_albedo_internal",
    "snow_dynamics_albedo_low",
    "snow_dynamics_albedo_high",
    "snow_dynamics_phenology_roots",
)


def prepare_case(case: str, days: int = 30) -> Path:
    """Create a fresh run directory beside the forcing data."""
    if case not in CASES:
        raise ValueError(f"Unknown case: {case}")
    if days < 1 or days > 1826:
        raise ValueError("days must be between 1 and 1826")

    run_dir = ROOT / f"{case}.demo"
    input_file = run_dir / f"{case}.xml"
    if input_file.exists() and (run_dir / "duration_days.txt").exists():
        return run_dir
    run_dir.mkdir(parents=True, exist_ok=True)

    source = ROOT / "inputs" / f"{case}.xml"
    tree = ET.parse(source)
    cycle = tree.getroot().find("./ParameterList[@name='cycle driver']")
    if cycle is None:
        raise ValueError(f"Missing cycle driver in {source}")
    end_time = cycle.find("./Parameter[@name='end time']")
    units = cycle.find("./Parameter[@name='end time units']")
    if end_time is None or units is None or units.get("value") != "d":
        raise ValueError(f"Unexpected end time in {source}")
    end_time.set("value", str(days))
    tree.write(input_file, encoding="utf-8", xml_declaration=True)
    (run_dir / "duration_days.txt").write_text(f"{days}\n")
    return run_dir


def run_case(case: str, days: int = 30) -> Path:
    """Run ATS once and return the directory containing results."""
    run_dir = prepare_case(case, days)
    saved_days = int((run_dir / "duration_days.txt").read_text().strip())
    if saved_days != days:
        raise ValueError(
            f"{run_dir} was prepared for {saved_days} days; use that duration or "
            "remove the run directory before preparing a new one"
        )
    if (run_dir / ".ats-complete").exists():
        return run_dir
    if (run_dir / "surf_prop.dat").exists():
        raise RuntimeError(
            f"{run_dir} contains an incomplete result; inspect ats.log and "
            "remove the run directory before retrying"
        )
    ats = shutil.which("ats")
    if ats is None:
        raise RuntimeError("ATS is not on PATH; use the training container")
    log_file = run_dir / "ats.log"
    with log_file.open("w") as log:
        result = subprocess.run(
            [ats, f"{case}.xml"], cwd=run_dir, stdout=log,
            stderr=subprocess.STDOUT, check=False,
        )
    if result.returncode != 0:
        tail = "\n".join(log_file.read_text(errors="replace").splitlines()[-25:])
        raise RuntimeError(f"ATS exited {result.returncode}; see {log_file}\n{tail}")
    if not (run_dir / "surf_prop.dat").exists():
        raise RuntimeError(f"ATS finished without surf_prop.dat; see {log_file}")
    (run_dir / ".ats-complete").write_text("ok\n")
    return run_dir


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("case", choices=CASES)
    parser.add_argument("--days", type=int, default=30)
    arguments = parser.parse_args()
    print(run_case(arguments.case, arguments.days))
