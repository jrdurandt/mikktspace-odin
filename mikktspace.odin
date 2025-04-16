package mikktspace

when ODIN_OS == .Linux {
	foreign import lib "libmikktspace.a"
} else when ODIN_OS == .Darwin {
	foreign import lib "libmikktspace.a"
} else when ODIN_OS == .Windows {
	foreign import lib "mikktspace.lib"
}

import c "core:c"

tbool :: distinct c.int

getNumFacesCallback :: #type proc "c" (pContext: ^SMikkTSpaceContext) -> c.int

getNumVerticesOfFaceCallback :: #type proc "c" (
	pContext: ^SMikkTSpaceContext,
	iFace: c.int,
) -> c.int

getPositionCallback :: #type proc "c" (
	pContext: ^SMikkTSpaceContext,
	fvPosOut: [^]c.float,
	iFace: c.int,
	iVert: c.int,
)

getNormalCallback :: #type proc "c" (
	pContext: ^SMikkTSpaceContext,
	fvNormOut: [^]c.float,
	iFace: c.int,
	iVert: c.int,
)

getTexCoordCallback :: #type proc "c" (
	pContext: ^SMikkTSpaceContext,
	fvTexcOut: [^]c.float,
	iFace: c.int,
	iVert: c.int,
)

setTSpaceBasicCallback :: #type proc "c" (
	pContext: ^SMikkTSpaceContext,
	fvTangent: [^]c.float,
	fSign: c.float,
	iFace: c.int,
	iVert: c.int,
)

setTSpaceCallback :: #type proc "c" (
	pContext: ^SMikkTSpaceContext,
	fvTangent: [^]c.float,
	fvBitangent: [^]c.float,
	fMagS: c.float,
	fMagT: c.float,
	bIsOrientationPreserving: tbool,
	iFace: c.int,
	iVert: c.int,
)

SMikkTSpaceContext :: struct {
	m_pInterface: ^SMikkTSpaceInterface,
	m_pUserData:  rawptr,
}

SMikkTSpaceInterface :: struct {
	m_getNumFaces:          getNumFacesCallback,
	m_getNumVerticesOfFace: getNumVerticesOfFaceCallback,
	m_getPosition:          getPositionCallback,
	m_getNormal:            getNormalCallback,
	m_getTexCoord:          getTexCoordCallback,
	m_setTSpaceBasic:       setTSpaceBasicCallback,
	m_setTSpace:            setTSpaceCallback,
}

@(default_calling_convention = "c")
foreign lib {
	genTangSpaceDefault :: proc(pContext: ^SMikkTSpaceContext) -> tbool ---
	genTangSpace :: proc(pContext: ^SMikkTSpaceContext, fAngularThreshold: c.float) -> tbool ---
}

//Simplified usage of MikkTSpace lib
//A lot of this has been adapted from Godot's usage of MikkTSpace.
//User needs to allocate and delete tangent and bitangent data after.
generate_tangent_space :: proc(
	positions: [][3]f32,
	tex_coords: [][2]f32,
	normals: [][3]f32,
	indices: []u16,
	out_tangents: [][3]f32,
	out_bitangents: [][3]f32,
) {
	vertex_count := len(positions)
	assert(vertex_count == len(tex_coords), "Positions and Tex Coords need to be same length")
	assert(vertex_count == len(normals), "Positions and normals need to be same length")

	assert(
		vertex_count == len(out_tangents),
		"Require an output tangent array same length as input positions",
	)
	assert(
		vertex_count == len(out_bitangents),
		"Require an output bitangent array same length as input positions",
	)

	VertexData :: struct {
		positions:  [][3]f32,
		tex_coords: [][2]f32,
		normals:    [][3]f32,
		tangents:   [][3]f32,
		bitangents: [][3]f32,
		indices:    []u16,
	}

	vertex_data := VertexData {
		positions,
		tex_coords,
		normals,
		out_tangents,
		out_bitangents,
		indices,
	}

	get_num_faces_callback: getNumFacesCallback = proc "c" (pContext: ^SMikkTSpaceContext) -> i32 {
		vertex_data: ^VertexData = (^VertexData)(pContext.m_pUserData)
		num := i32(len(vertex_data.indices) / 3)
		return num
	}

	get_num_vertices_of_face_callback: getNumVerticesOfFaceCallback = proc "c" (
		pContext: ^SMikkTSpaceContext,
		iFace: i32,
	) -> i32 {
		return 3
	}

	get_position: getPositionCallback = proc "c" (
		pContext: ^SMikkTSpaceContext,
		fvPosOut: [^]f32,
		iFace: i32,
		iVert: i32,
	) {
		vertex_data: ^VertexData = (^VertexData)(pContext.m_pUserData)
		v: [3]f32
		i := iFace * 3 + iVert
		if len(vertex_data.indices) > 0 {
			index := vertex_data.indices[i]
			if int(index) < len(vertex_data.positions) {
				v = vertex_data.positions[index]
			}
		} else {
			v = vertex_data.positions[i]
		}

		fvPosOut[0] = v.x
		fvPosOut[1] = v.y
		fvPosOut[2] = v.z
	}

	get_normal: getNormalCallback = proc "c" (
		pContext: ^SMikkTSpaceContext,
		fvNormOut: [^]f32,
		iFace: i32,
		iVert: i32,
	) {
		vertex_data: ^VertexData = (^VertexData)(pContext.m_pUserData)

		v: [3]f32
		if len(vertex_data.indices) > 0 {
			index := vertex_data.indices[iFace * 3 + iVert]
			if int(index) < len(vertex_data.normals) {
				v = vertex_data.normals[index]
			}
		} else {
			v = vertex_data.normals[iFace * 3 + iVert]
		}

		fvNormOut[0] = v.x
		fvNormOut[1] = v.y
		fvNormOut[2] = v.z
	}

	get_tex_coord: getTexCoordCallback = proc "c" (
		pContext: ^SMikkTSpaceContext,
		fvTexcOut: [^]f32,
		iFace: i32,
		iVert: i32,
	) {
		vertex_data: ^VertexData = (^VertexData)(pContext.m_pUserData)
		v: [2]f32
		if len(vertex_data.indices) > 0 {
			index := vertex_data.indices[iFace * 3 + iVert]
			if int(index) < len(vertex_data.normals) {
				v = vertex_data.tex_coords[index]
			}
		} else {
			v = vertex_data.tex_coords[iFace * 3 + iVert]
		}

		fvTexcOut[0] = v.x
		fvTexcOut[1] = v.y
	}

	set_tangent_space: setTSpaceCallback = proc "c" (
		pContext: ^SMikkTSpaceContext,
		fvTangent: [^]f32,
		fvBiTangent: [^]f32,
		fMagS: f32,
		fMagT: f32,
		bIsOrientationPreserving: tbool,
		iFace: i32,
		iVert: i32,
	) {
		vertex_data: ^VertexData = (^VertexData)(pContext.m_pUserData)

		tangent: [3]f32 = {fvTangent[0], fvTangent[1], fvTangent[2]}
		bitangent: [3]f32 = {fvBiTangent[0], fvBiTangent[1], fvBiTangent[2]}

		if len(vertex_data.indices) > 0 {
			index := vertex_data.indices[iFace * 3 + iVert]
			if int(index) < len(vertex_data.tangents) {
				vertex_data.tangents[index] = tangent
			}

			if int(index) < len(vertex_data.bitangents) {
				vertex_data.bitangents[index] = bitangent
			}
		} else {
			vertex_data.tangents[iFace * 3 + iVert] = tangent
			vertex_data.bitangents[iFace * 3 + iVert] = bitangent
		}
	}

	interface := SMikkTSpaceInterface {
		m_getNumFaces          = get_num_faces_callback,
		m_getNumVerticesOfFace = get_num_vertices_of_face_callback,
		m_getPosition          = get_position,
		m_getTexCoord          = get_tex_coord,
		m_getNormal            = get_normal,
		m_setTSpace            = set_tangent_space,
	}

	ctx := SMikkTSpaceContext {
		m_pInterface = &interface,
		m_pUserData  = &vertex_data,
	}

	genTangSpaceDefault(&ctx)
}
