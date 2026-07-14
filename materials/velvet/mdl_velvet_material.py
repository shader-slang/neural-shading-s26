import slangpy as spy
import numpy as np
from pathlib import Path

from materials.mdl_material_base import MDLMaterialBase

MATERIAL_DATA_DIR = Path(__file__).parent / "data"


class VelvetMaterial(MDLMaterialBase):
    def __init__(self, device: spy.Device):
        super().__init__(device)
        self.texture_paths = [
            {"name": MATERIAL_DATA_DIR / "velvet_imperfections.jpg", "srgb": False},
            {"name": MATERIAL_DATA_DIR / "velvet_diff.jpg", "srgb": False},
            {"name": MATERIAL_DATA_DIR / "velvet_norm.jpg", "srgb": False},
        ]
        self.buffer_path = MATERIAL_DATA_DIR / "velvet_material_data.bin"
        self.arg_block_offset = 0
        self.surface_scatter_bsdf_count = 3
        self.material_data_name = "g_material_data_mdl_velvet_material"
