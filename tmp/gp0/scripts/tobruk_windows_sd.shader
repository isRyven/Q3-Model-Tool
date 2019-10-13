// tobruk_windows_sd.shader
// generated by ShaderCleaner on Thu Feb  6 12:43:32 2003
// 5 total shaders

textures/tobruk_windows_sd/tobruk_moucha1
{
	cull none
	nomipmaps
	surfaceparm alphashadow
	surfaceparm nomarks
	surfaceparm nonsolid
	surfaceparm trans
	implicitMask -
}

textures/tobruk_windows_sd/tobruk_shutterbrown
{
	surfaceparm woodsteps
	implicitMap -
}

textures/tobruk_windows_sd/tobruk_tobruk_lwind
{
	qer_editorimage textures/tobruk_windows_sd/tobruk_lwind1.tga
	q3map_lightimage textures/tobruk_windows_sd/tobruk_lwind2.tga
	q3map_surfacelight 175
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tobruk_windows_sd/tobruk_lwind1.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tobruk_windows_sd/tobruk_lwind2.tga
		blendfunc GL_ONE GL_ONE
	}
}

textures/tobruk_windows_sd/tobruk_tobruk_mwind
{
	qer_editorimage textures/tobruk_windows_sd/tobruk_mwind1.tga
	q3map_lightimage textures/tobruk_windows_sd/tobruk_mwind2.tga
	q3map_surfacelight 175
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tobruk_windows_sd/tobruk_mwind1.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tobruk_windows_sd/tobruk_mwind2.tga
		blendfunc GL_ONE GL_ONE
	}
}

textures/tobruk_windows_sd/tobruk_windows_bright
{
	qer_editorimage textures/tobruk_windows_sd/tobruk_windows_on2.tga
	q3map_surfacelight 120
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tobruk_windows_sd/tobruk_windows_on2.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tobruk_windows_sd/tobruk_windows_on1.tga
		blendfunc GL_ONE GL_ONE
	}
}

textures/tobruk_windows_sd/tobruk_windows_medium
{
	qer_editorimage textures/tobruk_windows_sd/tobruk_windows_on1.tga
	q3map_surfacelight 45
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tobruk_windows_sd/tobruk_windows_off.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tobruk_windows_sd/tobruk_windows_on1.tga
		blendfunc GL_ONE GL_ONE
	}
}
