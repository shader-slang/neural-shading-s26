module mdl_material_data;

public struct MaterialData
{
    public ByteAddressBuffer buffer;
    public Texture2D textures_2d[32];
    public SamplerState sampler_state;
    public uint arg_block_offset;
    /// Number of bsdf slots used by the material.
    public uint surface_scatter_bsdf_count = 0;

    public T read_only_data_load<T>(uint offset)
    {
        return buffer.LoadAligned<T>(offset, 4);
    }

    public T arg_block_load<T>(uint offset)
    {
        return buffer.LoadAligned<T>(arg_block_offset + offset, 4);
    }
}
