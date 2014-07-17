nvbio_module(idr)

addsources(
    spp.cu
    alignment.h
    alignment.cpp
    alignment_bam.cpp
)

cuda_add_executable(spp ${idr_srcs})
target_link_libraries(spp bamtools nvbio zlibstatic crcstatic ${SYSTEM_LINK_LIBRARIES})
