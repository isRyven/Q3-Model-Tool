// assault_rock.shader
// generated by ShaderCleaner on Thu Feb  6 12:43:32 2003
// 5 total shaders

textures/assault_rock/ground_c07a
{
	surfaceparm gravelsteps
	implicitMap -
}

textures/assault_rock/ground_c09a
{
	surfaceparm grasssteps
	implicitMap -
}

textures/assault_rock/haze_vil_night
{
	nocompress
	sort 16
	surfaceparm pointlight
	{
		map textures/assault_rock/haze_vil_night.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
}

textures/assault_rock/haze2
{
	nocompress
	surfaceparm metalsteps
	surfaceparm pointlight
	{
		map textures/assault_rock/haze2.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
}

textures/assault_rock/hazz
{
	nocompress
	sort 16
	surfaceparm metalsteps
	surfaceparm pointlight
	{
		map textures/assault_rock/haze_vil_night.tga
		blendFunc GL_SRC_ALPHA GL_ONE
		rgbGen identity
	}
}
