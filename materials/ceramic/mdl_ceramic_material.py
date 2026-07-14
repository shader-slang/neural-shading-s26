import slangpy as spy
import numpy as np
from pathlib import Path

from materials.mdl_material_base import MDLMaterialBase

MATERIAL_DATA_DIR = Path(__file__).parent / "data"


class CeramicMaterial(MDLMaterialBase):
    def __init__(self, device: spy.Device):
        super().__init__(device)
        self.texture_paths = [
            {"name": MATERIAL_DATA_DIR / "versailles2_R_id_G_offs_B_color.png", "srgb": False},
            {"name": MATERIAL_DATA_DIR / "diamond_multi_R_noise1_G_noise2_B_craquelure.jpg", "srgb": False},
            {"name": MATERIAL_DATA_DIR / "diamond_multi_R_rough_G_thickness_B_drops.jpg", "srgb": False},
            {"name": MATERIAL_DATA_DIR / "versailles2_multi_R_height_G_edgefade_B_ao.jpg", "srgb": False},
            {"name": MATERIAL_DATA_DIR / "versailles2_norm.jpg", "srgb": False},
            {"name": MATERIAL_DATA_DIR / "mortar_diff.jpg", "srgb": True},
            {"name": MATERIAL_DATA_DIR / "mortar_norm.jpg", "srgb": False},
        ]
        self.buffer_path = MATERIAL_DATA_DIR / "ceramic_material_data.bin"
        self.arg_block_offset = 2048
        self.surface_scatter_bsdf_count = 2
        self.material_data_name = "g_material_data_mdl_ceramic_material"
