# SPDX-License-Identifier: Apache-2.0

from app import App
import slangpy as spy
from pathlib import Path

from materials.ceramic.mdl_ceramic_material import CeramicMaterial

# Create the app and load the slang module.
app = App(width=1024, height=1024, title="MDL Material Example", device_type=spy.DeviceType.vulkan)
module = spy.Module.load_from_file(app.device, "step_01_basicprogram.slang")
mat = CeramicMaterial(app.device)

loader = spy.TextureLoader(app.device)
envmap = loader.load_texture( Path(__file__).parent.parent / "data/brown_photostudio_02_2k.hdr")
sampler = app.device.create_sampler()

# Allocate a tensor for output
accumulator = spy.Tensor.empty(app.device, (1024,1024), "float4")
output = spy.Tensor.zeros(app.device, (1024,1024), "float3")
counter = 0

while app.process_events():

    # Set up global shader parameters.
    globals = {}
    globals["sampler"] = sampler
    globals["environment_map"] = envmap
    globals.update(mat.to_global_uniforms())

    # Full res rendered output BRDF from full res inputs.    
    module.render.set(globals)(
        pixel=spy.call_id(),
        accumulator=accumulator,
        counter=counter,
        _result=output,
    )
    counter += 1   

    # Blit tensor to screen.
    app.blit(output)

    # Present the window.
    app.present()
    #accumulator = spy.Tensor.empty(app.device, (1024,1024), "float4")
