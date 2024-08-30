/// ****************************************************************************
//<copyright file=GeosimExt.cginc company="GeoSim Systems Ltd">
// Copyright © 2000-2018 GeoSim Systems Ltd. All rights reserved. 
//</copyright>
// ****************************************************************************
#ifndef __GEOSIM_EXT_INCLUDED__
#define __GEOSIM_EXT_INCLUDED__

// Uncomment this line to enable extension behavior. To add extensions
// this file needs to be override per each project with different extensions.
#undef _GEOSIM_EXTENSIONS

#if defined(_GEOSIM_EXTENSIONS) 
// Add here the extensions

#else
#	define GEOSIM_EXT_VERTEX(Vert,Input)
#	define GEOSIM_EXT_FRAGMENT(Input,Surface)
#endif // IF _GEOSIM_EXTENSIONS




#endif
