# Workflow change report

The original workflow copy is byte-for-byte unchanged. It contains 80 nodes and 110 links.

The diffusion model, base-model mode, text encoder, VAE, core identity-edit adapter, and graph settings now match the selections in the original workflow. Only the additional Realism Engine row was added to `LCLoraLoader` node 2889. It is preloaded at strength 0.8 and disabled by default so you can toggle it on/off in ComfyUI. No prompts, graph links, image inputs, resolution, steps, sampler, CFG, post-processing, or output settings changed.

The HDR VAE downloader fetches the Krea2-specific HDR VAE file and stores it as `hdrVAE_fp32.safetensors`, the filename saved in the workflow. Realism Engine is a LoKr adapter; its actual effect in this graph remains to be verified by comparing outputs.
