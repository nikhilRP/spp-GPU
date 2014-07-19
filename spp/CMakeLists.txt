nvbio_module(idr)

addsources(
    spp.cpp
)
nvbio_add_module_directory(cuda)

cuda_add_executable(spp ${idr_srcs})
target_link_libraries(spp nvbio zlibstatic crcstatic ${SYSTEM_LINK_LIBRARIES})
