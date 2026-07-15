# Ensure the workspace root is on sys.path so that 'utracer' resolves
# to the package directory, even when this file is run directly as a script.
import argparse
from pathlib import Path
import sys

_WORKSPACE_ROOT = str(Path(__file__).resolve().parent.parent)
if _WORKSPACE_ROOT not in sys.path:
    sys.path.insert(0, _WORKSPACE_ROOT)

import utracer


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run UTracer.")
    parser.add_argument("--checkpoint", type=Path, default=None, help="Optional baked neural checkpoint directory or .npz file.")
    parser.add_argument("--width", type=int, default=1920)
    parser.add_argument("--height", type=int, default=1080)
    args = parser.parse_args()

    root = Path(__file__).parent.parent.resolve()

    device = utracer.create_device()
    scene = utracer.MicroScene(device)
    scene.load_mesh(root / "data/shaderball.glb", rescale_to=1)
    scene.set_env_map(root / "data/brown_photostudio_02_2k.hdr", 1)
    if args.checkpoint is not None:
        scene.set_neural_checkpoint(args.checkpoint)
    scene.build()

    camera = utracer.Camera(device, width=args.width, height=args.height)
    viewer = utracer.Viewer(scene, camera)
    viewer.run()
