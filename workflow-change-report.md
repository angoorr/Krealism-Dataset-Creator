# Workflow change report

The original workflow copy is byte-for-byte unchanged. It contains 80 nodes and 110 links.

The graph still has the original 80 nodes and 110 links, and the link table is byte-for-byte identical. Exactly four existing nodes have changed widget values: node 171's identity adapter path was changed from the Windows-style separator to a Linux-compatible path; node 2889 adds Realism Engine at strength 0.8, disabled by default; nodes 2892 and 2893 now use LC MaskMaker's local model labels for BiRefNet General and ViTMatte Base, which remain valid after setup installs the models. The diffusion model, base-model mode, text encoder, VAE, prompt sets, graph links, image inputs, resolution, steps, sampler, CFG, post-processing, and output settings are unchanged.

The HDR VAE downloader fetches the Krea2-specific HDR VAE file and stores it as `hdrVAE_fp32.safetensors`, the filename saved in the workflow. Realism Engine is a LoKr adapter; its actual effect in this graph remains to be verified by comparing outputs.
